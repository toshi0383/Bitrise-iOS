//
//  SingleBuildRequest.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/03/08.
//

import APIKit
import Foundation

struct SingleBuildRequest: BitriseAPIRequest {

    typealias Response = JSON

    let path: String

    init(appSlug: String, buildSlug: AppsBuilds.Build.Slug) {
        self.path = "/apps/\(appSlug)/builds/\(buildSlug)"
    }
}

struct SingleBuild {
    let data: AppsBuilds.Build

    init(from json: JSON) {
        self.data = AppsBuilds.Build(from: json["data"] as! JSON)
    }
}
