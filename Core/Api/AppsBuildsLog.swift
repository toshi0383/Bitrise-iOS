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

    public var expiring_raw_log_url: String?
    public var generated_log_chunks_num: Int?
    public var is_archived: Bool
    public var log_chunks: [Chunk]
    public var timestamp: Date?

    public init(expiring_raw_log_url: String?,
                generated_log_chunks_num: Int?,
                is_archived: Bool,
                log_chunks: [Chunk],
                timestamp: Date?
        ) {
        self.expiring_raw_log_url = expiring_raw_log_url
        self.generated_log_chunks_num = generated_log_chunks_num
        self.is_archived = is_archived
        self.log_chunks = log_chunks
        self.timestamp = timestamp
    }

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
