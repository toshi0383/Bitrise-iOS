//
//  BitriseYml.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/04/21.
//

import APIKit
import Foundation

struct YmlDataParser: DataParser {
    let contentType: String? = nil

    func parse(data: Data) throws -> Any {
        if let str = String(data: data, encoding: .utf8) {
            return BitriseYml(ymlPayload: str)
        }
        // TODO: throw more specific error than this
        throw APIError()
    }
}

struct GetBitriseYmlRequest: BitriseAPIRequest {

    typealias Response = BitriseYml

    let path: String
    var method: HTTPMethod {
        return .get
    }

    init(appSlug: String) {
        self.path = "apps/\(appSlug)/bitrise.yml"
    }

    let dataParser: DataParser = YmlDataParser()

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> BitriseYml {
        if let yml = object as? BitriseYml {
            return yml
        }
        throw APIError()
    }
}

// TODO: implement detailed structure of bitrise.yml
struct BitriseYml: Decodable {

    let ymlPayload: String
}
