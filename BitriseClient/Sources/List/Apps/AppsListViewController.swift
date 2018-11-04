import APIKit
import UIKit

final class AppsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var appsManager: AppsManager!

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let me = self else { return }

                me.tableView.deselectRow(at: indexPath, animated: true)
                let app = me.appsManager.apps[indexPath.row]
                let vc = BuildsListViewController.makeFromStoryboard(
                    .init(viewModel: .init(appSlug: app.slug, appName: app.title)))
                me.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appsManager.apps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppCell") as! AppCell
        cell.configure(appsManager.apps[indexPath.row])
        return cell
    }
}

// - MARK: Storyboardable

extension AppsListViewController: Storyboardable {

    struct Dependency {
        let appsManager: AppsManager
        init(appsManager: AppsManager = .shared) {
            self.appsManager = appsManager
        }
    }

    static func makeFromStoryboard(_ dependency: AppsListViewController.Dependency) -> AppsListViewController {
        let vc = unsafeMakeFromStoryboard()
        vc.appsManager = dependency.appsManager
        return vc
    }

}
