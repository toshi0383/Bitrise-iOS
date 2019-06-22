import RxSwift
import RxTest

@testable import BitriseClient

final class MockScheduler: SchedulerFactory {

    let concurrentMain: SchedulerType

    init(_ scheduler: TestScheduler = .init(initialClock: 0)) {
        self.concurrentMain = scheduler
    }
}
