import APIKit
import Core
import Foundation
import RxCocoa
import RxSwift
import UIKit

final class Router {
    static let shared = Router()

    private static var fetchMeApps: (MeAppsRequest) -> Observable<MeAppsRequest.Response> {
        return Session.shared.rx.send
    }

    private static var fetchAppsBuilds: (AppsBuildsRequest) -> Observable<AppsBuildsRequest.Response> {
        return Session.shared.rx.send
    }

    private let fetchMeApps: (MeAppsRequest) -> Observable<MeAppsRequest.Response>
    private let fetchAppsBuilds: (AppsBuildsRequest) -> Observable<AppsBuildsRequest.Response>
    private let appsManager: AppsManager
    private let config: ConfigType

    init(fetchMeApps: @escaping (MeAppsRequest) -> Observable<MeAppsRequest.Response> = Router.fetchMeApps,
         fetchAppsBuilds: @escaping (AppsBuildsRequest) -> Observable<AppsBuildsRequest.Response> = Router.fetchAppsBuilds,
         appsManager: AppsManager = .shared,
         config: ConfigType = Config.shared) {
        self.fetchMeApps = fetchMeApps
        self.fetchAppsBuilds = fetchAppsBuilds
        self.appsManager = appsManager
        self.config = config
    }

    let route = BehaviorRelay<[Route]>(value: [.launch])

    private let disposeBag = DisposeBag()

    func showTutorial() {
        route.accept([.tutorial])
    }

    func showAppsList() {

        route.accept([.launch])

        let appsBuilds: Observable<(AppsBuilds, AppSlug)?>
        if let appslug = config.lastAppSlugVisited {
            appsBuilds = fetchAppsBuilds(AppsBuildsRequest(appSlug: appslug))
                .map(AppsBuilds.init)
                .map { ($0, appslug) }
        } else {
            appsBuilds = Observable.just(nil)
        }

        // buildvc on top of appvc
        Observable.combineLatest(fetchMeApps(MeAppsRequest()), appsBuilds)
            .filter { !$0.0.data.isEmpty }
            .subscribe(
                onNext: { [weak self] (meApps, appsBuildsRes) in
                    guard let me = self else { return }

                    me.appsManager.apps = meApps.data

                    let origin: BuildsListOrigin = {

                        if let appsBuildsRes = appsBuildsRes {

                            let (appsBuilds, appSlug) = appsBuildsRes

                            if let fst = meApps.data.first(where: { $0.slug == appSlug }) {
                                return BuildsListOrigin(appSlug: fst.slug, appName: fst.title, appsBuilds: appsBuilds)
                            } else {
                                let fst = meApps.data.first!
                                return BuildsListOrigin(appSlug: fst.slug, appName: fst.title)
                            }
                        } else {
                            if let savedSlug = me.config.lastAppSlugVisited,

                                let fst = meApps.data.first(where: { $0.slug == savedSlug }) {
                                return BuildsListOrigin(appSlug: fst.slug, appName: fst.title)

                            } else {

                                let fst = meApps.data.first!
                                return BuildsListOrigin(appSlug: fst.slug, appName: fst.title)
                            }
                        }
                    }()

                    me.route.accept([.appsList, .buildsList(origin)])
                },

                onError: { [weak self] error in
                    guard let me = self else { return }

                    print("\(error)")
                    me.showTutorial()
                }
            )
            .disposed(by: disposeBag)

    }
}

extension Router {
    enum Route: Equatable {
        case appsList
        case buildsList(BuildsListOrigin)
        case launch
        case tutorial
    }
}
