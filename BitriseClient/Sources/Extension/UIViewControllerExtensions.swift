import RxSwift
import UIKit

/// Work In Progress. Fixme ;)
/// - Presenting Modal does not cause any lifecycle event for parent viewController.
///   Need to implement manual lifecycle management for that purpose.
///
/// - `viewWillTransition` and other lifecycles are still missing.
final class ViewControllerLifecycle {
    let viewDidLoad: Observable<Void>
    let viewWillAppear: Observable<Bool>
    let viewDidAppear: Observable<Bool>
    let viewWillDisappear: Observable<Bool>
    let viewDidDisappear: Observable<Bool>
    let viewWillLayoutSubviews: Observable<Void>
    let viewDidLayoutSubviews: Observable<Void>

    init(viewDidLoad: Observable<Void> = .empty(),
         viewWillAppear: Observable<Bool> = .empty(),
         viewDidAppear: Observable<Bool> = .empty(),
         viewWillDisappear: Observable<Bool> = .empty(),
         viewDidDisappear: Observable<Bool> = .empty(),
         viewWillLayoutSubviews: Observable<Void> = .empty(),
         viewDidLayoutSubviews: Observable<Void> = .empty()) {

        self.viewDidLoad = viewDidLoad
        self.viewWillAppear = viewWillAppear
        self.viewDidAppear = viewDidAppear
        self.viewWillDisappear = viewWillDisappear
        self.viewDidDisappear = viewDidDisappear
        self.viewWillLayoutSubviews = viewWillLayoutSubviews
        self.viewDidLayoutSubviews = viewDidLayoutSubviews
    }
}

extension UIViewController {

    func alert(_ message: String, completion: ((UIAlertAction) -> ())? = nil) {
        DispatchQueue.main.async { [weak self] in
            let vc = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
            self?.present(vc, animated: true, completion: nil)
        }
    }

    func alert(_ message: String, voidCompletion: (() -> ())?) {
        DispatchQueue.main.async { [weak self] in
            let vc = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in voidCompletion?() }))
            self?.present(vc, animated: true, completion: nil)
        }
    }

    func prompt(_ message: String, handler: (@escaping (Bool) -> ())) {
        DispatchQueue.main.async { [weak self] in
            let vc = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in handler(true) }))
            vc.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in handler(false) }))
            self?.present(vc, animated: true, completion: nil)
        }
    }

    // MARK: Lifecycle using RxSwift

    var lifecycle: ViewControllerLifecycle {
        return ViewControllerLifecycle(viewDidLoad: rx.viewDidLoad,
                                       viewWillAppear: rx.viewWillAppear,
                                       viewDidAppear: rx.viewDidAppear,
                                       viewWillDisappear: rx.viewWillDisappear,
                                       viewDidDisappear: rx.viewDidDisappear,
                                       viewWillLayoutSubviews: rx.viewWillLayoutSubviews,
                                       viewDidLayoutSubviews: rx.viewDidLayoutSubviews)
    }
}

// - MARK: Reactive extensions

/// - SeeAlso: [devxoul/RxViewController](https://github.com/devxoul/RxViewController)
extension Reactive where Base: UIViewController {
    var viewDidLoad: Observable<Void> {
        return base.rx.methodInvoked(#selector(Base.viewDidLoad)).map(void)
    }

    var viewWillAppear: Observable<Bool> {
        return base.rx.methodInvoked(#selector(Base.viewWillAppear))
            .map { $0.first as? Bool ?? false }
    }

    var viewDidAppear: Observable<Bool> {
        return base.rx.methodInvoked(#selector(Base.viewDidAppear))
            .map { $0.first as? Bool ?? false }
    }

    var viewWillDisappear: Observable<Bool> {
        return base.rx.methodInvoked(#selector(Base.viewWillDisappear))
            .map { $0.first as? Bool ?? false }
    }

    var viewDidDisappear: Observable<Bool> {
        return base.rx.methodInvoked(#selector(Base.viewDidDisappear))
            .map { $0.first as? Bool ?? false }
    }

    var viewWillLayoutSubviews: Observable<Void> {
        return base.rx.methodInvoked(#selector(Base.viewWillLayoutSubviews)).map(void)
    }

    var viewDidLayoutSubviews: Observable<Void> {
        return base.rx.methodInvoked(#selector(Base.viewDidLayoutSubviews)).map(void)
    }

    var willMoveToParentViewController: Observable<UIViewController?> {
        return base.rx.methodInvoked(#selector(Base.willMove)).map { $0.first as? UIViewController }
    }

    var didMoveToParentViewController: Observable<UIViewController?> {
        return base.rx.methodInvoked(#selector(Base.didMove)).map { $0.first as? UIViewController }
    }

    var didReceiveMemoryWarning: Observable<Void> {
        return base.rx.methodInvoked(#selector(Base.didReceiveMemoryWarning)).map(void)
    }

    var viewWillTransition: Observable<(CGSize, UIViewControllerTransitionCoordinator?)> {
        return base.rx.methodInvoked(#selector(Base.viewWillTransition))
            .map { object in
                let size = object.first as? CGSize ?? .zero
                let coordinator = object.count == 2 ? object[1] as? UIViewControllerTransitionCoordinator : nil
                return (size, coordinator)
            }
    }

    var willTransition: Observable<(UITraitCollection?, UIViewControllerTransitionCoordinator?)> {
        return base.rx.methodInvoked(#selector(Base.willTransition))
            .map { object in
                let traitCollection = object.first as? UITraitCollection
                let coordinator = object.count == 2 ? object[1] as? UIViewControllerTransitionCoordinator : nil
                return (traitCollection, coordinator)
            }
    }
}
