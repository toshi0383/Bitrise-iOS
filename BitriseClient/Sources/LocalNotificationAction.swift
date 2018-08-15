import APIKit
import Core
import Foundation
import UserNotifications

class LocalNotificationAction: NSObject, UNUserNotificationCenterDelegate {
    static let shared = LocalNotificationAction()

    struct Notification {
        let title: String
        let body: String
        init(build: AppsBuilds.Build) {
            self.title = "Build #\(build.build_number) \(build.status_text)"
            self.body = build.status_text
        }
    }

    private let session: Session

    init(session: Session = .shared) {
        self.session = session
    }

    func send(build: AppsBuilds.Build) {
        requestAuthorizationIfNeeded()

        let trigger: UNNotificationTrigger
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let content = UNMutableNotificationContent()
        let not = Notification(build: build)
        content.title = not.title
        content.sound = UNNotificationSound.default()

        let request = UNNotificationRequest(identifier: "normal",
                                            content: content,
                                            trigger: trigger)


        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }

    func requestAuthorizationIfNeeded() {
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
        completionHandler([.alert, .badge, .sound])
    }
}
