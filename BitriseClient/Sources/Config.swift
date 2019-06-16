import RealmSwift
import UIKit

// - MARK: ConfigType

protocol ConfigType {
    var personalAccessToken: String? { get }
    var lastAppSlugVisited: String? { get }
}

// - MARK: Config

final class Config: ConfigType {

    static let shared = Config()

    // MARK: PersonalAccessToken

    var personalAccessToken: String? {
        get {
            let realm = Realm.getRealm()
            return realm.object(ofType: SettingsRealm.self, forPrimaryKey: "1")?.personalAccessToken
        }
        set {
            let realm = Realm.getRealm()
            let settings = realm.object(ofType: SettingsRealm.self, forPrimaryKey: "1") ?? SettingsRealm()
            try! realm.write {
                settings.personalAccessToken = newValue
                realm.add(settings, update: .all)
            }
        }
    }

    // MARK: lastAppSlugVisited

    var lastAppSlugVisited: String? {
        get {
            let realm = Realm.getRealm()
            return realm.object(ofType: SettingsRealm.self, forPrimaryKey: "1")?.lastAppSlugVisited
        }
        set {
            let realm = Realm.getRealm()
            let settings = realm.object(ofType: SettingsRealm.self, forPrimaryKey: "1") ?? SettingsRealm()
            try! realm.write {
                settings.lastAppSlugVisited = newValue
                realm.add(settings, update: .all)
            }
        }
    }
}
