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
                            Text("#\(b.buildNumber!) \(b.statusText!) [\(b.triggeredWorkflow!)]")
                        }
                    }
                }
            }
            .navigationBarTitle(Text(store.app.title!))
            .sheet(isPresented: $isStartBuildViewPresented, onDismiss: nil, content: {
                StartBuildView(
                    isStartBuildViewPresented: self.$isStartBuildViewPresented,
                    store: .init(
                        app: self.store.app,
                        workflows: [
                            Workflow(id: "primary"),
                            Workflow(id: "test"),
                        ]
                    )
                )

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
    Build(abortReason: nil, branch: "master", buildNumber: i * 1000, commitHash: "fawefawefa", commitMessage: "hello", commitViewURL: nil, environmentPrepareFinishedAt: nil, finishedAt: nil, isOnHold: false, originalBuildParams: [:], pullRequestId: 1234, pullRequestTargetBranch: "develop", pullRequestViewURL: nil, slug: "faweafawef\(i)", stackConfigType: nil, stackIdentifier: nil, startedOnWorkerAt: "2019-11-16T12:24:56Z", status: 0, statusText: "in-progress", tag: nil, triggeredAt: "2019-11-16T12:24:53Z", triggeredBy: "webhook", triggeredWorkflow: "primary")
    }
)
#endif
