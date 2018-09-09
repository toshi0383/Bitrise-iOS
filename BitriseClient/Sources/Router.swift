import APIKit
import Core
import Foundation
import RxCocoa
import RxSwift
import UIKit

final class Router {
    static let shared = Router()

    let route = BehaviorRelay<[Route]>(value: [.launch])

    private let disposeBag = DisposeBag()

    func showTutorial() {
        route.accept([.tutorial])
    }

    func showAppsList() {

        route.accept([.launch])

        let req = MeAppsRequest()

        Session.shared.rx.send(req)
            .subscribe(
                onNext: { [weak self] res in
                    guard let me = self else { return }

                    AppsManager.shared.apps = res.data

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
