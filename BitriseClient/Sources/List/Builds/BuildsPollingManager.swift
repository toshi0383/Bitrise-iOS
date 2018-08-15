import APIKit
import Core
import Foundation

final class BuildPollingManager {

    typealias Build = AppsBuilds.Build
    typealias Slug = Build.Slug
    typealias UpdateHandler = (Build) -> ()

    private let interval: Double = 8.0

    private var handlers: [Slug: UpdateHandler] = [:]
    private var localNotificationTargets: Set<Slug> = []
    private var workItemMap: [Slug: DispatchWorkItem] = [:]

    let appSlug: String // accessed from pool
    private let session: Session
    private let localNotificationAction: LocalNotificationAction

    init(appSlug: String,
         session: Session = .shared,
         localNotificationAction: LocalNotificationAction = .shared) {
        self.appSlug = appSlug
        self.session = session
        self.localNotificationAction = localNotificationAction
    }

    var targets: [AppsBuilds.Build.Slug] {
        return handlers.keys.map { $0 }
    }

    func addTarget(buildSlug: Slug, completion: @escaping UpdateHandler) {
        handlers[buildSlug] = completion

        // start polling
        startPolling(buildSlug)
    }

    func removeTarget(buildSlug: Slug) {
        handlers.removeValue(forKey: buildSlug)
        if !localNotificationTargets.contains(buildSlug) {
            workItemMap.removeValue(forKey: buildSlug)?.cancel()
        }
    }

    func addLocalNotification(buildSlug: Slug) {
        localNotificationTargets.insert(buildSlug)
        if !handlers.keys.contains(buildSlug) {
            fatalError("Polling should have already started.")
        }
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
        session.send(req) { [weak self] result in
            guard let me = self else { return }
            switch result {
            case .success(let res):
                let build = SingleBuild(from: res).data

                me.handlers[buildSlug]?(build)

                if build.status == .notFinished {
                    me.startPolling(buildSlug)

                } else {

                    if me.localNotificationTargets.contains(where: { $0 == build.slug }) {
                        me.localNotificationAction.send(build: build)
                        me.localNotificationTargets.remove(build.slug)
                    }

                    me.removeTarget(buildSlug: buildSlug)
                }

            case .failure(let error):
                print("\(error)")
            }
        }
    }
}
