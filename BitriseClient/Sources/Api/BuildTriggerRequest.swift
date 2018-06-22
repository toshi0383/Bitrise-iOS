//
//  BuildTriggerRequest.swift
//  BitriseClient
//
//  Created by 鈴木 俊裕 on 2018/02/05.
//  Copyright © 2018 toshi0383. All rights reserved.
//

import Foundation

struct BuildTriggerRequest {

    let hook_info: HookInfo

    struct HookInfo {
        let type: String = "bitrise"
        let api_token: String

        func json() -> [String: Any] {
            return ["type": type, "api_token": api_token]
        }
    }

    let build_params: [String: Any]
    let triggered_by: String = "BitriseClient iOS App"

    enum CustomerKeys: String, CodingKey {
        case hook_info, build_params, triggered_by
    }

    func encode() throws -> Data {
        let json: [String: Any] = [
            "hook_info": hook_info.json(),
            "build_params": build_params,
            "triggered_by": triggered_by
        ]
        return try JSONSerialization.data(withJSONObject: json, options: [])
    }
}
