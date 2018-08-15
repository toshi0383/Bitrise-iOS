import Core
import Foundation

// https://devcenter.bitrise.io/api/build-trigger/#specify-environment-variables
struct BuildTriggerEnvironment: Equatable {
    let pkey: String
    let enabled: Bool
    let key: String
    let value: String

    init(pkey: String, enabled: Bool, key: String, value: String) {
        self.pkey = pkey
        self.enabled = enabled
        self.key = key
        self.value = value
    }

    init(realmObject: BuildTriggerEnvironmentRealm) {
        self.pkey = realmObject.pkey
        self.enabled = realmObject.enabled
        self.key = realmObject.key
        self.value = realmObject.value
    }

    var string: String {
        return "\(key):\(value)"
    }

    var json: JSON {
        return [
            "mapped_to": key,
            "value": value,
            "is_expand": false,
        ]
    }
}
