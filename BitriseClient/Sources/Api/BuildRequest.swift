//
//  BuildRequest.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/03/08.
//

import APIKit
import Foundation

struct BuildRequest: BitriseAPIRequest {

    typealias Response = Build

    let path: String

    init(appSlug: String, buildSlug: AppsBuilds.Build.Slug) {
        self.path = "/apps/\(appSlug)/builds/\(buildSlug)"
    }
}

struct Build: Decodable {
    let data: AppsBuilds.Build
}
