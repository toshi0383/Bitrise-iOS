import os.signpost
import APIKit
import Foundation

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
}

public struct AppsBuildsLog: Decodable {

    public let expiring_raw_log_url: String
    public let generated_log_chunks_num: Int
    public let is_archived: Bool
    public let log_chunks: [Chunk]
    public let timestamp: Date?

}

extension AppsBuildsLog {

  public struct Chunk: Decodable {

      public let chunk: String
      public let position: Int

  }

}
