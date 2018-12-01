import UIKit

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0x0000FF) / 255.0

        self.init(displayP3Red: red, green: green, blue: blue, alpha: alpha)
    }

    static let baseGreen = UIColor(hex: 0x40B497)
    static let gitRed = UIColor(hex: 0xFF5500)
    static let gitRedHighlight = UIColor(hex: 0xDB4B02)

    static let buildInProgress = UIColor(hex: 0x8054A6)
    static let buildSuccess    = UIColor(hex: 0x43C2A3)
    static let buildAborted    = UIColor(hex: 0xFEDE35)
    static let buildError      = UIColor(hex: 0xEE742E)
    static let buildOnHold     = UIColor(hex: 0x064357)
}
