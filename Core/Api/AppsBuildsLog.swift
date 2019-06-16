import os.signpost
import APIKit
import Foundation
import DifferenceKit

public struct AppsBuildsLogRequest: BitriseAPIRequest {

    public typealias Response = AppsBuildsLog

    public let path: String

    public let method: HTTPMethod = .get

    public let spid: Any? = {
        if #available(iOS 12.0, *) {
            return OSSignpostID(log: .network)
        } else {
            return nil
        }
    }()

    public init(appSlug: String, buildSlug: String) {
        self.path = "/apps/\(appSlug)/builds/\(buildSlug)/log"
    }

    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            let i = Int(str)!
            return Date(timeIntervalSince1970: TimeInterval(i))
        }

        if let data = object as? Data {
            return try decoder.decode(Response.self, from: data)
        }

        throw ResponseError.unexpectedObject(object)
    }
}

public struct AppsBuildsLog: Decodable, Equatable {

    public let expiring_raw_log_url: String?
    public let generated_log_chunks_num: Int?
    public let is_archived: Bool
    public let log_chunks: [Chunk]
    public let timestamp: Date?

}

extension AppsBuildsLog {

    public struct Chunk: Decodable, Equatable, Hashable, Differentiable {

        public let chunk: String
        public let position: Int

        public init(position: Int, chunk: String) {
            self.position = position
            self.chunk = chunk
        }

        public func hash(_ into: inout Hasher) {
            into.combine("\(position)\(chunk)")
            _ = into.finalize()
        }

    }

}
