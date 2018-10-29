import os.signpost
import APIKit
import Foundation

public struct MeAppsRequest: BitriseAPIRequest {

    public typealias Response = MeApps

    public let path: String = "/me/apps"

    public let spid: Any? = {
        if #available(iOS 12.0, *) {
            return OSSignpostID(log: .network)
        } else {
            return nil
        }
    }()

    public init() { }
}

public struct MeApps: Decodable, Equatable {
    public let data: [App]

    public struct App: Decodable, Equatable {
        public let is_disabled: Bool
        public let project_type: String
        public let provider: String
        public let repo_owner: String
        public let repo_slug: String
        public let repo_url: String
        public let slug: String
        public let title: String

        public init(is_disabled: Bool,
                    project_type: String,
                    provider: String,
                    repo_owner: String,
                    repo_slug: String,
                    repo_url: String,
                    slug: String,
                    title: String) {
            self.is_disabled = is_disabled
            self.project_type = project_type
            self.provider = provider
            self.repo_owner = repo_owner
            self.repo_slug = repo_slug
            self.repo_url = repo_url
            self.slug = slug
            self.title = title
        }
    }

    public init(data: [App], paging: Paging) {
        self.data = data
        self.paging = paging
    }

    public let paging: Paging
}
