//
//  Config.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/09.
//  Copyright © 2018 toshi0383. All rights reserved.
//

import Foundation
import UIKit

private let _Plist = Bundle.main.infoDictionary!
private class _InfoPlist {
    fileprivate enum StringKey: String {
        case BITRISE_APP_SLUG
        case BITRISE_API_TOKEN
    }
    fileprivate enum OptionalStringKey: String {
        case BITRISE_WORKFLOW_IDS
    }

    subscript(key: StringKey) -> String {
        return _Plist["\(key)"] as! String
    }

    subscript(key: OptionalStringKey) -> String? {
        return _Plist["\(key)"] as? String
    }
}

private let InfoPlist = _InfoPlist()

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
}
