import RxCocoa
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

        let ex: [Router.Route] = [.appsList, .buildsList(dependency.meApps.data[0])]
        XCTAssertEqual(router.route.value, ex)
    }

}

private final class Dependency {

    let appsManager: AppsManager = .init()
    let config: MockConfig = .init()
    let meApps = MeApps.mock()

    func fetchMeApps(_ req: MeAppsRequest) -> Observable<MeApps> {
        return .just(self.meApps)
    }

    init() { }
}
