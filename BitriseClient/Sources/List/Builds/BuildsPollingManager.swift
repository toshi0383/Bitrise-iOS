import APIKit
import Core
import Foundation
import RxCocoa
import RxSwift

final class BuildPollingManager {

    typealias Build = AppsBuilds.Build
    typealias Slug = Build.Slug

    let updatedBuild: Observable<Build>
    private let _updatedBuild = PublishRelay<Build>()

    let appSlug: String // accessed from pool

    private(set) var targets = Set<AppsBuilds.Build.Slug>()

    private let interval: Double = 8.0

    private var localNotificationTargets: Set<Slug> = []
    private var workItemMap: [Slug: DispatchWorkItem] = [:]

    private let session: Session
    private let localNotificationAction: LocalNotificationAction
    private let disposeBag = DisposeBag()

    init(appSlug: String,
         session: Session = .shared,
         localNotificationAction: LocalNotificationAction = .shared) {
        self.appSlug = appSlug
        self.session = session
        self.localNotificationAction = localNotificationAction
        self.updatedBuild = _updatedBuild.asObservable()
    }

    func addTarget(buildSlug: Slug) {
        targets.insert(buildSlug)

        // start polling
        startPolling(buildSlug)
    }

    func removeAllTargets() {
        for target in targets {
            removeTarget(buildSlug: target)
        }
    }

    func removeTarget(buildSlug: Slug) {
        targets.remove(buildSlug)

        if !localNotificationTargets.contains(buildSlug) {
            workItemMap.removeValue(forKey: buildSlug)?.cancel()
        }
    }

    func addLocalNotification(buildSlug: Slug) {
        localNotificationTargets.insert(buildSlug)
    }

    // MARK: Utilities

    private func startPolling(_ buildSlug: Slug) {
        let workItem = DispatchWorkItem { [weak self] in
            self?.callAPIAndUpdateHandler(buildSlug)
        }

        workItemMap[buildSlug] = workItem

        DispatchQueue.global()
            .asyncAfter(deadline: DispatchTime.now() + interval, execute: workItem)
    }

    private func callAPIAndUpdateHandler(_ buildSlug: Slug) {
        let req = SingleBuildRequest(appSlug: appSlug, buildSlug: buildSlug)

        session.rx.send(req)
            .subscribe(onNext: { [weak self] res in
                guard let me = self else { return }

                let build = SingleBuild(from: res).data

                me._updatedBuild.accept(build)

                if build.status == .notFinished {

                    me.startPolling(buildSlug)

                } else {

                    if me.localNotificationTargets.contains(where: { $0 == build.slug }) {
                        me.localNotificationAction.send(build: build)
                        me.localNotificationTargets.remove(build.slug)
                    }

                }
            })
            .disposed(by: disposeBag)
    }
}
