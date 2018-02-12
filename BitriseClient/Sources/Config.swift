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
        case TRIGGER_BUILD_APP_SLUG
        case TRIGGER_BUILD_API_TOKEN
        case TRIGGER_BUILD_WORKFLOW_IDS
        case BITRISE_PERSONAL_ACCESS_TOKEN
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

    static var appSlug: String? {
        return infoPlist[.TRIGGER_BUILD_APP_SLUG]
    }

    static var apiToken: String? {
        return infoPlist[.TRIGGER_BUILD_API_TOKEN]
    }

    static var workflowIDs: [WorkflowID] {
        guard let ids = infoPlist[.TRIGGER_BUILD_WORKFLOW_IDS] else {
            return []
        }
        return ids
            .split(separator: " ")
            .filter { !$0.isEmpty }
            .map { String($0) }
    }

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
