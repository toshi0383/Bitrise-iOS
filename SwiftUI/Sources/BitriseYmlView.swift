import Combine
import SwiftUI

struct BitriseYmlView : View {
    @ObservedObject var store: BitriseYmlStore

    var body: some View {
        List {
            ForEach(store.lines) { line in
                Text(line.value)
            }
        }
    }
}

#if DEBUG
struct BitriseYmlView_Previews : PreviewProvider {
    static var previews: some View {
        BitriseYmlView(store:
            .init(app: testApp,
                  lines: [
                    "a", "b", "c"
        ].map(Line.init)))
    }
}
#endif

final class BitriseYmlStore: ObservableObject {
    let app: App

    var lines: [Line] = [] {
        didSet {
            objectWillChange.send(self)
        }
    }

    init(app: App, lines: [Line] = []) {
        self.app = app
        self.lines = lines
    }

    var objectWillChange = PassthroughSubject<BitriseYmlStore, Never>()
}

struct Line: Equatable, Hashable, Identifiable {
    let id = UUID()
    var value: String
    init(value: String) {
        self.value = value
    }
}
