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

    enum FetchMode {
        case new, between, more

        var limit: Int {
            switch self {
            case .new:
                return 50
            case .between:
                return 20
            case .more:
                return 50
            }
        }
    }

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
                self?.sendAbortRequest(forBuild: build)
            }))
            alertActions.append(AlertAction.init(title: "Set Notification", handler: { [weak self] _ in
                self?.reserveNotification(forBuild: build)
            }))
        }

        if build.status != .notFinished {
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
    let isBetweenDataIndicatorHidden: Constant<Bool>
    let isMoreDataIndicatorHidden: Constant<Bool>

    // MARK: private properties

    private let _alertMessage = Variable<String>(value: "")
    private let _alertActions = Variable<[AlertAction]>(value: [])
    private let _dataChanges = Variable<[Change<AppsBuilds.Build>]>(value: [])
    private(set) var builds: [AppsBuilds.Build] = []
    private let _isNewDataIndicatorHidden = Variable<Bool>(value: true)
    private let _isBetweenDataIndicatorHidden = Variable<Bool>(value: true)
    private let _scrollRemainingRatio = Variable<CGFloat>(value: 10000)
    private let _isMoreDataIndicatorHidden = Variable<Bool>(value: true)
    private let _isLoading = Variable<Bool>(value: false)

    private let nextTokenNew = Variable<(next: String, offset: Int)?>(value: nil)
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
        self.isBetweenDataIndicatorHidden = Constant(variable: _isBetweenDataIndicatorHidden)
        self.isMoreDataIndicatorHidden = Constant(variable: _isMoreDataIndicatorHidden)

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

        notificationCenter.continuum
            .observe(_scrollRemainingRatio, on: OperationQueue()) { [weak self] remainingRatio in
                if remainingRatio < 0.02 {
                    self?.triggerPaging()
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

        if _isLoading.value { return }
        _isLoading.value = true

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

            me._isLoading.value = false
        }
    }

    /// - parameter offset: Index where you want to load new data at.
    ///      It should be current last index plus 1.
    func fetchBuilds(_ fetchMode: FetchMode) {

        if _isLoading.value { return }
        _isLoading.value = true

        let setIndicatorIsHidden: (Bool) -> () = { [weak self] isHidden in

            guard let me = self else { return }

            switch fetchMode {
            case .new:
                me._isNewDataIndicatorHidden.value = isHidden
            case .between:
                me._isBetweenDataIndicatorHidden.value = isHidden
            case .more:
                me._isMoreDataIndicatorHidden.value = isHidden
            }
        }

        setIndicatorIsHidden(false)

        let next: String? = {
            switch fetchMode {
            case .between:
                return nextTokenNew.value!.next
            case .more:
                return nextTokenMore.value
            case .new:
                return nil
            }
        }()

        let offset: Int = {
            switch fetchMode {
            case .between:
                return nextTokenNew.value!.offset
            case .more:
                return builds.count
            case .new:
                return 0
            }
        }()

        let req = AppsBuildsRequest(appSlug: appSlug, limit: fetchMode.limit, next: next)

        session.send(req) { [weak self] result in
            guard let me = self else { return }

            setIndicatorIsHidden(true)

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

                    if i + offset <= newBuilds.count {
                        newBuilds.insert(new, at: i + offset)
                    }
                }

                let changes = diff(old: me.builds, new: newBuilds)
                me.builds = newBuilds
                me._dataChanges.value = changes

                switch fetchMode {
                case .between:
                    if !reachedCurrent, let next = appsBuilds.paging.next {
                        me.nextTokenNew.value = (next: next, offset: appsBuilds.data.count)
                    } else {
                        me.nextTokenNew.value = nil
                    }
                case .more:
                    if let next = appsBuilds.paging.next {
                        me.nextTokenMore.value = next
                    } else {
                        me.nextTokenMore.value = nil
                    }
                case .new:
                    break
                }

            case .failure(let error):
                print(error)

            }

            me._isLoading.value = false
        }
    }

    func triggerPaging() {
        if let next = nextTokenMore.value {
            fetchBuilds(.more)
        }
    }

    func updateScrollInfo(contentHeight: CGFloat, contentOffsetY: CGFloat, frameHeight: CGFloat, adjustedContentInsetBottom: CGFloat) {
        if contentHeight <= 0 {
            return
        }
        let frameVisibleHeight = frameHeight - adjustedContentInsetBottom
        _scrollRemainingRatio.value = (contentHeight - contentOffsetY - frameVisibleHeight) / contentHeight
    }

    func reserveNotification(forBuild build: AppsBuilds.Build) {
        localNotificationAction.requestAuthorizationIfNeeded()

        buildPollingManager.addLocalNotification(buildSlug: build.slug)
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
