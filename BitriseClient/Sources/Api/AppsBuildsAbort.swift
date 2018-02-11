//
//  AppsBuildsAbort.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/12.
//

import APIKit
import Foundation

struct AppsBuildsAbortRequest: BitriseAPIRequest {
    typealias Response = AppsBuildsAbort

    let path: String

    let method: HTTPMethod = .post

    init(appSlug: String, buildSlug: String) {
        self.path = "/apps/\(appSlug)/builds/\(buildSlug)/abort"
    }
}

struct AppsBuildsAbort: Decodable {
    let status: String?
    let error_msg: String?
}
