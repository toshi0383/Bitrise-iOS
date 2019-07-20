import APIKit
import Combine
import Core
import Foundation
import RxSwift
import SwiftUI

final class AppStore: BindableObject {
    var willChange = PassthroughSubject<AppStore, Never>()

    var apps: [App] = [] {
        didSet {
            willChange.send(self)
        }
    }

    private let disposeBag = DisposeBag()

    init(apps: [App] = []) {
        self.apps = apps

        let req = MeAppsRequest()
        Session.shared.rx.send(req)
            .subscribe(onNext: { [weak self] res in
                self?.apps = res.data
            })
            .disposed(by: disposeBag)
    }
}

typealias App = MeApps.App

extension App: Identifiable {
    public var id: String {
        return slug
    }
}
