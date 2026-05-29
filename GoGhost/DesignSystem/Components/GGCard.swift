import SwiftUI

// Sharp-cornered card — 1px border, minimal fill, no rounding
struct GGCardModifier: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(GGColors.surface)
            .overlay(
                Rectangle()
                    .stroke(GGColors.border, lineWidth: 1)
            )
    }
}

extension View {
    func ggCard(padding: CGFloat = 16) -> some View {
        modifier(GGCardModifier(padding: padding))
    }
}
