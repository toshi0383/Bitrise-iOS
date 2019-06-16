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

extension ObservableType where Element: OptionalType {

    func filterNil() -> Observable<Element.Wrapped> {
        return flatMap { item -> Observable<Element.Wrapped> in
            if let value = item.value {
                return Observable.just(value)
            } else {
                return Observable.empty()
            }
        }
    }
}

extension ObservableType where Element: Emptyable {
    func filterEmpty() -> Observable<Element> {
        return filter { !$0.isEmpty }
    }
}

extension BehaviorRelay {
    var changed: Observable<Element> {
        return asObservable().skip(1)
    }
}

func void<E>(_ x: E) {
    return Void()
}

extension ObservableType {
    static func justOrEmpty<E>(_ x: E?) -> Observable<E> {
        if let x = x {
            return .just(x)
        } else {
            return .empty()
        }
    }
}
