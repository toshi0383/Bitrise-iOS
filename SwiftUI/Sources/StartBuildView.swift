import APIKit
import Combine
import Core
import SwiftUI

struct StartBuildView : View {
    @Binding var isStartBuildViewPresented: Bool
    @ObservedObject var store: StartBuildStore

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack {
                        TextField("Branch name", text: $store.branchName)
                    }

                    Button("Go!") {
                        self.store.trigger()
                    }
                    .frame(width: 80, height: 80, alignment: .center)
                    .foregroundColor(Color.baseGreen)
                }
                List {
                    ForEach(store.workflows) { workflow in
                        Text(workflow.id)
                        //                            .onTapGesture {
                        //                                self.store.selectedWorkflow = workflow
                        //                        }
                    }
                }
                Button("close") {
                    self.isStartBuildViewPresented.toggle()
                }

            }
            .navigationBarTitle(Text("Start Build"))
        }

    }
}

#if DEBUG
struct StartBuildView_Previews : PreviewProvider {
    static var previews: some View {
        StartBuildView(
            isStartBuildViewPresented: Binding<Bool>.init(get: { true }, set: { _ in }),
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

    var selectedWorkflow: Workflow? = Workflow(id: "test")

    var branchName: String = "" {
        didSet {
            objectWillChange.send(self)
        }
    }

    var workflows: [Workflow] {
        didSet {
            objectWillChange.send(self)
        }
    }

    init(app: App, workflows: [Workflow] = [.init(id: "test")]) {
        self.app = app
        self.workflows = workflows
    }

    var objectWillChange = PassthroughSubject<StartBuildStore, Never>()

    func trigger() {
        if let workflow = selectedWorkflow {
            let req = BuildTriggerRequest(appSlug: app.slug,
                                          branch: branchName,
                                          workflow_id: workflow.id)

            Session.shared.send(req) { result in
                switch result {
                case .success(let res):
                    print("\(res)")
                case .failure(let error):
                    print("\(error)")
                }
            }
        }

    }
}

struct Workflow: Equatable, Hashable, Identifiable {
    let id: String
}
