import os.signpost
import APIKit
import Foundation

public protocol BitriseAPIRequest: Request {
    var spid: Any? { get }
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
        if #available(iOS 12.0, *) {
            if let spid = self.spid as? OSSignpostID {
                os_signpost(.begin, log: .network, name: "BitriseAPIRequest", signpostID: spid, "%@", self.path)
            }
        }

        return urlRequest
    }

    public func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        if #available(iOS 12.0, *) {
            if let data = object as? Data {
                if let spid = self.spid as? OSSignpostID {
                    os_signpost(.end, log: .network, name: "BitriseAPIRequest", signpostID: spid, "%{iec-bytes}d", data.count)
                }
            }
        }

        // Copy of the default implementation in APIKit
        guard 200..<300 ~= urlResponse.statusCode else {
            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }

        return object
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
