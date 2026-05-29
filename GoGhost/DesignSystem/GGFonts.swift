import SwiftUI

// Bebas Neue — display/hero only. All caps condensed.
// IBM Plex Mono — everything else. Terminal feel.

struct GGFonts {
    private static let bebas   = "BebasNeue-Regular"
    private static let mono    = "IBMPlexMono-Regular"
    private static let monoMed = "IBMPlexMono-Medium"
    private static let monoSemi = "IBMPlexMono-SemiBold"
    private static let monoBold = "IBMPlexMono-Bold"

    // Hero — Bebas Neue only (day counter, timers, major display numbers)
    static let hero     = Font.custom(bebas, size: 96)
    static let counter  = Font.custom(bebas, size: 80)
    static let display  = Font.custom(bebas, size: 48)
    static let title    = Font.custom(bebas, size: 32)

    // Body — IBM Plex Mono
    static let headline  = Font.custom(monoSemi, size: 15)
    static let body      = Font.custom(mono, size: 14)
    static let bodyMed   = Font.custom(monoMed, size: 14)
    static let label     = Font.custom(monoSemi, size: 11)
    static let caption   = Font.custom(mono, size: 11)

    // Mono bold for scores/numbers in body context
    static let counterSmall = Font.custom(bebas, size: 36)
    static let counterMedium = Font.custom(bebas, size: 56)
}

// Used on Bebas Neue labels to add breathing room (it's very condensed)
struct BebasTracking: ViewModifier {
    var amount: CGFloat = 2
    func body(content: Content) -> some View {
        content.tracking(amount)
    }
}

extension View {
    func bebasTracking(_ amount: CGFloat = 2) -> some View {
        modifier(BebasTracking(amount: amount))
    }
    // Kept for backwards compat — used on caps labels in mono
    func tightTracking() -> some View {
        tracking(1.5)
    }
}
