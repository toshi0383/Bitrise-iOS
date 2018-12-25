import RxCocoa
import RxSwift

protocol Emptyable {
    var isEmpty: Bool { get }
}

extension Dictionary: Emptyable {}
extension Array: Emptyable {}
extension String: Emptyable {}

protocol OptionalType {
    associatedtype Wrapped

    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    var value: Wrapped? { return self }
}

extension ObservableType where E: OptionalType {

    func filterNil() -> Observable<E.Wrapped> {
        return flatMap { item -> Observable<E.Wrapped> in
            if let value = item.value {
                return Observable.just(value)
            } else {
                return Observable.empty()
            }
        }
    }
}

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
