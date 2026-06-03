import Testing
import SwiftUI
import UIKit
@testable import GoGhost

@MainActor
struct ShareRenderTests {

    // A simple known view: green block on dark background. We can assert exact pixels.
    private struct ProbeCard: View {
        var body: some View {
            ZStack {
                Color(hex: "0A0A0A")
                Rectangle()
                    .fill(Color(hex: "22C55E"))
                    .frame(width: 200, height: 200)
            }
        }
    }

    @Test func rendersCorrectSize() async throws {
        let img = try #require(renderToImage(ProbeCard(), width: 393, height: 852))
        // scale 3.0 → pixel dimensions are 3x the points
        #expect(img.size.width == 393)
        #expect(img.size.height == 852)
        #expect(img.scale == 3.0)
    }

    @Test func imageIsNotBlank() async throws {
        let img = try #require(renderToImage(ProbeCard(), width: 393, height: 852))
        let cg = try #require(img.cgImage)

        // Sample the center pixel — should be green (the 200x200 block), NOT black.
        let center = try #require(pixel(in: cg, atX: cg.width / 2, y: cg.height / 2))
        #expect(center.g > 150, "center should be green; got \(center)")
        #expect(center.r < 100)

        // Sample a corner — should be the dark background, not transparent/white.
        let corner = try #require(pixel(in: cg, atX: 5, y: 5))
        #expect(corner.r < 40 && corner.g < 40 && corner.b < 40, "corner should be dark bg; got \(corner)")
        #expect(corner.a > 250, "must be opaque; got alpha \(corner.a)")
    }

    @Test func distinctContentProducesDistinctPixels() async throws {
        // Two different scores should yield visually different images (proves real content render)
        let a = try #require(renderToImage(scoreCard(72), width: 393, height: 852))
        let b = try #require(renderToImage(scoreCard(0),  width: 393, height: 852))
        #expect(!imagesEqual(a, b), "different content rendered identical images — render is not capturing content")
    }

    private func scoreCard(_ avg: Int) -> some View {
        DisciplineCardContent(avg: avg, best: 90)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "0A0A0A"))
    }

    // MARK: - Pixel helpers

    private struct RGBA { let r, g, b, a: UInt8 }

    private func pixel(in cg: CGImage, atX x: Int, y: Int) -> RGBA? {
        guard let data = cg.dataProvider?.data,
              let ptr = CFDataGetBytePtr(data) else { return nil }
        let bpp = cg.bitsPerPixel / 8
        let bpr = cg.bytesPerRow
        let offset = y * bpr + x * bpp
        // Assume RGBA or BGRA 8-bit; alpha last or first depending on bitmap info.
        let info = cg.bitmapInfo
        let alphaFirst = info.contains(.byteOrder32Little) || (cg.alphaInfo == .premultipliedFirst || cg.alphaInfo == .first)
        if alphaFirst {
            // BGRA little-endian common on iOS
            let b = ptr[offset]; let g = ptr[offset+1]; let r = ptr[offset+2]; let a = ptr[offset+3]
            return RGBA(r: r, g: g, b: b, a: a)
        } else {
            let r = ptr[offset]; let g = ptr[offset+1]; let b = ptr[offset+2]; let a = ptr[offset+3]
            return RGBA(r: r, g: g, b: b, a: a)
        }
    }

    private func imagesEqual(_ a: UIImage, _ b: UIImage) -> Bool {
        guard let da = a.pngData(), let db = b.pngData() else { return false }
        return da == db
    }
}
