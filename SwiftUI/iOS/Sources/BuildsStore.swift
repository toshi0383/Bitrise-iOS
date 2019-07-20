import APIKit
import Combine
import Core
import Foundation
import RxSwift
import SwiftUI

final class BuildsStore: BindableObject {
    let app: App

    var builds: [Build] = [] {
        didSet {
            willChange.send(self)
        }
    }

    private let disposeBag = DisposeBag()

    init(app: App, builds: [Build] = []) {
        self.app = app
        self.builds = builds

        let req = AppsBuildsRequest(appSlug: app.slug)
        Session.shared.rx.send(req)
            .subscribe(onNext: { [weak self] res in
                self?.builds = AppsBuilds(from: res).data
            })
            .disposed(by: disposeBag)
    }

    var willChange = PassthroughSubject<BuildsStore, Never>()
}

typealias Build = AppsBuilds.Build
extension Build: Identifiable {
    public var id: String {
        return slug
    }
}
