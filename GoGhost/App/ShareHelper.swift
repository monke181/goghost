import SwiftUI
import UIKit
import CoreTransferable
import UniformTypeIdentifiers

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
