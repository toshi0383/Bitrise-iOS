//
//  AppsManager.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/12.
//

import Foundation

final class AppsManager {
    static let shared = AppsManager()

    var apps: [MeApps.App] = []
}
