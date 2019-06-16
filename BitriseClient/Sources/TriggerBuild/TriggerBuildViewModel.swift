import Core
import Foundation
import RealmSwift
import RxCocoa
import RxSwift

typealias WorkflowID = String
typealias AppSlug = String

/// TriggerBuildViewModel
///
/// - performs database update
/// - publish states for view
/// - triggers new builds via network
final class TriggerBuildViewModel {

    // MARK: Output

    let buildDidTrigger: Observable<Void>
    let alertMessage: Observable<String>

    // MARK: Private

    private let _buildDidTrigger = PublishRelay<Void>()
    private let _alertMessage = PublishRelay<String>()

    private var realmObject: BuildTriggerRealm!

    // MARK: LifeCycle

    /// NOTE: Accesses to realm in current thread.
    init(appSlug: String) {

        buildDidTrigger = _buildDidTrigger.asObservable()
        alertMessage = _alertMessage.asObservable()

        let realm = Realm.getRealm()

        if let obj = realm.object(ofType: BuildTriggerRealm.self, forPrimaryKey: appSlug) {
            realmObject = obj
        } else {
            let gitObject = GitObject.branch("")
            let properties: [String: Any?] = [
                "appSlug": appSlug,
                "gitObjectValue": gitObject.name,
                "gitObjectType": gitObject.type,
                "environments": []
            ]
            let b = BuildTriggerRealm(value: properties)
            try! realm.write {
                realm.add(b)
            }
            realmObject = b
        }
    }

    // TODO: Remember the last value
    var workflowID: WorkflowID?

    var workflowIDs: List<String> {
        get {
            return realmObject.workflowIDs
        }
    }

    func appendWorkflowID(_ workflowID: WorkflowID) {
        try! Realm.getRealm().write {
            realmObject.workflowIDs.append(workflowID)
        }
    }

    func removeWorkflowID(at row: Int) {
        try! Realm.getRealm().write {
            realmObject.workflowIDs.remove(at: row)
        }
    }

    var apiToken: String? {
        get {
            return realmObject.apiToken
        }
        set {
            try! Realm.getRealm().write {
                realmObject.apiToken = newValue
            }
        }
    }

    var gitObject: GitObject! {
        get {
            return GitObject(realmObject: realmObject)
        }
        set {
            // skip initial value via continuum
            guard let newValue = newValue else {
                return
            }
            try! Realm.getRealm().write {
                realmObject.gitObjectValue = newValue.name
                realmObject.gitObjectType = newValue.type
            }
        }
    }

    private var gitObjectCache: GitObjectCacheRealm = {
        let realm = Realm.getRealm()
        return realm.objects(GitObjectCacheRealm.self).first ?? GitObjectCacheRealm()
    }()

    var environments: [BuildTriggerEnvironment] {
        get {
            return realmObject.environments.map(BuildTriggerEnvironment.init)
        }
    }

    func appendEnvironment(_ value: (key: String, value: String)) {
        let realm = Realm.getRealm()
        try! realm.write {
            let env: BuildTriggerEnvironmentRealm = {
                if let existing = realm.object(ofType: BuildTriggerEnvironmentRealm.self,
                                               forPrimaryKey: value.key) {
                    existing.value = value.value
                    return existing
                } else {
                    let new = BuildTriggerEnvironmentRealm()
                    new.pkey = UUID().uuidString
                    new.key = value.key
                    new.value = value.value
                    return new
                }
            }()

            realmObject.environments.append(env)
        }
    }

    func setEnvironment(_ env: BuildTriggerEnvironment) {
        let realm = Realm.getRealm()
        if let o = realm.object(ofType: BuildTriggerEnvironmentRealm.self, forPrimaryKey: env.pkey) {
            try! realm.write {
                o.enabled = env.enabled
                o.key = env.key
                o.value = env.value
            }
        }
    }

    func removeEnvironment(at row: Int) {
        try! Realm.getRealm().write {
            realmObject.environments.remove(at: row)
        }
    }

    private func urlRequest() -> URLRequest? {

        guard let token = apiToken else { return nil }
        guard let workflowID = workflowID else { return nil }

        guard let url = URL(string: "https://app.bitrise.io/app/\(realmObject.appSlug)/build/start.json") else {
            return nil
        }

        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 5.0)

        let environments: [JSON] = self.environments.compactMap { $0.enabled ? $0.json : nil }
        let body = BuildTriggerRequest(hook_info: .init(api_token: token),
                                       build_params: gitObject.json
                                        |+| ["workflow_id": workflowID]
                                        |+| ["environments": environments])
        req.httpBody = try! body.encode()
        req.httpMethod = "POST"

        return req
    }

    func triggerBuild() {

        guard let req = urlRequest() else {
            alert("ERROR: Could not build request.")
            return
        }

        let gitObject = self.gitObject!

        let task = URLSession.shared.dataTask(with: req) { [weak self] (data, res, err) in

            guard let me = self else { return }

            #if DEBUG
                if let res = res as? HTTPURLResponse {
                    print(res.statusCode)
                    print(res.allHeaderFields)
                }
            #endif

            if let err = err {
                me.alert(err.localizedDescription)
                return
            }

            let str: String = {
                if let data = data {
                    return String(data: data, encoding: .utf8) ?? ""
                } else {
                    return ""
                }
            }()

            guard (res as? HTTPURLResponse)?.statusCode == 201 else {
                me.alert("Fail str: \(str)")
                return
            }

            me._buildDidTrigger.accept(())

            me.alert("Success\n\(str)")

            DispatchQueue.main.async { [weak me] in
                guard let me = me else { return }
                let realm = Realm.getRealm()

                do {
                    try realm.write {
                        me.gitObjectCache.enqueue(gitObject)
                        realm.add(me.gitObjectCache, update: .all)
                    }
                } catch {
                    assertionFailure("Failed to write realm object.")
                }
            }

        }

        task.resume()
    }

    func getSuggestions(forType type: String) -> [String] {
        assert(Thread.current == .main)
        return gitObjectCache.name(forType: type)
    }

    private func alert(_ string: String) {
        _alertMessage.accept(string)
    }
}
