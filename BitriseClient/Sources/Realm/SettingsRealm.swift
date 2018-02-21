import Foundation
import RealmSwift

final class SettingsRealm: Object {
    @objc dynamic var pkey = "1"
    @objc dynamic var personalAccessToken: String?

    override static func primaryKey() -> String? {
        return "pkey"
    }
}
