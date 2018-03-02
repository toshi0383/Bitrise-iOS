//
//  BuildsListViewModel.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/23.
//

import APIKit
import Continuum
import DeepDiff
import Foundation

final class BuildsListViewModel {

    // MARK: Input

    private let appName: String

    // MARK: Output

    let appSlug: String
    let navigationBarTitle: String
    let alertMessage: Constant<String>
    let dataChanges: Constant<[Change<AppsBuilds.Build>]>

    // MARK: private properties

    private let _alertMessage = Variable<String>(value: "")
    private let _dataChanges = Variable<[Change<AppsBuilds.Build>]>(value: [])
    private(set) var builds: [AppsBuilds.Build] = []

    // MARK: Initializer

    init(appSlug: String,
         appName: String) {
        self.appSlug = appSlug
        self.appName = appName
        self.navigationBarTitle = appName
        self.alertMessage = Constant(variable: _alertMessage)
        self.dataChanges = Constant(variable: _dataChanges)
    }

    // MARK: LifeCycle & Update

    func viewDidLoad() {
        // save app-title
        Config.lastAppNameVisited = appName

        fetchDataAndReloadTable()
    }

    // MARK: API Call

    func fetchDataAndReloadTable() {
        let req = AppsBuildsRequest(appSlug: appSlug)
        Session.shared.send(req) { [weak self] result in
            guard let me = self else { return }

            switch result {
            case .success(let res):
                let changes = diff(old: me.builds, new: res.data)
                me.builds = res.data
                me._dataChanges.value = changes
            case .failure(let error):
                print(error)
            }
        }
    }

    func sendAbortRequest(indexPath: IndexPath) {
        let buildSlug = builds[indexPath.row].slug
        let buildNumber = builds[indexPath.row].build_number
        let req = AppsBuildsAbortRequest(appSlug: appSlug, buildSlug: buildSlug)

        Session.shared.send(req) { [weak self] result in
            guard let me = self else { return }

            switch result {
            case .success(let res):
                if let msg = res.error_msg {
                    me._alertMessage.value = msg
                } else {
                    me._alertMessage.value = "Aborted: #\(buildNumber)"
                    me.fetchDataAndReloadTable()
                }
            case .failure(let error):
                me._alertMessage.value = "Abort failed: \(error.localizedDescription)"
            }
        }
    }

}
