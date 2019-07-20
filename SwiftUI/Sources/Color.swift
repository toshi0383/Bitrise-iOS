import SwiftUI

extension Color {
    init(hex: Int) {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0x00FF00) >> 8) / 255.0
        let blue = Double(hex & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }

    public static let baseGreen = Color(hex: 0x40B497)
    public static let gitRed = Color(hex: 0xFF5500)
    public static let gitRedHighlight = Color(hex: 0xDB4B02)
    public static let buildInProgress = Color(hex: 0x8054A6)
    public static let buildSuccess    = Color(hex: 0x43C2A3)
    public static let buildAborted    = Color(hex: 0xFEDE35)
    public static let buildError      = Color(hex: 0xEE742E)
    public static let buildOnHold     = Color(hex: 0x064357)
}
