import APIKit
import Foundation

public struct AppsBuildsAbortRequest: BitriseAPIRequest {
    public typealias Response = AppsBuildsAbort

    public let path: String

    public let method: HTTPMethod = .post

    public init(appSlug: String, buildSlug: String) {
        self.path = "/apps/\(appSlug)/builds/\(buildSlug)/abort"
    }

    public var bodyParameters: BodyParameters? {
        return JSONBodyParameters(JSONObject: [:])
    }
}

public struct AppsBuildsAbort: Decodable {
    public let status: String?
    public let error_msg: String?
}
