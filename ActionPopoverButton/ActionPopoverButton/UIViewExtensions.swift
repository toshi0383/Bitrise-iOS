//
//  UIViewExtensions.swift
//  ActionPopoverButton
//
//  Created by Toshihiro Suzuki on 2018/02/10.
//

import UIKit


public struct HitTestHooking<Base> {
    /// Base object to extend.
    public let base: Base

    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
    public init(_ base: Base) {
        self.base = base
    }
}

/// A type that has reactive extensions.
public protocol HitTestHookingCompatible {
    /// Extended type
    associatedtype CompatibleType

    /// HitTestHooking extensions.
    static var hth: HitTestHooking<CompatibleType>.Type { get set }

    /// HitTestHooking extensions.
    var hth: HitTestHooking<CompatibleType> { get set }
}

extension HitTestHookingCompatible {
    /// HitTestHooking extensions.
    public static var hth: HitTestHooking<Self>.Type {
        get {
            return HitTestHooking<Self>.self
        }
        set {
            // this enables using HitTestHooking to "mutate" base type
        }
    }

    /// HitTestHooking extensions.
    public var hth: HitTestHooking<Self> {
        get {
            return HitTestHooking(self)
        }
        set {
            // this enables using HitTestHooking to "mutate" base object
        }
    }
}

/// Extend UIView with `hth` proxy.
extension UIView: HitTestHookingCompatible { }

private enum AssociatedKey {
    static var target = "target"
}

extension HitTestHooking where Base: UIView {

    /// TODO: Support multiple children
    public var targetChildToHitTest: UIView? {
        set {
            objc_setAssociatedObject(base, &AssociatedKey.target, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(base, &AssociatedKey.target) as? UIView
        }
    }

    public static func exchangeMethods() {
        let instance = UIView()

        // hitTest
        do {
            let method: Method = class_getInstanceMethod(object_getClass(instance), #selector(UIView.hitTest(_:with:)))!
            let swizzledMethod: Method = class_getInstanceMethod(object_getClass(instance), #selector(UIView.apb_hitTest(_:with:)))!
            method_exchangeImplementations(method, swizzledMethod)
        }
    }
}

extension UIView {

    /// By default non-root UIViews does not respond for outside bounds touches.
    /// Method performs hitTest against targetChildToHitTest view to respond to outside touch.
    @objc func apb_hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = hth.targetChildToHitTest {
            if let hit = view.hitTest(convert(point, to: view), with: event) {
                return hit
            }
        }

        // IMPORTANT: Perform hitTest for myself at last.
        return self.apb_hitTest(point, with: event)
    }
}
