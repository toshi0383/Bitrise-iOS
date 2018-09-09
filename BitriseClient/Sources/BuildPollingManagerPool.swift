final class BuildPollingManagerPool {
    static let shared = BuildPollingManagerPool()

    private var managers: [BuildPollingManager] = []

    func manager(for appSlug: String) -> BuildPollingManager {
        if let manager = managers.first(where: { $0.appSlug == appSlug }) {
            return manager
        } else {
            let manager = BuildPollingManager(appSlug: appSlug)
            managers.append(manager)
            return manager
        }
    }
}
