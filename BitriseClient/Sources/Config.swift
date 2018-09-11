import RealmSwift
import UIKit

// - MARK: ConfigType

protocol ConfigType {
    var personalAccessToken: String? { get }
    var lastAppNameVisited: String? { get }
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
                realm.add(settings, update: true)
            }
        }
    }

    // MARK: lastAppNameVisited

    var lastAppNameVisited: String? {
        get {
            let realm = Realm.getRealm()
            return realm.object(ofType: SettingsRealm.self, forPrimaryKey: "1")?.lastAppNameVisited
        }
        set {
            let realm = Realm.getRealm()
            let settings = realm.object(ofType: SettingsRealm.self, forPrimaryKey: "1") ?? SettingsRealm()
            try! realm.write {
                settings.lastAppNameVisited = newValue
                realm.add(settings, update: true)
            }
        }
    }
}
