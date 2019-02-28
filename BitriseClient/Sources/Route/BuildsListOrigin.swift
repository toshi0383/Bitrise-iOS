import Core

struct BuildsListOrigin: Equatable {
    let appSlug: AppSlug
    let appName: String
    let appsBuilds: AppsBuilds?

    init(appSlug: AppSlug, appName: String, appsBuilds: AppsBuilds? = nil) {
        self.appSlug = appSlug
        self.appName = appName
        self.appsBuilds = appsBuilds
    }
}

