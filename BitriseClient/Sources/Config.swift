import Foundation
import RealmSwift
import UIKit

// - MARK: InfoPlist

private let InfoPlist = _InfoPlist()

private class _InfoPlist {
    private let _Plist = Bundle.main.infoDictionary!

    enum OptionalDictionaryKey: String {
        case TRIGGER_BUILD_WORKFLOW_IDS
    }

    subscript(key: OptionalDictionaryKey) -> [String: String]? {
        if let s = _Plist["\(key)"] as? String, !s.isEmpty {
            return try! JSONDecoder().decode([String: String].self, from: s.data(using: .utf8)!)
        } else {
            return nil
        }
    }
}

// - MARK: Config

final class Config {

    static var workflowIDsMap: [AppSlug: [WorkflowID]] {
        guard let dictionary = InfoPlist[.TRIGGER_BUILD_WORKFLOW_IDS] else {
            return [:]
        }

        return dictionary.mapValues(stringToStrArray)
    }

    private static func stringToStrArray(_ string: String) -> [String] {
        return string
            .split(separator: " ")
            .filter { !$0.isEmpty }
            .map { String($0) }
    }

    // MARK: PersonalAccessToken

    static var personalAccessToken: String? {
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

    static var lastAppNameVisited: String? {
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
