import APIKit
import Combine
import Core
import Foundation
import SwiftUI

final class BuildsStore: BindableObject {
    let app: App

    var builds: [Build] = [] {
        didSet {
            willChange.send(self)
        }
    }

    init(app: App, builds: [Build] = []) {
        self.app = app
        self.builds = builds

        let req = AppsBuildsRequest(appSlug: app.slug)
        Session.shared.send(req) { [weak self] r in
            switch r {
            case .success(let res):
                self?.builds = AppsBuilds(from: res).data
            case .failure(let error):
                print("\(error)")
            }
        }
    }

    var willChange = PassthroughSubject<BuildsStore, Never>()
}

typealias Build = AppsBuilds.Build
extension Build: Identifiable {
    public var id: String {
        return slug
    }
}
