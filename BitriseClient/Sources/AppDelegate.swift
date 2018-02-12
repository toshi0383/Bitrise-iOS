//
//  AppDelegate.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2017/12/19.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import ActionPopoverButton
import APIKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // ActionPopoverButton
        UIView.hth.exchangeMethods()

        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.rootViewController = SplashViewController.makeFromStoryboard()

        let req = MeAppsRequest()
        Session.shared.send(req) { result in

            switch result {
            case .success(let res):
                if let fst = res.data.first(where: { $0.title == "abema-ios" }) {
                    let dep: (String, String) = (fst.slug, fst.title)
                    DispatchQueue.main.async { [unowned self] in
                        let vc = BuildsListViewController.makeFromStoryboard(dep)
                        self.window?.rootViewController = vc
                        self.window?.makeKeyAndVisible()
                    }
                }
            case .failure(let error):
                #if DEBUG
                    print(error)
                #endif
            }
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

