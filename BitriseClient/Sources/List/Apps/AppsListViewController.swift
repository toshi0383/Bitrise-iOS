import APIKit
import UIKit

final class AppsListViewController: UIViewController, Storyboardable, UITableViewDataSource, UITableViewDelegate {

    typealias Dependency = Void

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    private var apps: [MeApps.App] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let req = MeAppsRequest()
        Session.shared.send(req) { [weak self] result in
            guard let me = self else { return }

            switch result {
            case .success(let res):
                me.apps = res.data
                me.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }

    // MARK: UITableViewDataSource & UITableViewDelegate

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppCell") as! AppCell
        cell.configure(apps[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let app = apps[indexPath.row]
        let dep = (app.slug, app.title)
        let vc = BuildsListViewController.makeFromStoryboard(dep)
        navigationController?.pushViewController(vc, animated: true)
    }
}
