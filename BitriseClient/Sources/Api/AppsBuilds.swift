//
//  AppsBuilds.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/11.
//

import APIKit
import Foundation

struct AppsBuildsRequest: BitriseAPIRequest {

    typealias Response = JSON

    let path: String
    private let limit: Int

    var queryParameters: [String : Any]? {
        return ["limit": limit]
    }

    init(appSlug: String, limit: Int = 50) {
        self.path = "/apps/\(appSlug)/builds"
        self.limit = limit
    }
}

struct AppsBuilds {

    let data: [Build]

    struct Build: Hashable, AutoEquatable {

        typealias Slug = String

        let abort_reason: String?
        let branch: String?
        let build_number: Int
        let commit_hash: String?
        let commit_message: String?
        let commit_view_url: String?
        let environment_prepare_finished_at: Date?
        let finished_at: Date?
        let is_on_hold: Bool
        let original_build_params: [String: Any]
        let pull_request_id: Int?
        let pull_request_target_branch: String?
        let pull_request_view_url: String?
        let slug: Slug
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
        let triggered_at: Date
        let triggered_by: String?
        let triggered_workflow: String

        init(from json: JSON) {
            func decodeDate(from string: String?) -> Date? {
                guard let string = string else { return nil }
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                f.timeZone = TimeZone(secondsFromGMT: 0)
                return f.date(from: string)
            }

            self.abort_reason = json["abort_reason"] as? String
            self.branch = json["branch"] as? String
            self.commit_hash = json["commit_hash"] as? String
            self.commit_message = json["commit_message"] as? String
            self.commit_view_url = json["commit_view_url"] as? String
            self.environment_prepare_finished_at = decodeDate(from: json["environment_prepare_finished_at"] as? String)
            self.finished_at = decodeDate(from: json["finished_at"] as? String)
            self.pull_request_id = json["pull_request_id"] as? Int
            self.pull_request_target_branch = json["pull_request_target_branch"] as? String
            self.pull_request_view_url = json["pull_request_view_url"] as? String
            self.stack_config_type = json["stack_config_type"] as? String
            self.stack_identifier = json["stack_identifier"] as? String
            self.started_on_worker_at = decodeDate(from: json["started_on_worker_at"] as? String)
            self.tag = json["tag"] as? String
            self.triggered_by = json["triggered_by"] as? String
            self.build_number = json["build_number"] as! Int
            self.is_on_hold = json["is_on_hold"] as! Bool
            self.original_build_params = json["original_build_params"] as! JSON
            self.slug = json["slug"] as! Slug
            self.status = Status(rawValue: json["status"] as! Int)!
            self.status_text = json["status_text"] as! String
            self.triggered_at = decodeDate(from: json["triggered_at"] as? String)!
            self.triggered_workflow = json["triggered_workflow"] as! String
        }
    }

    let paging: Paging

    init(from json: JSON) {
        let dataJSONs = json["data"] as! [JSON]
        self.data = dataJSONs.map(Build.init)
        let pagingJSON = json["paging"] as! JSON
        self.paging = Paging(from: pagingJSON)
    }
}

extension AppsBuilds.Build {
    var hashValue: Int {
        return build_number
    }
}
