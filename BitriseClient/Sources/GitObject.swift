import UIKit

enum GitObject {
    case branch(String), tag(String), commitHash(String)
}

// MARK: Initializer

extension GitObject {

    init?(type: String, name: String) {
        switch type {
        case "branch":
            self = .branch(name)
            return
        case "tag":
            self = .tag(name)
            return
        case "commitHash":
            self = .commitHash(name)
            return
        default:
            return nil
        }
    }

    init?(realmObject: BuildTriggerRealm) {
        guard let name = realmObject.gitObjectValue,
            let type = realmObject.gitObjectType else { return nil }

        self.init(type: type, name: name)
    }
}

// MARK: Utilities

extension GitObject {

    static func enumerated() -> [GitObject] {
        return [.branch(""), .tag(""), .commitHash("")]
    }

    func updateAssociatedValue(_ name: String) -> GitObject {
        switch self {
        case .branch: return .branch(name)
        case .tag: return .tag(name)
        case .commitHash: return .commitHash(name)
        }
    }

    var name: String {
        switch self {
        case .branch(let v): return v
        case .tag(let v): return v
        case .commitHash(let v): return v
        }
    }

    var type: String {
        switch self {
        case .branch: return "branch"
        case .tag: return "tag"
        case .commitHash: return "commitHash"
        }
    }

    var json: [String: Any] {
        switch self {
        case .branch(let v): return ["branch": v]
        case .tag(let v): return ["tag": v]
        case .commitHash(let v): return ["commit": v]
        }
    }

    var image: UIImage {
        switch self {
        case .branch:
            return UIImage(named: "git-branch")!
        case .tag:
            return UIImage(named: "git-tag")!
        case .commitHash:
            return UIImage(named: "git-commit")!
        }
    }

    var text: String {
        switch self {
        case .branch(let v): return v
        case .tag(let v): return v
        case .commitHash(let v): return v
        }
    }
}
