//
//  BitriseYml.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/04/21.
//

import APIKit
import Foundation

struct GetBitriseYmlRequest: BitriseAPIRequest {

    typealias Response = BitriseYml

    let path: String
    var method: HTTPMethod {
        return .get
    }

    init(appSlug: String) {
        self.path = "apps/\(appSlug)/bitrise.yml"
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> BitriseYml {
        if let data = object as? Data,
            let str = String(data: data, encoding: .utf8) {
            return BitriseYml(ymlPayload: str)
        }
        throw APIError()
    }
}

struct BitriseYml {

    let ymlPayload: String
}
