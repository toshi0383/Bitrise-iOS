//
//  BuildsListViewModel.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/23.
//

import APIKit
import Foundation

final class BuildsListViewModel {

    // MARK: Input

    private let appName: String

    // MARK: Output

    // FIXME: This is terrible. I need a Reactive tool.
    //   Maybe Continuum with closure handler API?
    typealias AlertClosure = (String, (() -> ())?) -> ()

    let appSlug: String
    let navigationBarTitle: String

    private(set) var reloadData: (() -> ())!
    private(set) var alert: AlertClosure!

    // MARK: private properties

    private(set) var builds: [AppsBuilds.Build] = []

    // MARK: Initializer

    init(appSlug: String,
         appName: String) {
        self.appSlug = appSlug
        self.appName = appName
        self.navigationBarTitle = appName
    }

    // MARK: LifeCycle & Update

    func viewDidLoad(reloadData: @escaping () -> (), alert: @escaping AlertClosure) {
        // save app-title
        Config.lastAppNameVisited = appName

        self.reloadData = reloadData
        self.alert = alert

        fetchDataAndReloadTable()
    }

    // MARK: API Call

    // TODO: Insert Animation
    func fetchDataAndReloadTable() {
        let req = AppsBuildsRequest(appSlug: appSlug)
        Session.shared.send(req) { [weak self] result in
            guard let me = self else { return }

            switch result {
            case .success(let res):
                me.builds = res.data
                me.reloadData()
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
                    me.alert(msg)
                } else {
                    me.alert("Aborted: #\(buildNumber)") { [weak self] in
                        self?.fetchDataAndReloadTable()
                    }
                }
            case .failure(let error):
                self?.alert("Abort failed: \(error.localizedDescription)")
            }
        }
    }

    private func alert(_ message: String, completion: (() -> ())? = nil) {
        alert(message, completion: completion)
    }

}
