import Combine
import SwiftUI
import RxSwift

struct ContentView : View {
    @ObjectBinding var store = AppStore()

    var body: some View {
        NavigationView {
            List {
                ForEach(store.apps) { (app: App) in
                    NavigationLink(destination: BuildListView(app: app)) {
                        Text(app.title)
                    }
                }
            }
            .navigationBarTitle(Text("Apps"))
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView(store: testStore)
    }
}

private let testStore = AppStore(apps: testData)
private let testData = [
    "Bitrise-iOS",
    "AbemaTV",
    "Netflix",
    "Amazon Prime Video"
    ].map {
        App(is_disabled: false, project_type: nil, provider: "provider", repo_owner: "toshi0383", repo_slug: "afawefawe", repo_url: "https://github.com/toshi0383", slug: "egeruhoooi", title: $0)
}

let testApp = App(is_disabled: false, project_type: nil, provider: "provider", repo_owner: "toshi0383", repo_slug: "afawefawe", repo_url: "https://github.com/toshi0383", slug: "egeruhoooi", title: "Bitrise-iOS")

#endif
