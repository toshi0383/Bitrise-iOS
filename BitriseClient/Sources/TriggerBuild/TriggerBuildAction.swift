import Core
import Foundation
import RealmSwift

final class TriggerBuildAction {

    static let shared = TriggerBuildAction()

    func sendRebuildRequest(appSlug: AppSlug, _ build: AppsBuilds.Build) throws {

        let token = Config.shared.personalAccessToken!

        guard let url = URL(string: "https://api.bitrise.io/v0.1/apps/\(appSlug)/builds") else {
            return
        }

        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 5.0)

        req.setValue(token, forHTTPHeaderField: "Authorization")

        let body = RebuildTriggerRequest(build_params: build.original_build_params)

        req.httpBody = try! body.encode()
        req.httpMethod = "POST"

        URLSession.shared.dataTask(with: req).resume()
    }
}
