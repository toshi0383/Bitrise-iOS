//
//  Haptic.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/22.
//

import UIKit

final class Haptic {
    static func generate(_ style: UIImpactFeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
