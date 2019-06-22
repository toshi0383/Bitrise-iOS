import RxTest

@testable import BitriseClient

func mockEnvironment(_ scheduler: TestScheduler) -> Environment {
    return Environment(schedulerFactory: MockScheduler(scheduler))
}
