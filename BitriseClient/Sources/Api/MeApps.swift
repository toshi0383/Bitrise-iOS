//
//  MeApps.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/11.
//

import APIKit
import Foundation

struct MeAppsRequest: BitriseAPIRequest {

    typealias Response = MeApps

    let path: String = "/me/apps"
}

struct MeApps: Decodable {
    let data: [App]

    struct App: Decodable {
        let is_disabled: Bool
        let project_type: String
        let provider: String
        let repo_owner: String
        let repo_slug: String
        let repo_url: String
        let slug: String
        let title: String
    }
}
