import APIKit
import Foundation

public protocol BitriseAPIRequest: Request {
    var personalAccessToken: String? { get }
}

extension BitriseAPIRequest {

    public var personalAccessToken: String? {
        return APIConfig.getToken()
    }

    public var baseURL: URL {
        return URL(string: "https://api.bitrise.io/v0.1")!
    }

    public var method: HTTPMethod {
        return .get
    }

    public var headerFields: [String : String] {
        var fields: [String: String] = [:]

        if let token = personalAccessToken {
            fields["Authorization"] = "token \(token)"
        }

        return fields
    }

    public func intercept(urlRequest: URLRequest) throws -> URLRequest {
        #if DEBUG
//            print(urlRequest)
            if let headers = urlRequest.allHTTPHeaderFields {
//                print(headers)
            }
        #endif
        return urlRequest
    }
}

extension BitriseAPIRequest where Response: Decodable {
    public var dataParser: DataParser {
        return _DataParser()
    }

    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let data = object as? Data {
            return try decoder.decode(Response.self, from: data)
        }

        throw ResponseError.unexpectedObject(object)
    }
}

extension BitriseAPIRequest where Response == JSON {
    public var dataParser: DataParser {
        return _DataParser()
    }

    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let data = object as? Data,
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
            return json
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

public struct Paging: Decodable, Equatable {
    public let page_item_limit: Int
    public let total_item_count: Int
    public let next: String?
}

extension Paging {
    init(from json: JSON) {
        self.next = json["next"] as? String
        self.page_item_limit = json["page_item_limit"] as! Int
        self.total_item_count = json["total_item_count"] as! Int
    }
}
