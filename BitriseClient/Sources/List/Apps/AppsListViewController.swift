import APIKit
import UIKit

final class AppsListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let req = MeAppsRequest()
        Session.shared.send(req) { result in
            switch result {
            case .success(let res):
                print(res)
            case .failure(let error):
                print(error)
            }
        }
    }
}
