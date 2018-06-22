//
//  BuildTriggerEnvironment.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/06/22.
//

import Foundation

// https://devcenter.bitrise.io/api/build-trigger/#specify-environment-variables
struct BuildTriggerEnvironment: Equatable {
    let enabled: Bool
    let key: String
    let value: String

    init(realmObject: BuildTriggerEnvironmentRealm) {
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
