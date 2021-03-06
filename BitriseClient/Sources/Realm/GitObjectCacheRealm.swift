import Realm
import RealmSwift

final class GitObjectCacheRealm: Object {

    @objc dynamic var pkey = ""

    var tags = List<String>()
    var branches = List<String>()
    var commits = List<String>()

    override static func primaryKey() -> String? {
        return "pkey"
    }
}

// MARK: Utility

extension GitObjectCacheRealm {

    func enqueue(_ gitObject: GitObject) {
        switch gitObject {
        case .branch(let name):
            if !branches.contains(name) {
                branches.append(name)
            }
        case .tag(let name):
            if !tags.contains(name) {
                tags.append(name)
            }
        case .commitHash(let name):
            if !commits.contains(name) {
                commits.append(name)
            }
        }
    }

    func name(forType type: String) -> [String] {
        switch type {
        case "tag":
            return tags.map { $0 }
        case "branch":
            return branches.map { $0 }
        case "commitHash":
            return commits.map { $0 }
        default:
            return []
        }
    }
}
