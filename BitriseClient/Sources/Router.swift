//
//  Router.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/21.
//

import APIKit
import Foundation
import UIKit

final class Router {
    static let shared = Router()

    var appWindow: UIWindow?

    func showTutorial() {
        let vc = TutorialViewController.makeFromStoryboard()
        let nc = UINavigationController(rootViewController: vc)
        nc.isNavigationBarHidden = true
        appWindow?.rootViewController = nc
        appWindow?.makeKeyAndVisible()
    }

    func showAppsList() {

        do {
            let vc = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
            self.appWindow?.rootViewController = vc
            self.appWindow?.makeKeyAndVisible()
        }

        let req = MeAppsRequest()
        Session.shared.send(req) { [unowned self] result in

            switch result {
            case .success(let res):

                AppsManager.shared.apps = res.data

                let cond: (MeApps.App) -> Bool = {
                    if let appname = Config.defaults[.lastAppNameVisited] {
                        return $0.title == appname
                    } else {
                        return true
                    }
                }

                if let fst = res.data.first(where: cond) {
                    DispatchQueue.main.async { [unowned self] in

                        // buildvc on top of appvc
                        let appvc = AppsListViewController.makeFromStoryboard(.init())
                        let buildvc = BuildsListViewController.makeFromStoryboard(
                            .init(appSlug: fst.slug, appName: fst.title)
                        )
                        let nc = UINavigationController()

                        nc.setViewControllers([appvc, buildvc], animated: false)
                        self.appWindow?.rootViewController = nc
                    }
                }
            case .failure(let error):
                #if DEBUG
                    print(error)
                #endif

                self.showTutorial()
            }
        }

    }
}
