import ActionPopoverButton
import Core
import RxSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        if isTest() {
            return true
        }

        Core.APIConfig.getToken = { Config.personalAccessToken }

        // [ActionPopoverButton]
        UIView.hth.exchangeMethods()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        DispatchQueue.global().async {
            RealmManager.shared.initialize()
        }

        Router.shared.route
            .filterEmpty()
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe(onNext: { [weak self] route in
                guard let me = self else { return }

                let vcs = route.map { route -> UIViewController in
                    switch route {
                    case .appsList:
                        return AppsListViewController.makeFromStoryboard(.init())

                    case .buildsList(let app):
                        return BuildsListViewController.makeFromStoryboard(
                            .init(viewModel: .init(appSlug: app.slug, appName: app.title))
                        )

                    case .launch:
                        return UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()!

                    case .tutorial:
                        let vc = TutorialViewController.makeFromStoryboard()
                        let nc = UINavigationController(rootViewController: vc)
                        nc.isNavigationBarHidden = true
                        return nc

                    }
                }

                let vc: UIViewController = {
                    if vcs.count == 1 {
                        return vcs[0]
                    }

                    let nc = UINavigationController()
                    nc.setViewControllers(vcs, animated: false)
                    return nc
                }()

                me.window?.rootViewController = vc
                me.window?.makeKeyAndVisible()
            })
            .disposed(by: disposeBag)

         if Config.personalAccessToken == nil {
            Router.shared.showTutorial()
         } else {
             Router.shared.showAppsList()
         }

        return true
    }
}
