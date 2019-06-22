import RxTest

extension TestScheduler {
    func wait(_ seconds: Int) {
        advanceTo(clock + seconds)
    }
}
