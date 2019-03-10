@testable import Core

extension AppsBuilds {
    static func mock() -> AppsBuilds {

        let data: [AppsBuilds.Build] = [
            AppsBuilds.Build.init(abort_reason: nil,
                                  branch: nil,
                                  build_number: 1,
                                  commit_hash: nil,
                                  commit_message: nil,
                                  commit_view_url: nil,
                                  environment_prepare_finished_at: nil,
                                  finished_at: nil,
                                  is_on_hold: false,
                                  original_build_params: [:],
                                  pull_request_id: nil,
                                  pull_request_target_branch: nil,
                                  pull_request_view_url: nil,
                                  slug: "build-slug-0",
                                  stack_config_type: nil,
                                  stack_identifier: nil,
                                  started_on_worker_at: nil,
                                  status: .finished,
                                  status_text: "finished",
                                  tag: nil,
                                  triggered_at: Date(),
                                  triggered_by: nil,
                                  triggered_workflow: "test")
        ]

        let paging = Paging(page_item_limit: 25,
                            total_item_count: 3,
                            next: nil)

        return AppsBuilds(data: data, paging: paging)
    }
}
