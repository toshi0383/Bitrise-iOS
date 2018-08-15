//
//  PostBitriseYmlRequet.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/04/28.
//

import APIKit
import Foundation

public struct PostBitriseYmlRequest: BitriseAPIRequest {

    // TODO: Response is in JSON
    public typealias Response = BitriseYml

    public let path: String
    public let ymlString: String
    public var method: HTTPMethod {
        return .post
    }

    public init(appSlug: String, ymlString: String) {
        self.path = "apps/\(appSlug)/bitrise.yml"
        self.ymlString = ymlString
    }

    public var bodyParameters: BodyParameters? {
        return JSONBodyParameters(JSONObject:
            ["app_config_datastore_yaml": ymlString])
    }

    public let dataParser: DataParser = BitriseYmlDataParser()

    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> BitriseYml {
        if let yml = object as? BitriseYml {
            return yml
        }
        throw APIError()
    }
}
