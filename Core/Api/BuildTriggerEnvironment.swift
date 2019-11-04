import Foundation

// https://devcenter.bitrise.io/api/build-trigger/#specify-environment-variables
public struct BuildTriggerEnvironment: Equatable, Codable {
    public let pkey: String
    public let enabled: Bool
    public let mapped_to: String
    public let value: String
    public let is_expand: Bool = false

    public init(pkey: String, enabled: Bool, key: String, value: String) {
        self.pkey = pkey
        self.enabled = enabled
        self.mapped_to = key
        self.value = value
    }

    public init(realmObject: BuildTriggerEnvironmentRealm) {
        self.pkey = realmObject.pkey
        self.enabled = realmObject.enabled
        self.mapped_to = realmObject.key
        self.value = realmObject.value
    }

    public var string: String {
        return "\(mapped_to):\(value)"
    }
}
