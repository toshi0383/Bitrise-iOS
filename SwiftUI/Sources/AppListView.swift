import BitriseSwift
import Combine
import SwiftUI

struct AppListView : View {
    @ObservedObject var store = AppStore()

    var body: some View {
        NavigationView {
            List {
                ForEach(store.apps) { (app: App) in
                    NavigationLink(destination: BuildListView(app: app)) {
                        Text(app.title!)
                    }
                }
            }
            .navigationBarTitle(Text("Apps"))
        }
    }
}

#if DEBUG
struct AppListView_Previews : PreviewProvider {
    static var previews: some View {
        AppListView(store: testStore)
    }
}

private let testStore = AppStore(apps: testData)
private let testData = [
    "Bitrise-iOS",
    "AbemaTV",
    "Netflix",
    "Amazon Prime Video"
    ].map {
        App(avatarURL: nil, isDisabled: false, owner: .init(name: "toshi0383"), projectType: nil, provider: "provider", repoSlug: "afawefawe", repoURL: "https://github.com/toshi0383", slug: "egeruhoooi", title: $0)
}

let testApp = App(avatarURL: nil, isDisabled: false, owner: .init(name: "toshi0383"), projectType: nil, provider: "provider", repoSlug: "afawefawe", repoURL: "https://github.com/toshi0383", slug: "egeruhoooi", title: "Bitrise-iOS")


#endif
