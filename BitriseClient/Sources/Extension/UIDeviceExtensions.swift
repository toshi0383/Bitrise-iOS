//
//  UIDeviceExtensions.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/12.
//

import UIKit

private func getVersionCode() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)

    let versionCode: String = String(validatingUTF8: NSString(bytes: &systemInfo.machine, length: Int(_SYS_NAMELEN), encoding: String.Encoding.ascii.rawValue)!.utf8String!)!

    return versionCode
}

enum Device {
    static var isPhoneX: Bool {
        return ["iPhone10,3", "iPhone10,6"].contains(getVersionCode())
    }
}

