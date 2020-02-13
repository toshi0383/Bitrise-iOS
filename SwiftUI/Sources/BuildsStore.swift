import BitriseSwift
import Combine
import Core
import Foundation
import SwiftUI

final class BuildsStore: ObservableObject {
    let app: App

    var builds: [Build] = [] {
        didSet {
            objectWillChange.send(self)
        }
    }

    init(app: App, builds: [Build] = []) {
        self.app = app
        self.builds = builds

        let req = API.Builds.BuildList.Request(appSlug: app.slug!)

        APIClient.default.makeRequest(req) { [weak self] r in
            switch r.result {
            case .success(let value):
                if let data = value.success?.data {
                    self?.builds = data
                }
            case .failure(let error):
                print("\(error)")
            }
        }
    }

    var objectWillChange = PassthroughSubject<BuildsStore, Never>()
}

typealias Build = V0BuildResponseItemModel
extension Build: Identifiable {
    public var id: String {
        return slug!
    }
}
