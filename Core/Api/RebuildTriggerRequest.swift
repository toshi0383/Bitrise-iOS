import Foundation

/// `build_params` is params from previous build, so it could be typed, but isn't on purpose.
/// This way we can ignore potential future breaking changes in `bulid_params` fields.
/// That's why we can't use Encodable here.
///
/// TODO: Maybe try https://github.com/noppefoxwolf/Bitrise-Swift
public struct RebuildTriggerRequest {

    public let hook_info: HookInfo
    public let build_params: JSON
    public let triggered_by: String

    public init(build_params: JSON,
                triggered_by: String = "BitriseClient iOS App",
                hook_info: HookInfo = .init()) {
        self.hook_info = hook_info
        self.build_params = build_params
        self.triggered_by = triggered_by
    }

    public func encode() throws -> Data {
        let json: [String: Any] = [
            "hook_info": hook_info.json(),
            "build_params": build_params,
            "triggered_by": triggered_by
        ]
        return try JSONSerialization.data(withJSONObject: json, options: [])
    }
}

extension RebuildTriggerRequest {

    public struct HookInfo {
        public let type: String

        public init(type: String = "bitrise") {
            self.type = type
        }

        public func json() -> [String: Any] {
            return ["type": type]
        }
    }
}
