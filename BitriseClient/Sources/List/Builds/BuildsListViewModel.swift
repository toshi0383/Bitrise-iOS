import os.signpost
import APIKit
import Core
import DeepDiff
import Foundation
import RxSwift
import RxCocoa
import UIKit

final class BuildsListViewModel {

    let buildPollingManager: BuildPollingManager

    /// lock for updateBuild
    private let updateBuildLock = NSLock()

    var lifecycle: ViewControllerLifecycle! {
        didSet {
            lifecycle.viewDidLayoutSubviews
                .subscribe(onNext: { [weak self] _ in
                    guard let me = self else { return }

                    // save app-title
                    Config.shared.lastAppSlugVisited = me.appSlug

                    me.fetchInitialDataIfNeededAndLoadTable()
                })
                .disposed(by: disposeBag)

            lifecycle.viewWillDisappear
                .subscribe(onNext: { [weak self] _ in
                    guard let me = self else { return }

                    me.buildPollingManager.removeAllTargets()
                })
                .disposed(by: disposeBag)
        }
    }

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
        } else {

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

    let appSlug: String
    private var initialResponse: AppsBuilds?
    let navigationBarTitle: String
    let alertMessage: Observable<String>

    /// alert from accessory button
    let alertActions: Observable<[AlertAction]>

    let dataChanges: Property<[Change<AppsBuilds.Build>]>
    let isNewDataIndicatorHidden: Property<Bool>
    let isBetweenDataIndicatorHidden: Property<Bool>
    let isMoreDataIndicatorHidden: Property<Bool>

    private(set) var builds: [AppsBuilds.Build] = []

    // MARK: private properties

    private let _alertMessage = PublishRelay<String>()
    private let _alertActions = PublishRelay<[AlertAction]>()
    private let _dataChanges = BehaviorRelay<[Change<AppsBuilds.Build>]>(value: [])
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

    // MARK: Initializer

    init(origin: BuildsListOrigin,
         localNotificationAction: LocalNotificationAction = .shared,
         session: Session = .shared) {
        self.appSlug = origin.appSlug
        self.initialResponse = origin.appsBuilds
        self.navigationBarTitle = origin.appName
        self.localNotificationAction = localNotificationAction
        self.session = session
        self.buildPollingManager = BuildPollingManagerPool.shared.manager(for: origin.appSlug)
        self.alertMessage = _alertMessage.asObservable()
        self.alertActions = _alertActions.asObservable()
        self.dataChanges = Property(_dataChanges)
        self.isNewDataIndicatorHidden = Property(_isNewDataIndicatorHidden)
        self.isBetweenDataIndicatorHidden = Property(_isBetweenDataIndicatorHidden)
        self.isMoreDataIndicatorHidden = Property(_isMoreDataIndicatorHidden)

        buildPollingManager.updatedBuild
            .subscribe(onNext: { [weak self] build in
                guard let me = self else { return }

                me.updateBuildLock.lock(); defer { me.updateBuildLock.unlock() }

                if let index = me.builds.firstIndex(of: build) {
                    if me.builds[index] == build {
                        return
                    }

                    var newBuilds = me.builds
                    newBuilds[index] = build

                    let changes = diff(old: me.builds, new: newBuilds)

                    me.builds = newBuilds

                    me._dataChanges.accept(changes)
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

    // MARK: Utilities

    func updateBuild(_ build: AppsBuilds.Build) {
        updateBuildLock.lock(); defer { updateBuildLock.unlock() }

        if let idx = builds.lastIndex(where: { $0.slug == build.slug }) {
            builds[idx] = build
        }
    }

    // MARK: API Call

    private func fetchInitialDataIfNeededAndLoadTable() {

        if _isLoading.value { return }
        _isLoading.accept(true)

        let updateNewData = { [weak self] (_ appsBuilds: AppsBuilds) -> Void in
            guard let me = self else { return }

            me.updateBuildLock.lock(); defer { me.updateBuildLock.unlock() }

            let changes = diff(old: me.builds, new: appsBuilds.data)

            me.builds = appsBuilds.data

            me._dataChanges.accept(changes)
            me.nextTokenMore.accept(appsBuilds.paging.next)
            me._isLoading.accept(false)
        }

        if let appsBuilds = initialResponse {
            updateNewData(appsBuilds)
            initialResponse = nil
            return
        }

        let req = AppsBuildsRequest(appSlug: appSlug)

        session.rx.send(req)
            .catchError({ [weak self] _ in
                self?._isLoading.accept(false)
                return .empty()
            })
            .map(AppsBuilds.init)
            .subscribe(onNext: updateNewData)
            .disposed(by: disposeBag)
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

        session.rx.send(req)
            .catchError({ [weak self] _ in
                self?._isLoading.accept(false)
                return .empty()
            })
            .subscribe(onNext: { [weak self] res in
                guard let me = self else { return }

                setIndicatorIsHidden(true)

                me.updateBuildLock.lock(); defer { me.updateBuildLock.unlock() }

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

                me._isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }

    func triggerPaging() {
        if nextTokenMore.value != nil {
            fetchBuilds(.more)
        }
    }

    func updateScrollInfo(contentHeight: CGFloat, contentOffsetY: CGFloat, frameHeight: CGFloat, adjustedContentInsetBottom: CGFloat) {
        if #available(iOS 12.0, *) {
            os_signpost(.event, log: .pointsOfInterest, name: "updateScrollInfo")
        }

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

        session.rx.send(req)
            .catchError({ [weak self] error in
                self?._isLoading.accept(false)
                self?._alertMessage.accept("Abort failed: \(error.localizedDescription)")
                return .empty()
            })
            .map { res in
                if let msg = res.error_msg {
                    return msg
                } else {
                    return "Aborted: #\(buildNumber)"
                }
            }
            .bind(to: _alertMessage)
            .disposed(by: disposeBag)
    }
}

// MARK: Type

extension BuildsListViewModel {

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
        let style: UIAlertAction.Style
        let handler: ((UIAlertAction) -> ())?

        init(title: String,
             style: UIAlertAction.Style = .default,
             handler: ((UIAlertAction) -> ())?) {
            self.title = title
            self.style = style
            self.handler = handler
        }
    }
}

private extension Array where Element == AppsBuilds.Build {
    func containsByBuildNumber(_ build: Element) -> Bool {
        return self.contains { $0.build_number == build.build_number }
    }
}
