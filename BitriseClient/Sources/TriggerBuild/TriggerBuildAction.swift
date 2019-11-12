import Core
import BitriseSwift
import Foundation
import RealmSwift

final class TriggerBuildAction {

    static let shared = TriggerBuildAction()

    func sendRebuildRequest(appSlug: AppSlug, _ buildParams: JSON) throws {

        let decoder = JSONDecoder()
        let data = try! JSONSerialization.data(withJSONObject: buildParams, options: [])
        let params = try! decoder.decode(V0BuildTriggerParamsBuildParams.self, from: data)

        let req = API.Builds.BuildTrigger.Request(appSlug: appSlug,
                                                  body: .init(buildParams: params, hookInfo: .init(type: "bitrise")))

        _ = APIClient.default.rx.makeRequest(req).subscribe()
    }
}
