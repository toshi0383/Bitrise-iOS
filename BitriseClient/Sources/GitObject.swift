enum GitObject {

    case branch(String), tag(String), commitHash(String)

    var json: [String: Any] {
        switch self {
        case .branch(let v): return ["branch": v]
        case .tag(let v): return ["tag": v]
        case .commitHash(let v): return ["commit": v]
        }
    }

    init?(realmObject: BuildTriggerRealm) {
        guard let value = realmObject.gitObjectValue,
            let type = realmObject.gitObjectType else { return nil }

        switch type {
        case "branch":
            self = .branch(value)
            return
        case "tag":
            self = .tag(value)
            return
        case "commitHash":
            self = .commitHash(value)
            return
        default:
            return nil
        }
    }

    static func enumerated() -> [GitObject] {
        return [.branch(""), .tag(""), .commitHash("")]
    }

    func updateAssociatedValue(_ value: String) -> GitObject {
        switch self {
        case .branch: return .branch(value)
        case .tag: return .tag(value)
        case .commitHash: return .commitHash(value)
        }
    }

    var associatedValue: String {
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
}
