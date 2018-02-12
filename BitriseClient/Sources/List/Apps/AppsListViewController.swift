import APIKit
import UIKit

final class AppsListViewController: UIViewController, Storyboardable, UITableViewDataSource, UITableViewDelegate {

    struct Dependency {
        let appsManager: AppsManager
        init(appsManager: AppsManager = .shared) {
            self.appsManager = appsManager
        }
    }

    private var appsManager: AppsManager!

    static func makeFromStoryboard(_ dependency: AppsListViewController.Dependency) -> AppsListViewController {
        let vc = unsafeMakeFromStoryboard()
        vc.appsManager = dependency.appsManager
        return vc
    }

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.reloadData()
    }

    // MARK: UITableViewDataSource & UITableViewDelegate

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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let app = appsManager.apps[indexPath.row]
        let vc = BuildsListViewController.makeFromStoryboard(
            .init(appSlug: app.slug, appName: app.title))
        navigationController?.pushViewController(vc, animated: true)
    }
}
