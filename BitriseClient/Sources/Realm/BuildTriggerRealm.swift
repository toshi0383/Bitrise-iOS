import Realm
import RealmSwift

class BuildTriggerRealm: Object {
    @objc dynamic var appSlug = ""
    @objc dynamic var gitObjectType: String?
    @objc dynamic var gitObjectValue: String?

    // NOTE: This is different from the personal access token
    // [SettingRealm.personalAccessToken](setting-realm-personal-access-token)
    @objc dynamic var apiToken: String?

    var workflowIDs = List<String>()

    var environments = List<BuildTriggerEnvironmentRealm>()

    override static func primaryKey() -> String? {
        return "appSlug"
    }
}

class BuildTriggerEnvironmentRealm: Object {
    @objc dynamic var enabled = true
    @objc dynamic var key = ""
    @objc dynamic var value = ""

    override static func primaryKey() -> String? {
        return "key"
    }
}

extension BuildTriggerEnvironmentRealm {
    static func create(_ model: BuildTriggerEnvironment) -> BuildTriggerEnvironmentRealm {
        let e = BuildTriggerEnvironmentRealm()
        e.enabled = model.enabled
        e.key = model.key
        e.value = model.value
        return e
    }
}
