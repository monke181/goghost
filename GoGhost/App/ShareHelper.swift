import SwiftUI
import UIKit

// MARK: - Image rendering

/// Renders a SwiftUI view to a UIImage suitable for sharing.
///
/// Approach: temporarily add a UIHostingController to the live key window (offscreen),
/// force Core Animation to flush, then capture with drawHierarchy(afterScreenUpdates:true).
/// This is the only approach that reliably captures SwiftUI's Metal-based rendering on device.
@MainActor
func renderToImage<Content: View>(_ content: Content, width: CGFloat = 393, height: CGFloat = 852) -> UIImage? {
    let size = CGSize(width: width, height: height)

    guard
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
        let window = windowScene.windows.first(where: { $0.isKeyWindow })
    else { return nil }

    let hosting = UIHostingController(
        rootView: content
            .frame(width: size.width, height: size.height)
            .environment(\.colorScheme, .dark)
    )
    hosting.view.frame = CGRect(
        x: -size.width * 2,   // place well offscreen so user never sees it
        y: -size.height * 2,
        width:  size.width,
        height: size.height
    )
    hosting.view.backgroundColor = UIColor(red: 0.039, green: 0.039, blue: 0.039, alpha: 1)

    window.addSubview(hosting.view)
    hosting.view.setNeedsLayout()
    hosting.view.layoutIfNeeded()

    // Flush Core Animation so SwiftUI's Metal layer paints before we capture.
    CATransaction.flush()

    let image = UIGraphicsImageRenderer(size: size).image { _ in
        hosting.view.drawHierarchy(in: hosting.view.bounds, afterScreenUpdates: true)
    }

    hosting.view.removeFromSuperview()
    return image
}

// MARK: - Share sheet presentation

/// Presents a UIActivityViewController over the topmost view controller.
/// Dispatches to main async so any SwiftUI transitions complete first.
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
