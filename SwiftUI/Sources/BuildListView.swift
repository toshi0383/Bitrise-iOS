import Combine
import SwiftUI

struct BuildListView : View {

    @ObservedObject var store: BuildsStore

    @State var isStartBuildViewPresented = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Menu")) {
                    Button(action: { self.isStartBuildViewPresented.toggle() }) {
                        Text("Start Build")
                    }
                    NavigationLink(destination: BitriseYmlView(store: .init(app: self.store.app))) {
                        Text("bitrise.yml")
                    }
                }
                Section(header: Text("Builds")) {
                    ForEach(store.builds) { b in
                        HStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.buildSuccess)
                                .frame(width: 30, height: 30, alignment: .center)
                            Text("#\(b.build_number.description) \(b.status_text) [\(b.triggered_workflow)]")
                        }
                    }
                }
            }
            .navigationBarTitle(Text(store.app.title))
            .sheet(isPresented: $isStartBuildViewPresented, onDismiss: nil, content: {
                StartBuildView(app: self.store.app)
            })
        }
    }
}

extension BuildListView {
    init(app: App) {
        store = BuildsStore(app: app)
    }
}

#if DEBUG
struct BuildListView_Previews : PreviewProvider {
    static var previews: some View {
        BuildListView(store: testStore)
    }
}

private let testStore: BuildsStore = BuildsStore(app: testApp, builds: (0..<100).map { i in
    Build(abort_reason: nil, branch: "master", build_number: i * 1000, commit_hash: "afawagaew", commit_message: "hello", commit_view_url: nil, environment_prepare_finished_at: nil, finished_at: nil, is_on_hold: false, original_build_params: [:], pull_request_id: 1234, pull_request_target_branch: "develop", pull_request_view_url: nil, slug: "afwfwgrexxx\(i)", stack_config_type: nil, stack_identifier: nil, started_on_worker_at: Date(), status: .notFinished, status_text: "in-progress", tag: nil, triggered_at: Date(), triggered_by: nil, triggered_workflow: "primary")
    }
)
#endif
