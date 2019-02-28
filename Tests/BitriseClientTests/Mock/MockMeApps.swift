@testable import Core

extension MeApps {
    static func mock() -> MeApps {

        let data: [MeApps.App] = [
            MeApps.App(is_disabled: false,
                       project_type: nil,
                       provider: "",
                       repo_owner: "",
                       repo_slug: "",
                       repo_url: "",
                       slug: "",
                       title: "app-name-0")
        ]

        let paging = Paging(page_item_limit: 25,
                            total_item_count: 3,
                            next: nil)

        return MeApps(data: data, paging: paging)
    }
}
