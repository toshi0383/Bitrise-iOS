//
//  BuildsPollingManager.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/03/08.
//

import APIKit
import Foundation

final class BuildPollingManager {

    typealias Build = AppsBuilds.Build
    typealias Slug = Build.Slug
    typealias UpdateHandler = (Build) -> ()

    private let interval: Double = 8.0

    private var handlers: [Slug: UpdateHandler] = [:]
    private var workItemMap: [Slug: DispatchWorkItem] = [:]

    let appSlug: String // accessed from pool
    private let session: Session

    init(appSlug: String, session: Session = .shared) {
        self.appSlug = appSlug
        self.session = session
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
        workItemMap.removeValue(forKey: buildSlug)?.cancel()
    }

    // MARK: Utilities
    private func startPolling(_ buildSlug: Slug) {
        let workItem = DispatchWorkItem { [weak self] in
            self?.callAPIAndUpdateHandler(buildSlug)
        }

        workItemMap[buildSlug] = workItem

        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + interval, execute: workItem)
    }

    private func callAPIAndUpdateHandler(_ buildSlug: Slug) {
        let req = BuildRequest(appSlug: appSlug, buildSlug: buildSlug)
        session.send(req) { [weak self] result in
            guard let me = self else { return }

            switch result {
            case .success(let res):
                let build = res.data
                me.handlers[buildSlug]?(build)
                if build.status == .notFinished {
                    me.startPolling(buildSlug)
                } else {
                    me.removeTarget(buildSlug: buildSlug)
                }
            case .failure(let error):
                print("\(error)")
            }
        }
    }
}
