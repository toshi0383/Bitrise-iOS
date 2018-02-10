//
//  BuildTriggerRequest.swift
//  BitriseClient
//
//  Created by 鈴木 俊裕 on 2018/02/05.
//  Copyright © 2018 toshi0383. All rights reserved.
//

import Foundation

struct BuildTriggerRequest: Codable {

    let hook_info: HookInfo

    struct HookInfo: Codable {
        let type: String = "bitrise"
        let api_token: String
    }

    let build_params: [String: String]
    let triggered_by: String = "BitriseClient iOS App"
}
