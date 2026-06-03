import SwiftUI
import UIKit

// MARK: - Image rendering

/// Renders a SwiftUI view to a UIImage suitable for sharing.
///
/// Uses SwiftUI's ImageRenderer — needs no window or live view hierarchy and renders
/// synchronously. Reliable for our content (text + rectangles + shapes; no Metal, blur,
/// or AsyncImage). A fixed proposedSize guarantees a fully-laid-out result every time.
@MainActor
func renderToImage<Content: View>(_ content: Content, width: CGFloat = 393, height: CGFloat = 852) -> UIImage? {
    let renderer = ImageRenderer(
        content: content
            .frame(width: width, height: height)
            .background(GGColors.background)
            .environment(\.colorScheme, .dark)
    )
    renderer.proposedSize = ProposedViewSize(width: width, height: height)
    renderer.scale = 3.0
    renderer.isOpaque = true
    return renderer.uiImage
}

// MARK: - Share sheet presentation

func presentShareSheet(items: [Any]) {
    DispatchQueue.main.async {
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
            let window = windowScene.windows.first(where: { $0.isKeyWindow }),
            let root = window.rootViewController
        else { return }

        var top = root
        while let presented = top.presentedViewController { top = presented }

        let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let popover = avc.popoverPresentationController {
            popover.sourceView = top.view
            popover.sourceRect = CGRect(x: top.view.bounds.midX, y: top.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        top.present(avc, animated: true)
    }
}
