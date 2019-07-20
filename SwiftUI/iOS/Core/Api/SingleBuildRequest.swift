import os.signpost
import APIKit
import Foundation

public struct SingleBuildRequest: BitriseAPIRequest {

    public typealias Response = JSON

    public let path: String

    public let spid: Any? = {
        if #available(iOS 12.0, *) {
            return OSSignpostID(log: .network)
        } else {
            return nil
        }
    }()

    public init(appSlug: String, buildSlug: AppsBuilds.Build.Slug) {
        self.path = "/apps/\(appSlug)/builds/\(buildSlug)"
    }
}

public struct SingleBuild {

    public let data: AppsBuilds.Build

    public init(from json: JSON) {
        self.data = AppsBuilds.Build(from: json["data"] as! JSON)
    }
}
