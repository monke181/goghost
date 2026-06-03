import Testing
import SwiftUI
import UIKit
@testable import GoGhost

@MainActor
struct ConfettiRenderTests {

    /// Renders the confetti frozen 0.4s into its animation and confirms it actually
    /// draws particles — i.e. there are non-background colored pixels on screen.
    /// This directly verifies "confetti fires" (the reported bug was nothing appearing).
    @Test func confettiDrawsParticles() async throws {
        let frozen = Date().addingTimeInterval(-0.4)   // mid-animation
        let view = GGConfettiView(count: 300, fixedStart: frozen)
            .frame(width: 393, height: 852)
            .background(Color.black)

        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = ProposedViewSize(width: 393, height: 852)
        renderer.scale = 2.0
        renderer.isOpaque = true

        let img = try #require(renderer.uiImage)
        let cg = try #require(img.cgImage)

        let coloredPixels = countNonBlackPixels(cg)
        // 300 particles over a full screen → expect a meaningful number of lit pixels.
        #expect(coloredPixels > 200, "confetti rendered \(coloredPixels) colored pixels — expected particles to be visible")
    }

    /// A confetti at t=0 (no time elapsed) should be essentially empty (particles
    /// start above the top edge). Confirms the time math gates correctly.
    @Test func confettiEmptyAtStart() async throws {
        let view = GGConfettiView(count: 300, fixedStart: Date())
            .frame(width: 393, height: 852)
            .background(Color.black)

        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = ProposedViewSize(width: 393, height: 852)
        renderer.scale = 2.0
        renderer.isOpaque = true

        let img = try #require(renderer.uiImage)
        let cg = try #require(img.cgImage)
        let coloredPixels = countNonBlackPixels(cg)
        #expect(coloredPixels < 50, "expected near-empty frame at t=0, got \(coloredPixels) colored pixels")
    }

    // MARK: - Pixel counting

    private func countNonBlackPixels(_ cg: CGImage) -> Int {
        guard let data = cg.dataProvider?.data,
              let ptr = CFDataGetBytePtr(data) else { return 0 }
        let bpp = cg.bitsPerPixel / 8
        let bpr = cg.bytesPerRow
        let w = cg.width, h = cg.height
        var count = 0
        // Sample every 4th pixel for speed
        var y = 0
        while y < h {
            var x = 0
            while x < w {
                let off = y * bpr + x * bpp
                let c0 = ptr[off], c1 = ptr[off+1], c2 = ptr[off+2]
                // non-black if any channel is meaningfully lit
                if c0 > 30 || c1 > 30 || c2 > 30 { count += 1 }
                x += 4
            }
            y += 4
        }
        return count
    }
}
