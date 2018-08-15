import Core
import Foundation

final class AppsManager {
    static let shared = AppsManager()

    var apps: [MeApps.App] = []
}
