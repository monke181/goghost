import SwiftUI

struct GGFonts {
    // PostScript names
    private static let inter         = "InterVariable"
    private static let interDisplay  = "InterDisplay-Black"

    // Counter — large monospaced numbers (day counter, score, timer)
    static let counter = Font.custom(interDisplay, size: 80)
        .monospacedDigit()
    static let counterMedium = Font.custom(interDisplay, size: 48)
        .monospacedDigit()
    static let counterSmall = Font.custom(inter, size: 32)
        .monospacedDigit()

    // Display
    static let display = Font.custom(inter, size: 34).weight(.black)
    static let title   = Font.custom(inter, size: 22).weight(.bold)
    static let headline = Font.custom(inter, size: 17).weight(.semibold)

    // Body
    static let body       = Font.custom(inter, size: 15).weight(.regular)
    static let bodyMedium = Font.custom(inter, size: 15).weight(.medium)

    // Labels
    static let label   = Font.custom(inter, size: 11).weight(.bold)
    static let caption = Font.custom(inter, size: 12).weight(.medium)
}

struct TightTracking: ViewModifier {
    func body(content: Content) -> some View {
        content.tracking(1.5)
    }
}

extension View {
    func tightTracking() -> some View {
        modifier(TightTracking())
    }
}
