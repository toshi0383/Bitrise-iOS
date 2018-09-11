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

    private let fetchMeApps: (MeAppsRequest) -> Observable<MeAppsRequest.Response>
    private let appsManager: AppsManager

    init(fetchMeApps: @escaping (MeAppsRequest) -> Observable<MeAppsRequest.Response> = Router.fetchMeApps,
         appsManager: AppsManager = .shared) {
        self.fetchMeApps = fetchMeApps
        self.appsManager = appsManager
    }

    let route = BehaviorRelay<[Route]>(value: [.launch])

    private let disposeBag = DisposeBag()

    func showTutorial() {
        route.accept([.tutorial])
    }

    func showAppsList() {

        route.accept([.launch])

        fetchMeApps(MeAppsRequest())
            .subscribe(
                onNext: { [weak self] res in
                    guard let me = self else { return }

                    me.appsManager.apps = res.data

                    let cond: (MeApps.App) -> Bool = {
                        if let appname = Config.lastAppNameVisited {
                            return $0.title == appname
                        } else {
                            return true
                        }
                    }

                    if let fst = res.data.first(where: cond) {
                        // buildvc on top of appvc
                        me.route.accept([.appsList, .buildsList(fst)])
                    }
                },

                onError: { [weak self] _ in
                    guard let me = self else { return }

                    me.showTutorial()
                }
            )
            .disposed(by: disposeBag)

    }
}

extension Router {
    enum Route {
        case appsList, buildsList(MeApps.App), launch, tutorial
    }
}
