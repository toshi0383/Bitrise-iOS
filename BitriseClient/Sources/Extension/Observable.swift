import RxCocoa
import RxSwift

protocol Emptyable {
    var isEmpty: Bool { get }
}

extension Dictionary: Emptyable {}
extension Array: Emptyable {}
extension String: Emptyable {}

extension ObservableType where E: Emptyable {
    func filterEmpty() -> Observable<E> {
        return filter { !$0.isEmpty }
    }
}

extension BehaviorRelay {
    var changed: Observable<E> {
        return asObservable().skip(1)
    }
}

func void<E>(_ x: E) {
    return Void()
}
