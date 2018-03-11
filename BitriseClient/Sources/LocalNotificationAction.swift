//
//  LocalNotificationAction.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/03/11.
//

import APIKit
import Foundation
import UserNotifications

class LocalNotificationAction: NSObject, UNUserNotificationCenterDelegate {
    static let shared = LocalNotificationAction()

    struct Notification {
        let title: String
        let body: String
        init(build: AppsBuilds.Build) {
            self.title = "Build Status Update"
            self.body = build.status_text
        }
    }

    private let session: Session

    init(session: Session = .shared) {
        self.session = session
    }

    func reserve(appSlug: AppSlug, buildSlug: AppsBuilds.Build.Slug) {
        requestAuthorizationIfNeeded()

        let trigger: UNNotificationTrigger
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "hello"
        content.body = buildSlug

        // 通常
        let request = UNNotificationRequest(identifier: "\(appSlug)-\(buildSlug)",
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current()
            .add(request, withCompletionHandler: nil)
    }

    func send(build: AppsBuilds.Build) {
        requestAuthorizationIfNeeded()

        let trigger: UNNotificationTrigger
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let content = UNMutableNotificationContent()
        let not = Notification(build: build)
        content.title = not.title
        content.body = not.body
        content.sound = UNNotificationSound.default()

        // 通常
        let request = UNNotificationRequest(identifier: "normal",
                                            content: content,
                                            trigger: trigger)


        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }

    private func requestAuthorizationIfNeeded() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
            if let error = error {
                print("error: \(error), granted: \(granted)")
                return
            }
        })
    }

    // MARK: UNUserNotificationCenterDelegate

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let separated = notification.request.identifier.split(separator: "-").map(String.init)
        if separated.count != 2 {
            completionHandler([.alert, .badge, .sound])
            return
        }

        let appSlug = separated[0]
        let buildSlug = separated[1]
        let req = BuildRequest(appSlug: appSlug, buildSlug: buildSlug)

        session.send(req) { [weak self] result in
            switch result {
            case .success(let res):
                self?.send(build: res.data)
            case .failure(let error):
                print("\(error)")
            }
        }
    }
}
