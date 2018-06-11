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

    // MARK: Type

    struct AlertAction {
        let title: String
        let style: UIAlertActionStyle
        let handler: ((UIAlertAction) -> ())?

        init(title: String,
             style: UIAlertActionStyle = .default,
             handler: ((UIAlertAction) -> ())?) {
            self.title = title
            self.style = style
            self.handler = handler
        }
    }

    // MARK: Input

    private let appName: String

    func tappedAccessoryButtonIndexPath(_ indexPath: IndexPath) {

        if builds.count < indexPath.row + 1 {
            return
        }

        let build = builds[indexPath.row]
        var alertActions = [AlertAction]()

        if build.status == .notFinished {
            alertActions.append(AlertAction.init(title: "Abort", handler: { [weak self] _ in
                guard let me = self else {
                    return
                }

                me.sendAbortRequest(forBuild: build)
            }))
        }

        if build.status == .finished {
            alertActions.append(AlertAction.init(title: "Rebuild", handler: { [weak self] _ in
                guard let me = self else { return }

                TriggerBuildAction.shared.sendRebuildRequest(appSlug: me.appSlug, build)
            }))
        }

        alertActions.append(.init(title: "Cancel", style: .cancel, handler: nil))

        _alertActions.value = alertActions
    }

    // MARK: Output

    let appSlug: String
    let navigationBarTitle: String
    let alertMessage: Constant<String>

    /// alert from accessory button
    let alertActions: Constant<[AlertAction]>

    let dataChanges: Constant<[Change<AppsBuilds.Build>]>
    let isNewDataIndicatorHidden: Constant<Bool>
    // let isMoreDataIndicatorHidden: Constant<Bool>

    // MARK: private properties

    private let _alertMessage = Variable<String>(value: "")
    private let _alertActions = Variable<[AlertAction]>(value: [])
    private let _dataChanges = Variable<[Change<AppsBuilds.Build>]>(value: [])
    private(set) var builds: [AppsBuilds.Build] = []
    let _isNewDataIndicatorHidden = Variable<Bool>(value: true)
    // let isMoreDataIndicatorHidden = Variable<Bool>(value: true)

    private let nextTokenNew = Variable<String?>(value: nil)
    private let nextTokenMore = Variable<String?>(value: nil)

    private let session: Session
    private let localNotificationAction: LocalNotificationAction
    private let disposeBag = NotificationCenterContinuum.Bag()
    private let buildPollingManager: BuildPollingManager

    /// lock to avoid race condition
    private let lock = NSLock()

    // MARK: Initializer

    init(appSlug: String,
         appName: String,
         localNotificationAction: LocalNotificationAction = .shared,
         session: Session = .shared) {
        self.appSlug = appSlug
        self.appName = appName
        self.navigationBarTitle = appName
        self.localNotificationAction = localNotificationAction
        self.session = session

        self.alertMessage = Constant(variable: _alertMessage)
        self.alertActions = Constant(variable: _alertActions)
        self.dataChanges = Constant(variable: _dataChanges)
        self.isNewDataIndicatorHidden = Constant(variable: _isNewDataIndicatorHidden)

        let buildPollingManager = BuildPollingManagerPool.shared.manager(for: appSlug)
        self.buildPollingManager = buildPollingManager

        notificationCenter.continuum
            .observe(dataChanges, on: OperationQueue()) { [weak self] changes in
                if changes.isEmpty { // skip initial value
                    return
                }
                for c in changes {
                    if let item = c.insert?.item {

                        buildPollingManager.addTarget(buildSlug: item.slug) { [weak self] build in
                            guard let me = self else { return }
                            me.lock.lock(); defer { me.lock.unlock() }

                            var newData = me.builds
                            if let index = newData.index(where: { $0.slug == build.slug }) {
                                newData[index] = build
                            }

                            let changes = diff(old: me.builds, new: newData)
                            me.builds = newData
                            me._dataChanges.value = changes
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: LifeCycle & Update

    func viewDidLoad() {
        // save app-title
        Config.lastAppNameVisited = appName

        fetchDataAndReloadTable()
    }

    func viewWillDisappear() {
        for buildSlug in buildPollingManager.targets {
            buildPollingManager.removeTarget(buildSlug: buildSlug)
        }
    }

    // MARK: API Call

    // TODO: paging
    // FIXME: avoid dropping existing data
    func fetchDataAndReloadTable() {
        let req = AppsBuildsRequest(appSlug: appSlug)

        session.send(req) { [weak self] result in
            guard let me = self else { return }

            switch result {
            case .success(let res):
                let appsBuilds = AppsBuilds(from: res)
                let changes = diff(old: me.builds, new: appsBuilds.data)
                me.builds = appsBuilds.data
                me._dataChanges.value = changes
                me.nextTokenMore.value = appsBuilds.paging.next

            case .failure(let error):
                print(error)
            }
        }
    }

    func triggerPullToRefresh() {
        _isNewDataIndicatorHidden.value = false

        let req = AppsBuildsRequest(appSlug: appSlug, limit: 10)

        session.send(req) { [weak self] result in
            guard let me = self else { return }

            me._isNewDataIndicatorHidden.value = true

            switch result {
            case .success(let res):

                let appsBuilds = AppsBuilds(from: res)
                var newBuilds: [AppsBuilds.Build] = me.builds
                var reachedCurrent = false

                for (i, new) in appsBuilds.data.enumerated() {
                    if newBuilds.containsByBuildNumber(new) {
                        reachedCurrent = true
                        break
                    }
                    newBuilds.insert(new, at: i)
                }

                if !reachedCurrent {
                    print("FIXME: there is new data in between")
                }

                me.nextTokenNew.value = !reachedCurrent ? appsBuilds.paging.next : nil

                let changes = diff(old: me.builds, new: newBuilds)
                me.builds = newBuilds
                me._dataChanges.value = changes

            case .failure(let error):
                print(error)

            }
        }
    }

    func reserveNotification(indexPath: IndexPath) {
        localNotificationAction.requestAuthorizationIfNeeded()

        let buildSlug = builds[indexPath.row].slug
        buildPollingManager.addLocalNotification(buildSlug: buildSlug)
    }

    private func sendAbortRequest(forBuild build: AppsBuilds.Build) {

        let buildSlug = build.slug
        let buildNumber = build.build_number
        let req = AppsBuildsAbortRequest(appSlug: appSlug, buildSlug: buildSlug)

        session.send(req) { [weak self] result in
            guard let me = self else { return }

            switch result {
            case .success(let res):
                if let msg = res.error_msg {
                    me._alertMessage.value = msg
                } else {
                    me._alertMessage.value = "Aborted: #\(buildNumber)"
                }
            case .failure(let error):
                me._alertMessage.value = "Abort failed: \(error.localizedDescription)"
            }
        }
    }
}

private extension Array where Element == AppsBuilds.Build {
    func containsByBuildNumber(_ build: Element) -> Bool {
        return self.contains { $0.build_number == build.build_number }
    }
}
