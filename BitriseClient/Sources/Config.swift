//
//  Config.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/09.
//  Copyright © 2018 toshi0383. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import UIKit

// - MARK: SwiftyUserDefaults

extension DefaultsKeys {
    static let bitrisePersonalAccessToken = DefaultsKey<String?>("bitrisePersonalAccessToken")
    static let lastAppNameVisited = DefaultsKey<String?>("lastAppNameVisited")
}

// - MARK: InfoPlist

private let _Plist = Bundle.main.infoDictionary!
class InfoPlist {
    //fileprivate enum StringKey: String {
    //}
    enum OptionalStringKey: String {
        case BITRISE_PERSONAL_ACCESS_TOKEN
    }

    enum OptionalDictionaryKey: String {
        case TRIGGER_BUILD_WORKFLOW_IDS
        case TRIGGER_BUILD_API_TOKENS
    }

    //subscript(key: StringKey) -> String {
    //    return _Plist["\(key)"] as! String
    //}

    subscript(key: OptionalStringKey) -> String? {
        if let s = _Plist["\(key)"] as? String, !s.isEmpty {
            return s
        } else {
            return nil
        }
    }

    subscript(key: OptionalDictionaryKey) -> [String: String]? {
        if let s = _Plist["\(key)"] as? String, !s.isEmpty {
            return try! JSONDecoder().decode([String: String].self, from: s.data(using: .utf8)!)
        } else {
            return nil
        }
    }
}

// - MARK: Config

final class Config {

    static let infoPlist = InfoPlist()

    static let defaults: UserDefaults = Defaults

    static func getNonEmptyStringOrNil(_ key: InfoPlist.OptionalStringKey) -> String? {
        if let s: String = infoPlist[key], !s.isEmpty {
            return s
        } else {
            return nil
        }
    }

    static func apiToken(for appSlug: AppSlug) -> String? {
        return apiTokensMap?[appSlug]
    }

    static var apiTokensMap: [AppSlug: String]? {
        return infoPlist[.TRIGGER_BUILD_API_TOKENS]
    }

    static var workflowIDsMap: [AppSlug: [WorkflowID]] {
        guard let dictionary = infoPlist[.TRIGGER_BUILD_WORKFLOW_IDS] else {
            return [:]
        }

        return dictionary.mapValues(stringToStrArray)
    }

    private static func stringToStrArray(_ string: String) -> [String] {
        return string
            .split(separator: " ")
            .filter { !$0.isEmpty }
            .map { String($0) }
    }

    //static func workflowIDs(for appSlug: String) -> [WorkflowID] {
    //    guard let dictionary = infoPlist[.TRIGGER_BUILD_WORKFLOW_IDS],
    //        let idsStr = dictionary[appSlug]
    //        else {
    //        return []
    //    }
    //    return stringToStrArray(idsStr)
    //}

    static var personalAccessToken: String? {
        if let t = infoPlist[.BITRISE_PERSONAL_ACCESS_TOKEN] {
            return t
        }

        return cachedPersonalAccessToken
    }

    static var cachedPersonalAccessToken: String? {
        get {
            return defaults[.bitrisePersonalAccessToken]
        }
        set {
            defaults[.bitrisePersonalAccessToken] = newValue
        }
    }
}
