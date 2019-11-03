import Foundation
import APIKit

public struct BuildParams: Codable {
    public var branch: String?
    public var workflow_id: String?
    public var tag: String?
    public var commit_hash: String?
    public var commit_message: String?
//    public var environments: [BuildTriggerEnvironment]

    public init(branch: String? = nil, tag: String? = nil, commit_hash: String? = nil, workflow_id: String? = nil, environments: [BuildTriggerEnvironment] = []) {
        self.branch = branch
        self.tag = tag
        self.commit_hash = commit_hash
        self.workflow_id = workflow_id
//        self.environments = environments
    }
}

public struct BuildTriggerResponse: Decodable {
    public let status, message, slug, service: String
    public let build_slug: String
    public let build_number: Int
    public let build_url: String
    public let triggered_workflow: String
}

public struct BuildTriggerRequest: BitriseAPIRequest {
    public var path: String {
        return "/apps/\(appSlug)/builds"
    }

    public let method: HTTPMethod = .post

    public var spid: Any? = nil

    public typealias Response = BuildTriggerResponse

    public var bodyParameters: BodyParameters? {
        let data: Data = try! JSONEncoder().encode(body)
        let o = try! JSONSerialization.jsonObject(with: data, options: [])
        return JSONBodyParameters(JSONObject: o)
    }

    private let appSlug: String
    private let body: BuildTriggerRequest.Body

    public init(appSlug: String,
                hook_info: Body.HookInfo = .init(),
                build_params: BuildParams,
                triggered_by: String = "BitriseClient iOS App") {
        self.appSlug = appSlug
        self.body = Body(hook_info: hook_info, build_params: build_params, triggered_by: triggered_by)
    }

    public init(appSlug: String,
                branch: String,
                workflow_id: String?,
                hook_info: Body.HookInfo = .init()) {

        self.init(appSlug: appSlug,
                  build_params: BuildParams(branch: branch, workflow_id: workflow_id))
    }
}

extension BuildTriggerRequest {

    public struct Body: Encodable {
        public let hook_info: HookInfo
        public let build_params: BuildParams
        public let triggered_by: String

        public struct HookInfo: Encodable {
            public let type: String

            public init(type: String = "bitrise") {
                self.type = type
            }

        }
    }
}
