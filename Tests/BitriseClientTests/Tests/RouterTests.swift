import RxSwift
import XCTest

@testable import BitriseClient
@testable import Core

final class RouterTests: XCTestCase {

    fileprivate var router: Router!
    fileprivate var dependency: Dependency!

}

extension RouterTests {

    override func setUp() {
        super.setUp()

        dependency = Dependency()

        router = Router(fetchMeApps: dependency.fetchMeApps,
                        fetchAppsBuilds: dependency.fetchAppsBuilds,
                        appsManager: dependency.appsManager,
                        config: dependency.config)
    }

    func testShowTutorial() {
        XCTAssertEqual(router.route.value, [.launch])
        router.showTutorial()
        XCTAssertEqual(router.route.value, [.tutorial])
    }

    func testShowAppsList() {
        XCTAssertEqual(router.route.value, [.launch])
        router.showAppsList()

        let origin = BuildsListOrigin(appSlug: "app-slug-0", appName: "", appsBuilds: dependency.appsBuilds)
        let ex: Router.Route = .buildsList(origin)
        XCTAssertEqual(router.route.value, router.route.value)
        XCTAssertEqual(router.route.value, [.appsList, ex])
    }

}

private final class Dependency {

    let appsManager: AppsManager = .init()
    let config: MockConfig = .init()
    let meApps = MeApps.mock()
    let appsBuilds = AppsBuilds.mock()

    func fetchMeApps(_ req: MeAppsRequest) -> Observable<MeApps> {
        return .just(self.meApps)
    }

    func fetchAppsBuilds(_ req: AppsBuildsRequest) -> Observable<AppsBuildsRequest.Response> {
        return .just(self.appsBuilds.json)
    }

    init() { }
}
