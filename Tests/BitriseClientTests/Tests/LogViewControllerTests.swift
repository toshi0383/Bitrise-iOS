import Foundation
import RxSwift
import RxTest
import XCTest

import Core
@testable import BitriseClient

final class LogViewControllerTests: XCTestCase {

    func test() {
        let scheduler = TestScheduler(initialClock: 0)
        let env = mockEnvironment(scheduler)
        let textView = UITextView()

        let retain = LogViewController(
            appSlug: "app00",
            build: MockBuildForLog(),
            textView: textView,
            scheduler: env,
            sendBuildLogRequest: { (req: AppsBuildsLogRequest) -> Observable<AppsBuildsLog> in

                                let res = AppsBuildsLog(
                                    expiring_raw_log_url: nil,
                                    generated_log_chunks_num: nil,
                                    is_archived: false,
                                    log_chunks: [
                                        AppsBuildsLog.Chunk(position: 2, chunk: "chunk2"),
                                    ],
                                    timestamp: nil
                                )

                                return .just(res)
        })

        scheduler.wait(1)

        XCTAssertEqual(textView.text, "chunk2")
    }
}

struct MockBuildForLog: BuildForLog {
    let build_number: Int = 0
    let status: AppsBuilds.Build.Status = .notFinished
    let slug: String = "build00"
}
