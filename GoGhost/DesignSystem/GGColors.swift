import SwiftUI

struct GGColors {
    // Backgrounds
    static let background       = Color(hex: "0A0A0A")
    static let surface          = Color(hex: "111111")
    static let surfaceElevated  = Color(hex: "1C1C1C")
    static let border           = Color(hex: "2C2C2C")

    // Text
    static let textPrimary      = Color.white
    static let textSecondary    = Color(hex: "888888")
    static let textTertiary     = Color(hex: "3C3C3C")

    // Accent — green. Used only on active states: streak, today's bar, go ghost button, session complete
    static let accent           = Color(hex: "22C55E")
    static let accentDim        = Color(hex: "22C55E").opacity(0.15)

    // Semantic
    static let danger           = Color(hex: "EF4444")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
