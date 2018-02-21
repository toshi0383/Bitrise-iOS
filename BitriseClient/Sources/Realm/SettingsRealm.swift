import Foundation
import RealmSwift

final class SettingsRealm: Object {
    @objc dynamic var pkey = "1"
    @objc dynamic var personalAccessToken: String?
    @objc dynamic var lastAppNameVisited: String?

    override static func primaryKey() -> String? {
        return "pkey"
    }
}
