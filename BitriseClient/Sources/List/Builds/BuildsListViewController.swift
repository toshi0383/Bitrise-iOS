import APIKit
import UIKit

final class BuildsListViewController: UIViewController, Storyboardable, UITableViewDataSource, UITableViewDelegate {

    typealias Dependency = String

    static func makeFromStoryboard(_ dependency: String) -> BuildsListViewController {
        let vc = BuildsListViewController.unsafeMakeFromStoryboard()
        vc.appSlug = dependency
        return vc
    }

    private var appSlug: String!

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    private var builds: [AppsBuilds.Build] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let req = AppsBuildsRequest(appSlug: appSlug)
        Session.shared.send(req) { [weak self] result in
            guard let me = self else { return }

            switch result {
            case .success(let res):
                me.builds = res.data
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
        return builds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuildCell") as! BuildCell
        cell.configure(builds[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }
}
