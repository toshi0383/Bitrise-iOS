import APIKit
import Core
import DeepDiff
import Foundation
import RxSwift
import RxCocoa
import UIKit

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

    var lifecycle: ViewControllerLifecycle! {
        didSet {
            lifecycle.viewDidLoad
                .subscribe(onNext: { [weak self] in
                    guard let me = self else { return }

                    // save app-title
                    Config.lastAppNameVisited = me.appName

                    me.fetchDataAndReloadTable()
                })
                .disposed(by: disposeBag)

            lifecycle.viewWillDisappear
                .subscribe(onNext: { [weak self] _ in
                    guard let me = self else { return }

                    for buildSlug in me.buildPollingManager.targets {
                        me.buildPollingManager.removeTarget(buildSlug: buildSlug)
                    }
                })
                .disposed(by: disposeBag)
        }
    }

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

                do {
                    try TriggerBuildAction.shared.sendRebuildRequest(appSlug: me.appSlug, build)
                } catch {
                    me._alertMessage.accept("\(error)")
                }
            }))
        }

        alertActions.append(.init(title: "Cancel", style: .cancel, handler: nil))

        _alertActions.accept(alertActions)
    }

    // MARK: Output

    let appSlug: String
    let navigationBarTitle: String
    let alertMessage: Observable<String>

    /// alert from accessory button
    let alertActions: Property<[AlertAction]>

    let dataChanges: Property<[Change<AppsBuilds.Build>]>
    let isNewDataIndicatorHidden: Property<Bool>
    let isBetweenDataIndicatorHidden: Property<Bool>
    let isMoreDataIndicatorHidden: Property<Bool>

    // MARK: private properties

    private let _alertMessage = PublishRelay<String>()
    private let _alertActions = BehaviorRelay<[AlertAction]>(value: [])
    private let _dataChanges = BehaviorRelay<[Change<AppsBuilds.Build>]>(value: [])
    private(set) var builds: [AppsBuilds.Build] = []
    private let _isNewDataIndicatorHidden = BehaviorRelay<Bool>(value: true)
    private let _isBetweenDataIndicatorHidden = BehaviorRelay<Bool>(value: true)
    private let _scrollRemainingRatio = BehaviorRelay<CGFloat>(value: 10000)
    private let _isMoreDataIndicatorHidden = BehaviorRelay<Bool>(value: true)
    private let _isLoading = BehaviorRelay<Bool>(value: false)

    private let nextTokenNew = BehaviorRelay<(next: String, offset: Int)?>(value: nil)
    private let nextTokenMore = BehaviorRelay<String?>(value: nil)

    private let session: Session
    private let localNotificationAction: LocalNotificationAction
    private let disposeBag = DisposeBag()
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

        self.alertMessage = _alertMessage.asObservable()
        self.alertActions = Property(_alertActions)
        self.dataChanges = Property(_dataChanges)
        self.isNewDataIndicatorHidden = Property(_isNewDataIndicatorHidden)
        self.isBetweenDataIndicatorHidden = Property(_isBetweenDataIndicatorHidden)
        self.isMoreDataIndicatorHidden = Property(_isMoreDataIndicatorHidden)

        let buildPollingManager = BuildPollingManagerPool.shared.manager(for: appSlug)
        self.buildPollingManager = buildPollingManager

        dataChanges.changed
            .subscribe(onNext: { [weak self] changes in
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
                            me._dataChanges.accept(changes)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        _scrollRemainingRatio
            .subscribe(onNext: { [weak self] remainingRatio in
                if remainingRatio < 0.02 {
                    self?.triggerPaging()
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: API Call

    private func fetchDataAndReloadTable() {

        if _isLoading.value { return }
        _isLoading.accept(true)

        let req = AppsBuildsRequest(appSlug: appSlug)

        session.send(req) { [weak self] result in
            guard let me = self else { return }

            switch result {
            case .success(let res):
                let appsBuilds = AppsBuilds(from: res)
                let changes = diff(old: me.builds, new: appsBuilds.data)
                me.builds = appsBuilds.data
                me._dataChanges.accept(changes)
                me.nextTokenMore.accept(appsBuilds.paging.next)

            case .failure(let error):
                print(error)
            }

            me._isLoading.accept(false)
        }
    }

    /// - parameter offset: Index where you want to load new data at.
    ///      It should be current last index plus 1.
    ///
    /// - FIXME:
    ///     When data is loaded partially like this: [(900...851), (800...751)]
    ///     triggering pull-to-refresh causes droppping the next token for (850...801).
    ///
    func fetchBuilds(_ fetchMode: FetchMode) {

        if _isLoading.value { return }
        _isLoading.accept(true)

        let setIndicatorIsHidden: (Bool) -> () = { [weak self] isHidden in

            guard let me = self else { return }

            switch fetchMode {
            case .new:
                me._isNewDataIndicatorHidden.accept(isHidden)
            case .between:
                me._isBetweenDataIndicatorHidden.accept(isHidden)
            case .more:
                me._isMoreDataIndicatorHidden.accept(isHidden)
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

                switch fetchMode {
                case .new,
                     .between:

                    if let newLast = appsBuilds.data.last?.build_number,
                        let currentFirst = newBuilds.first?.build_number {
                        if newLast > currentFirst + 1 {
                            // More data exists in between. Set nextToken for new data.
                            if let next = appsBuilds.paging.next {
                                me.nextTokenNew.accept((next, appsBuilds.data.count))
                            }
                        } else if currentFirst >= newLast {
                            // Caught-up to current. nil-out the nextToken for new data.
                            me.nextTokenNew.accept(nil)
                        }
                    }

                case .more:
                    if let next = appsBuilds.paging.next {
                        me.nextTokenMore.accept(next)
                    } else {
                        me.nextTokenMore.accept(nil)
                    }
                }

                for (i, new) in appsBuilds.data.enumerated() {
                    if i + offset <= newBuilds.count {
                        newBuilds.insert(new, at: i + offset)
                    }
                }

                let changes = diff(old: me.builds, new: newBuilds)
                me.builds = newBuilds
                me._dataChanges.accept(changes)

            case .failure(let error):
                print(error)

            }

            me._isLoading.accept(false)
        }
    }

    func triggerPaging() {
        if nextTokenMore.value != nil {
            fetchBuilds(.more)
        }
    }

    func updateScrollInfo(contentHeight: CGFloat, contentOffsetY: CGFloat, frameHeight: CGFloat, adjustedContentInsetBottom: CGFloat) {
        if contentHeight <= 0 {
            return
        }
        let frameVisibleHeight = frameHeight - adjustedContentInsetBottom
        _scrollRemainingRatio.accept((contentHeight - contentOffsetY - frameVisibleHeight) / contentHeight)
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
                    me._alertMessage.accept(msg)
                } else {
                    me._alertMessage.accept("Aborted: #\(buildNumber)")
                }
            case .failure(let error):
                me._alertMessage.accept("Abort failed: \(error.localizedDescription)")
            }
        }
    }
}

private extension Array where Element == AppsBuilds.Build {
    func containsByBuildNumber(_ build: Element) -> Bool {
        return self.contains { $0.build_number == build.build_number }
    }
}
