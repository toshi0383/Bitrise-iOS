import Realm
import RealmSwift

public class BuildTriggerRealm: Object {
    @objc public dynamic var appSlug = ""
    @objc public dynamic var gitObjectType: String?
    @objc public dynamic var gitObjectValue: String?

    public var workflowIDs = List<String>()

    public var environments = List<BuildTriggerEnvironmentRealm>()

    override public static func primaryKey() -> String? {
        return "appSlug"
    }
}

public class BuildTriggerEnvironmentRealm: Object {
    @objc public dynamic var pkey = ""
    @objc public dynamic var enabled = true
    @objc public dynamic var key = ""
    @objc public dynamic var value = ""

    override public static func primaryKey() -> String? {
        return "pkey"
    }
}

extension BuildTriggerEnvironmentRealm {
    public static func create(_ model: BuildTriggerEnvironment) -> BuildTriggerEnvironmentRealm {
        let e = BuildTriggerEnvironmentRealm()
        e.enabled = model.enabled
        e.pkey = model.pkey
        e.key = model.mapped_to
        e.value = model.value
        return e
    }
}
