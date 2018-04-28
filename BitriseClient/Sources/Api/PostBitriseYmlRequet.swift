//
//  PostBitriseYmlRequet.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/04/28.
//

import APIKit
import Foundation

struct PostBitriseYmlRequest: BitriseAPIRequest {

    // TODO: Response is in JSON
    typealias Response = BitriseYml

    let path: String
    let ymlString: String
    var method: HTTPMethod {
        return .post
    }

    init(appSlug: String, ymlString: String) {
        self.path = "apps/\(appSlug)/bitrise.yml"
        self.ymlString = ymlString
    }

    var bodyParameters: BodyParameters? {
        return JSONBodyParameters(JSONObject:
            ["app_config_datastore_yaml": ymlString])
    }

    let dataParser: DataParser = BitriseYmlDataParser()

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> BitriseYml {
        if let yml = object as? BitriseYml {
            return yml
        }
        throw APIError()
    }
}
