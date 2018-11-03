import os.log
import APIKit
import Core
import DeepDiff
import RxSwift
import UIKit

final class BuildsListViewController: UIViewController, Storyboardable, UITableViewDataSource, UITableViewDelegate {

    struct Dependency {
        let viewModel: BuildsListViewModel
    }

    static func makeFromStoryboard(_ dependency: Dependency) -> BuildsListViewController {
        let vc = BuildsListViewController.unsafeMakeFromStoryboard()
        vc.viewModel = dependency.viewModel
        vc.viewModel.lifecycle = vc.lifecycle
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

    @IBOutlet private weak var bitriseYmlButton: UIButton! {
        didSet {
            bitriseYmlButton.layer.cornerRadius = bitriseYmlButton.frame.width / 2
        }
    }

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        return refreshControl
    }()

    private let disposeBag = DisposeBag()

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.navigationBarTitle

        viewModel.alertMessage
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe(onNext: { [weak self] msg in
                self?.alert(msg)
            })
            .disposed(by: disposeBag)

        viewModel.alertActions.asObservable()
            .filterEmpty()
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe(onNext: { [weak self] alertActions in
                self?.showActionSheet(actions: alertActions)
            })
            .disposed(by: disposeBag)

        viewModel.dataChanges.changed
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe(onNext: { [weak self] changes in
                self?.tableView.reload(changes: changes, completion: { _ in })
            })
            .disposed(by: disposeBag)

        viewModel.isNewDataIndicatorHidden.asObservable()
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe(onNext: { [weak self] isHidden in
                guard let me = self else { return }

                if isHidden {
                    me.refreshControl.endRefreshing()
                } else {
                    me.refreshControl.beginRefreshing()
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: IBAction

    @IBAction func bitriseYmlButtonTap() {
        let vm = BitriseYmlViewModel(appSlug: viewModel.appSlug, appName: viewModel.navigationBarTitle)
        let vc = BitriseYmlViewController(viewModel: vm)

        vc.modalPresentationStyle = .overCurrentContext

        navigationController?.present(vc, animated: true, completion: nil)
    }

    @IBAction func triggerBuildButtonTap() {
        Haptic.generate(.light)

        let logicStore = TriggerBuildViewModel(appSlug: viewModel.appSlug)
        let vc = TriggerBuildViewController.makeFromStoryboard(logicStore)

        vc.modalPresentationStyle = .overCurrentContext

        navigationController?.present(vc, animated: true, completion: nil)

        logicStore.buildDidTrigger
            .subscribe(onNext: { [weak viewModel] _ in
                viewModel?.fetchBuilds(.new)
            })
            .disposed(by: disposeBag)
    }

    @objc private func pullToRefresh() {
        viewModel.fetchBuilds(.new)
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

    private var visibleBuilds: [AppsBuilds.Build] {
        guard let indexPaths = tableView.indexPathsForVisibleRows else { return [] }

        return indexPaths.map { viewModel.builds[$0.row] }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        // Reset BuildPollingManager.targets

        let visibleBuilds = self.visibleBuilds
        let buildPollingManager = viewModel.buildPollingManager

        for buildSlug in buildPollingManager.targets {

            if !visibleBuilds.contains(where: { $0.slug == buildSlug }) {

                // NOTE: Polling won't be cancelled if localNotification is registered.
                buildPollingManager.removeTarget(buildSlug: buildSlug)

            }
        }

        for visibleBuild in visibleBuilds {

            if visibleBuild.status == .notFinished,
                !buildPollingManager.targets.contains(where: { $0 == visibleBuild.slug }) {

                buildPollingManager.addTarget(buildSlug: visibleBuild.slug)

            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {

        viewModel.tappedAccessoryButtonIndexPath(indexPath)

    }

    func showActionSheet(actions: [BuildsListViewModel.AlertAction]) {

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        for action in actions {
            actionSheet.addAction(UIAlertAction(title: action.title,
                                                style: action.style,
                                                handler: action.handler))
        }

        present(actionSheet, animated: true, completion: nil)
    }

    private var alphaChangingViews: [UIView] {
        return [triggerBuildButton, bitriseYmlButton]
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        alphaChangingViews.forEach { $0.alpha = 0.1 }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        self.workItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            UIView.animate(withDuration: 0.3) {
                self?.alphaChangingViews.forEach { $0.alpha = 1.0 }
            }
        }

        self.workItem = workItem

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5,
                                      execute: workItem)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewModel.updateScrollInfo(contentHeight: scrollView.contentSize.height,
                                   contentOffsetY: scrollView.contentOffset.y,
                                   frameHeight: scrollView.frame.height,
                                   adjustedContentInsetBottom: scrollView.adjustedContentInset.bottom)
    }
}
