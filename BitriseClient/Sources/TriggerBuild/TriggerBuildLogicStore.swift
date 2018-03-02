//
//  TriggerBuildLogicStore.swift
//  BitriseClient
//
//  Created by 鈴木 俊裕 on 2018/02/05.
//  Copyright © 2018 toshi0383. All rights reserved.
//

import Continuum
import Foundation
import RealmSwift

typealias WorkflowID = String
typealias AppSlug = String

final class TriggerBuildLogicStore {

    private var realmObject: BuildTriggerRealm!

    let buildDidTriggerRelay: Constant<Void?>
    private let _buildDidTriggerRelay = Variable<Void?>(value: nil)

    /// NOTE: Accesses to realm in current thread.
    init(appSlug: String) {

        let realm = Realm.getRealm()

        buildDidTriggerRelay = Constant(variable: _buildDidTriggerRelay)

        if let obj = realm.object(ofType: BuildTriggerRealm.self, forPrimaryKey: appSlug) {
            realmObject = obj
        } else {
            let gitObject = GitObject.branch("")
            let properties: [String: Any?] = [
                "appSlug": appSlug,
                "gitObjectValue": gitObject.associatedValue,
                "gitObjectType": gitObject.type
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

    var gitObject: GitObject {
        get {
            return GitObject(realmObject: realmObject) ?? .branch("")
        }
        set {
            try! Realm.getRealm().write {
                realmObject.gitObjectValue = newValue.associatedValue
                realmObject.gitObjectType = newValue.type
            }
        }
    }

    func urlRequest() -> URLRequest? {

        guard let token = apiToken else { return nil }
        guard let workflowID = workflowID else { return nil }

        guard let url = URL(string: "https://www.bitrise.io/app/\(realmObject.appSlug)/build/start.json") else {
            return nil
        }

        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 5.0)

        let body = BuildTriggerRequest(hook_info: .init(api_token: token),
                                       build_params: gitObject.json + ["workflow_id": workflowID])
        req.httpBody = try! JSONEncoder().encode(body)
        req.httpMethod = "POST"

        return req
    }

    func buildDidTrigger() {
        _buildDidTriggerRelay.value = ()
    }
}

typealias JSON = [String: String]
func + (_ lhs: JSON, _ rhs: JSON) -> JSON {
    var r: JSON = [:]
    lhs.forEach { r[$0] = $1 }
    rhs.forEach { r[$0] = $1 }
    return r
}
