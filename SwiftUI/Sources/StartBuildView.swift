import Combine
import SwiftUI

struct StartBuildView : View {
    @ObservedObject var store: StartBuildStore

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack {
                        SecureField("API Token for \(self.store.app.title)", text: $store.tokenText)
                        TextField("Branch name", text: $store.branchName)
                    }

                    Button("Go!") {
                        // start build
                    }
                    .frame(width: 80, height: 80, alignment: .center)
                    .foregroundColor(Color.baseGreen)
                }
                List {
                    ForEach(store.workflows) { workflow in
                        Text(workflow.id)
                    }
                }
            }
            .navigationBarTitle(Text("Start Build"))
        }

    }
}

extension StartBuildView {
    init(app: App) {
        self.store = .init(app: app)
    }
}

#if DEBUG
struct StartBuildView_Previews : PreviewProvider {
    static var previews: some View {
        StartBuildView(
            store: .init(
                app: testApp,
                workflows: [
                    Workflow(id: "primary"),
                    Workflow(id: "test"),
                ]
            )
        )
    }
}
#endif

final class StartBuildStore: ObservableObject {
    let app: App

    var tokenText: String = "" {
        didSet {
            objectWillChange.send(self)
        }
    }

    var branchName: String = "" {
        didSet {
            objectWillChange.send(self)
        }
    }

    var workflows: [Workflow] = [] {
        didSet {
            objectWillChange.send(self)
        }
    }

    init(app: App, workflows: [Workflow] = []) {
        self.app = app
        self.workflows = workflows
    }

    var objectWillChange = PassthroughSubject<StartBuildStore, Never>()
}

struct Workflow: Equatable, Hashable, Identifiable {
    let id: String
}
