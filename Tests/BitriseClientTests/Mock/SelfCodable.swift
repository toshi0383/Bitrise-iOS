@testable import Core
import Foundation

extension AppsBuilds {

    // testable
    var json: JSON {
        let pagingJSON: JSON = [
            "next": paging.next ?? NSNull(),
            "page_item_limit": paging.page_item_limit,
            "total_item_count": paging.total_item_count,
            ]

        return [
            "data": data.map { $0.json },
            "paging": pagingJSON,
        ]
    }
}

extension AppsBuilds.Build {

    // testable
    fileprivate var json: JSON {
        func encodeDate(_ date: Date?) -> Any {
            if let date = date {
                return dateFormatter.string(from: date)
            } else {
                return NSNull()
            }
        }

        return [
            "abort_reason": abort_reason ?? NSNull(),
            "branch": branch ?? NSNull(),
            "build_number": build_number,
            "commit_hash": commit_hash ?? NSNull(),
            "commit_message": commit_message ?? NSNull(),
            "commit_view_url": commit_view_url ?? NSNull(),
            "environment_prepare_finished_at": encodeDate(environment_prepare_finished_at),
            "finished_at": encodeDate(finished_at),
            "is_on_hold": is_on_hold,
            "original_build_params": original_build_params,
            "pull_request_id": pull_request_id ?? NSNull(),
            "pull_request_target_branch": pull_request_target_branch ?? NSNull(),
            "pull_request_view_url": pull_request_view_url ?? NSNull(),
            "slug": slug,
            "stack_config_type": stack_config_type ?? NSNull(),
            "stack_identifier": stack_identifier ?? NSNull(),
            "started_on_worker_at": encodeDate(started_on_worker_at),
            "status": status.rawValue,
            "status_text": status_text,
            "tag": tag ?? NSNull(),
            "triggered_at": encodeDate(triggered_at),
            "triggered_by": triggered_by ?? NSNull(),
            "triggered_workflow": triggered_workflow,
        ]
    }
}
