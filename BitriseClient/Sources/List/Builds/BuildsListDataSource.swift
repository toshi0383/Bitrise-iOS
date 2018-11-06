import RxSwift
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
        let build = viewModel.builds[indexPath.row]
        cell.configure(build)

        if build.status == .notFinished {
            viewModel.buildPollingManager.updatedBuild
                .filter { build.slug == $0.slug }
                .observeOn(ConcurrentMainScheduler.instance)
                .subscribe(onNext: { [weak cell, weak self] in
                    if $0.status == .finished {
                        self?.viewModel.updateBuild($0)
                        self?.viewModel.buildPollingManager.removeTarget(buildSlug: $0.slug)
                    }

                    cell?.configure($0)
                })
                .disposed(by: cell.reuseDisposeBag)
        }

        return cell
    }

}
