import SwiftUI
import UIKit
import CoreTransferable
import UniformTypeIdentifiers

// MARK: - Image rendering

/// Renders a SwiftUI view to a UIImage suitable for sharing.
///
/// Uses SwiftUI's ImageRenderer — needs no window or live view hierarchy and renders
/// synchronously. Reliable for our content (text + rectangles + shapes; no Metal, blur,
/// or AsyncImage).
///
/// Pass `height: nil` (default) to let the view size to its natural content height —
/// only the width is constrained, so the resulting image hugs the content vertically.
/// Pass an explicit height for a fixed aspect ratio.
@MainActor
func renderToImage<Content: View>(_ content: Content, width: CGFloat = 393, height: CGFloat? = nil) -> UIImage? {
    let sized = content
        .frame(width: width)
        .frame(height: height)   // no-op when height is nil → natural height
        .background(GGColors.background)
        .environment(\.colorScheme, .dark)

    let renderer = ImageRenderer(content: sized)
    renderer.proposedSize = ProposedViewSize(width: width, height: height)
    renderer.scale = 3.0
    renderer.isOpaque = true
    return renderer.uiImage
}

// MARK: - Transferable share image

/// A PNG-backed image that works with the native SwiftUI `ShareLink`.
/// Exports as a real .png file so every destination (Save Image, Photos, Messages,
/// AirDrop, Instagram, etc.) treats it as a shareable picture — not the app itself.
struct ShareableImage: Transferable {
    let image: UIImage
    let filename: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { shareable in
            shareable.image.pngData() ?? Data()
        }
        .suggestedFileName { $0.filename }
    }
}
