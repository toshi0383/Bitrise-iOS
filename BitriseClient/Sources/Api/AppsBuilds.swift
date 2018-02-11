//
//  AppsBuilds.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/11.
//

import APIKit
import Foundation

struct AppsBuildsRequest: BitriseAPIRequest {

    typealias Response = AppsBuilds

    let path: String

    init(appSlug: String) {
        self.path = "/apps/\(appSlug)/builds"
    }
}

struct AppsBuilds: Decodable {

    let data: [Build]

    struct Build: Decodable {
        let abort_reason: String?
        let branch: String?
        let build_number: Int
        let commit_hash: String?
        let commit_message: String?
        let commit_view_url: String?
        let environment_prepare_finished_at: Date?
        let finished_at: Date?
        let is_on_hold: Bool
        // TODO
        // let original_build_params: [String: AnyObject]
        let pull_request_id: Int
        let pull_request_target_branch: String?
        let pull_request_view_url: String?
        let slug: String
        let stack_config_type: String?
        let stack_identifier: String?
        let started_on_worker_at: Date?
        let status: Status

        enum Status: Int, Decodable {
            case notFinished = 0
            case finished = 1
            case error = 2
            case aborted = 3
        }

        let status_text: String
        let tag: String?
        let triggered_at: String
        let triggered_by: String?
        let triggered_workflow: String
    }

    let paging: Paging
}
