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

    override static func primaryKey() -> String? {
        return "appSlug"
    }
}
