import APIKit
import Foundation

public struct BitriseYmlDataParser: DataParser {
    public let contentType: String? = nil

    public func parse(data: Data) throws -> Any {
        if let str = String(data: data, encoding: .utf8) {
            return BitriseYml(ymlPayload: str)
        }
        // TODO: throw more specific error than this
        throw APIError()
    }
}

public struct GetBitriseYmlRequest: BitriseAPIRequest {

    public typealias Response = BitriseYml

    public let path: String
    public var method: HTTPMethod {
        return .get
    }

    public init(appSlug: String) {
        self.path = "apps/\(appSlug)/bitrise.yml"
    }

    public let dataParser: DataParser = BitriseYmlDataParser()

    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> BitriseYml {
        if let yml = object as? BitriseYml {
            return yml
        }
        throw APIError()
    }
}

// TODO: implement detailed structure of bitrise.yml
public struct BitriseYml: Decodable {

    public let ymlPayload: String
}
