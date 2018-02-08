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

    fileprivate enum ArrayKey: String {
        case WORKFLOW_IDS
    }

    subscript(key: StringKey) -> String {
        return _Plist["\(key)"] as! String
    }

    // TOOD
    //subscript(key: ArrayKey) -> [AnyObject] {
    //    return _Plist["\(key)"] as! [AnyObject]
    //}
}
private let InfoPlist = _InfoPlist()

final class Config {
    static var appSlug: String {
        return InfoPlist[.BITRISE_APP_SLUG]
    }

    static var apiToken: String {
        return InfoPlist[.BITRISE_API_TOKEN]
    }
}
