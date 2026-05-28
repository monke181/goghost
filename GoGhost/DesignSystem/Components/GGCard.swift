import SwiftUI

struct GGCardModifier: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(GGColors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

extension View {
    func ggCard(padding: CGFloat = 16) -> some View {
        modifier(GGCardModifier(padding: padding))
    }
}
