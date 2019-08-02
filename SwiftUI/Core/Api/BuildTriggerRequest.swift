import Foundation
import APIKit

public struct BuildParams: Codable {
    var branch: String?
    var workflow_id: String?
    var tag: String?
    var commit_hash: String?
    var commit_message: String?
}

extension BuildParams {
    init(json: JSON) {
        self.branch = json["branch"] as? String
        self.tag = json["tag"] as? String
        self.workflow_id = json["workflow_id"] as? String
        self.commit_hash = json["commit_hash"] as? String
        self.commit_message = json["commit_message"] as? String
    }
}

public struct BuildTriggerResponse: Decodable {
    let status, message, slug, service: String
    let build_slug: String
    let build_number: Int
    let build_url: String
    let triggered_workflow: String
}

/// `build_params` is params from previous build, so it could be typed, but isn't on purpose.
/// This way we can ignore potential future breaking changes in `bulid_params` fields.
/// That's why we can't use Encodable here.
public struct BuildTriggerRequest: BitriseAPIRequest {
    public var path: String {
        return "/apps/\(appSlug)/builds"
    }

    public var method: HTTPMethod = .post

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
