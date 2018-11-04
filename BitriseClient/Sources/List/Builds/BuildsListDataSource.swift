import UIKit

final class BuildsListDataSource: NSObject, UITableViewDataSource {

    private let viewModel: BuildsListViewModel

    init(viewModel: BuildsListViewModel) {
        self.viewModel = viewModel
    }

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

}
