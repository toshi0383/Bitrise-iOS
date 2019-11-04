import APIKit
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
                o.key = env.mapped_to
                o.value = env.value
            }
        }
    }

    func removeEnvironment(at row: Int) {
        try! Realm.getRealm().write {
            realmObject.environments.remove(at: row)
        }
    }

    func triggerBuild() {

        guard let workflowID = workflowID else { return }

        let environments: [BuildTriggerEnvironment] = self.environments.compactMap { $0.enabled ? $0 : nil }
        let req = BuildTriggerRequest(appSlug: realmObject.appSlug,
                                      build_params: BuildParams(gitObject: gitObject,
                                                                workflowID: workflowID,
                                                                environments: environments))

        let gitObject = self.gitObject!

        Session.shared.send(req) { [weak self] (result) in
            guard let me = self else { return }

            switch result {
            case .success(let res):

                me._buildDidTrigger.accept(())

                me.alert("Success\n\(res)")

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
            case .failure(let error):
                me.alert(error.localizedDescription)
            }
        }

    }

    func getSuggestions(forType type: String) -> [String] {
        assert(Thread.current == .main)
        return gitObjectCache.name(forType: type)
    }

    private func alert(_ string: String) {
        _alertMessage.accept(string)
    }
}
