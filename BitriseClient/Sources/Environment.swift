import RxSwift

final class Environment {
    static let shared = Environment(schedulerFactory: Environment.Scheduler())

    let schedulerFactory: SchedulerFactory

    init(schedulerFactory: SchedulerFactory) {
        self.schedulerFactory = schedulerFactory
    }
}

protocol SchedulerFactory {
    var concurrentMain: SchedulerType { get }
}

extension Environment {
    final class Scheduler: SchedulerFactory {
        let concurrentMain: SchedulerType = ConcurrentMainScheduler.instance
    }
}
