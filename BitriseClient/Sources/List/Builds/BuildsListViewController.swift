import APIKit
import Continuum
import DeepDiff
import UIKit

final class BuildsListViewController: UIViewController, Storyboardable, UITableViewDataSource, UITableViewDelegate {

    struct Dependency {
        let viewModel: BuildsListViewModel
    }

    static func makeFromStoryboard(_ dependency: Dependency) -> BuildsListViewController {
        let vc = BuildsListViewController.unsafeMakeFromStoryboard()
        vc.viewModel = dependency.viewModel
        return vc
    }

    private var viewModel: BuildsListViewModel!

    // animation dispatch after
    private var workItem: DispatchWorkItem?

    @IBOutlet private weak var triggerBuildButton: UIButton! {
        didSet {
            triggerBuildButton.layer.cornerRadius = triggerBuildButton.frame.width / 2
        }
    }

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    private let disposeBag = NotificationCenterContinuum.Bag()

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.navigationBarTitle

        viewModel.viewDidLoad()

        notificationCenter.continuum
            .observe(viewModel.alertMessage, on: .main) { [weak self] msg in
                if !msg.isEmpty { // skip initial value
                    self?.alert(msg)
                }
            }
            .disposed(by: disposeBag)

        notificationCenter.continuum
            .observe(viewModel.dataChanges, on: .main) { [weak self] changes in
                if !changes.isEmpty { // skip initial value
                    self?.tableView.reload(changes: changes, completion: { _ in })
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: IBAction

    @IBAction func triggerBuildButtonTap() {
        Haptic.generate(.light)
        let vc = TriggerBuildViewController.makeFromStoryboard(TriggerBuildLogicStore(appSlug: viewModel.appSlug))
        vc.modalPresentationStyle = .overCurrentContext
        navigationController?.present(vc, animated: true, completion: nil)
    }

    // MARK: UITableViewDataSource & UITableViewDelegate

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.builds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuildCell") as! BuildCell
        cell.configure(viewModel.builds[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Abort", style: .default, handler: { [weak self] _ in
            self?.viewModel.sendAbortRequest(indexPath: indexPath)
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true, completion: nil)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        triggerBuildButton.alpha = 0.1
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        self.workItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            UIView.animate(withDuration: 0.3) {
                self?.triggerBuildButton.alpha = 1.0
            }
        }

        self.workItem = workItem

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5,
                                      execute: workItem)
    }
}
