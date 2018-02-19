import UIKit

protocol Storyboardable: class, NSObjectProtocol {
    associatedtype Instance

    /// 初期化時の依存注入のためのデータ型。
    /// - Note: デフォルトは`Void`にしない（unsafeのままになるため）
    associatedtype Dependency // = Void

    static func makeFromStoryboard(_ dependency: Dependency) -> Instance
    static var storyboard: UIStoryboard { get }
    static var storyboardName: String { get }
    static var identifier: String { get }
}

// MARK: Default implementation

private extension NSObjectProtocol {
    static var className: String {
        return String(describing: self)
    }
}

extension Storyboardable {
    static var storyboardName: String {
        return className
    }

    static var identifier: String {
        return className
    }

    static var storyboard: UIStoryboard {
        return UIStoryboard(name: storyboardName, bundle: nil)
    }
}

extension Storyboardable where Dependency == Void {
    static func makeFromStoryboard(_ dependency: Dependency) -> Self {
        return unsafeMakeFromStoryboard()
    }

    static func makeFromStoryboard() -> Self {
        return makeFromStoryboard(())
    }
}

// MARK: Helpers

extension Storyboardable {
    /// 依存性注入前のunsafe instantiate。
    /// `Dependency != Void` の場合、`static func makeFromStoryboard(_:)`を定義の上、このメソッドを起点に依存をセットする。
    static func unsafeMakeFromStoryboard() -> Self {
        return storyboard.instantiateViewController(withIdentifier: identifier) as! Self
    }
}
