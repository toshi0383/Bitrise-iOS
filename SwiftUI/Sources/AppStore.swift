import BitriseSwift
import Combine
import Core
import Foundation
import SwiftUI

final class AppStore: ObservableObject {
    var objectWillChange = PassthroughSubject<AppStore, Never>()

    var apps: [App] = [] {
        didSet {
            objectWillChange.send(self)
        }
    }

    init(apps: [App] = []) {
        self.apps = apps

        let req = API.Application.AppList.Request(options: .init(sortBy: .lastBuildAt))

        APIClient.default.makeRequest(req) { [weak self] res in
            switch res.result {
            case .success(let value):
                if let data = value.success?.data {
                    self?.apps = data
                }
            case .failure(let apiError):
                print("\(apiError)")
            }
        }
    }
}

typealias App = V0AppResponseItemModel

extension App: Identifiable {
    public var id: String {
        return slug!
    }
}
