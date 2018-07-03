//
//  TriggerBuildAction.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/06/10.
//

import Foundation
import RealmSwift

final class TriggerBuildAction {

    static let shared = TriggerBuildAction()

    func sendRebuildRequest(appSlug: AppSlug, _ build: AppsBuilds.Build) {

        let realm = Realm.getRealm()
        guard let token = realm.object(ofType: BuildTriggerRealm.self, forPrimaryKey: appSlug)?.apiToken else {
            return
        }

        guard let url = URL(string: "https://app.bitrise.io/app/\(appSlug)/build/start.json") else {
            return
        }

        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 5.0)

        let body = BuildTriggerRequest(hook_info: .init(api_token: token),
                                       build_params: build.original_build_params)

        req.httpBody = try! body.encode()
        req.httpMethod = "POST"

        URLSession.shared.dataTask(with: req).resume()
    }
}
