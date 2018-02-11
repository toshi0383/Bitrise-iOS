//
//  BitriseAPIRequest.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/11.
//

import APIKit
import Foundation

protocol BitriseAPIRequest: Request { }

extension BitriseAPIRequest where Response: Decodable {
    var baseURL: URL {
        return URL(string: "https://api.bitrise.io/v0.1")!
    }

    var method: HTTPMethod {
        return .get
    }

    var headerFields: [String : String] {
        var fields: [String: String] = [:]

        if let token = Config.personalAccessToken {
            fields["Authorization"] = "token \(token)"
        }

        return fields
    }

    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        #if DEBUG
            print(urlRequest)
            if let headers = urlRequest.allHTTPHeaderFields {
                print(headers)
            }
        #endif
        return urlRequest
    }

    var dataParser: DataParser {
        return _DataParser()
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let data = object as? Data {
            #if DEBUG
                if let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            #endif
            return try decoder.decode(Response.self, from: data)
        }

        throw ResponseError.unexpectedObject(object)
    }
}

private class _DataParser: DataParser {
    var contentType: String? = nil

    func parse(data: Data) throws -> Any {
        return data
    }
}

struct Paging: Decodable {
    let page_item_limit: Int
    let total_item_count: Int
    let next: String?
}
