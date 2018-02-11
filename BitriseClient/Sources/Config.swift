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
}

// - MARK: InfoPlist

private let _Plist = Bundle.main.infoDictionary!
private class _InfoPlist {
    fileprivate enum StringKey: String {
        case BITRISE_APP_SLUG
        case BITRISE_API_TOKEN
    }
    fileprivate enum OptionalStringKey: String {
        case BITRISE_WORKFLOW_IDS
        case BITRISE_PERSONAL_ACCESS_TOKEN
    }

    subscript(key: StringKey) -> String {
        return _Plist["\(key)"] as! String
    }

    subscript(key: OptionalStringKey) -> String? {
        return _Plist["\(key)"] as? String
    }
}

private let InfoPlist = _InfoPlist()

// - MARK: Config

final class Config {
    static var appSlug: String {
        return InfoPlist[.BITRISE_APP_SLUG]
    }

    static var apiToken: String {
        return InfoPlist[.BITRISE_API_TOKEN]
    }

    static var workflowIDs: [WorkflowID] {
        guard let ids = InfoPlist[.BITRISE_WORKFLOW_IDS] else {
            return []
        }
        return ids
            .split(separator: " ")
            .filter { !$0.isEmpty }
            .map { String($0) }
    }

    static var cachedPersonalAccessToken: String? {
        get {
            return Defaults[.bitrisePersonalAccessToken]
        }
        set {
            Defaults[.bitrisePersonalAccessToken] = newValue
        }
    }

    static var personalAccessToken: String? {
        if let t =  InfoPlist[.BITRISE_PERSONAL_ACCESS_TOKEN] {
            return t
        }

        return cachedPersonalAccessToken
    }
}
