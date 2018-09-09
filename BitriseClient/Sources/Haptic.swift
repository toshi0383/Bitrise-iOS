import UIKit

final class Haptic {
    static func generate(_ style: UIImpactFeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
