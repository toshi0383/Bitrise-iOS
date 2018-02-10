//
//  LogicStore.swift
//  BitriseClient
//
//  Created by 鈴木 俊裕 on 2018/02/05.
//  Copyright © 2018 toshi0383. All rights reserved.
//

import Continuum
import Foundation

typealias WorkflowID = String

final class LogicStore {

    var workflowID: WorkflowID?
    var apiToken: String? = Config.apiToken

    var gitObject: GitObject = .branch("") {
        didSet {
            print(gitObject)
        }
    }

    func urlRequest() -> URLRequest? {

        guard let token = apiToken else { return nil }
        guard let workflowID = workflowID else { return nil }

        let _gitObject = gitObject

        guard let url = URL(string: "https://www.bitrise.io/app/\(Config.appSlug)/build/start.json") else {
            return nil
        }

        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 5.0)

        let body = BuildTriggerRequest(hook_info: .init(api_token: token),
                                       build_params: _gitObject.json + ["workflow_id": workflowID])
        req.httpBody = try! JSONEncoder().encode(body)
        req.httpMethod = "POST"

        return req
    }
}

typealias JSON = [String: String]
func + (_ lhs: JSON, _ rhs: JSON) -> JSON {
    var r: JSON = [:]
    lhs.forEach { r[$0] = $1 }
    rhs.forEach { r[$0] = $1 }
    return r
}
