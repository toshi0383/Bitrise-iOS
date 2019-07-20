import Combine
import SwiftUI

struct StartBuildView : View {
    @ObjectBinding var store: StartBuildStore

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
//            .navigationBarTitle(Text("Start Build"))
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

final class StartBuildStore: BindableObject {
    let app: App

    var tokenText: String = "" {
        didSet {
            willChange.send(self)
        }
    }

    var branchName: String = "" {
        didSet {
            willChange.send(self)
        }
    }

    var workflows: [Workflow] = [] {
        didSet {
            willChange.send(self)
        }
    }

    init(app: App, workflows: [Workflow] = []) {
        self.app = app
        self.workflows = workflows
    }

    var willChange = PassthroughSubject<StartBuildStore, Never>()
}

struct Workflow: Equatable, Hashable, Identifiable {
    let id: String
}
