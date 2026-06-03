import Testing
import SwiftUI
import UIKit
@testable import GoGhost

@MainActor
struct CompactShareTests {

    private func mockSummary() -> WeekSummary {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let names = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
        let scores = [85, 72, 0, 90, 65, 88, 78]
        let cells = (0..<7).map { i in
            WeekSummary.DayCell(weekday: names[i],
                                date: cal.date(byAdding: .day, value: -(6 - i), to: today)!,
                                score: scores[i], focusMinutes: 30)
        }
        let scored = scores.filter { $0 > 0 }
        return WeekSummary(weekNumber: 3, startDate: cal.date(byAdding: .day, value: -6, to: today)!,
                           endDate: today, dayCells: cells,
                           avgScore: scored.reduce(0,+)/scored.count, bestScore: scored.max()!,
                           totalFocusMinutes: 350, completedDays: scored.count)
    }

    /// The compact weekly share card should render much shorter than a full screen
    /// (852pt → 2556px @3x). We expect it to hug content well under that.
    @Test func weeklyShareCardIsCompact() async throws {
        let img = try #require(renderToImage(WeeklyShareCard(summary: mockSummary())))
        // Width is the fixed 393pt @3x = 1179px
        #expect(img.size.width == 393)
        // Natural height must be clearly shorter than the old full-screen 852pt.
        #expect(img.size.height < 700, "card height \(img.size.height)pt — expected compact (<700)")
        #expect(img.size.height > 300, "card height \(img.size.height)pt — suspiciously short")
    }

    @Test func compactCardIsNotBlank() async throws {
        let img = try #require(renderToImage(WeeklyShareCard(summary: mockSummary())))
        let cg = try #require(img.cgImage)
        // Sample many points; expect green (bars/scores) somewhere.
        var foundGreen = false
        guard let data = cg.dataProvider?.data, let ptr = CFDataGetBytePtr(data) else {
            Issue.record("no pixel data"); return
        }
        let bpp = cg.bitsPerPixel / 8, bpr = cg.bytesPerRow
        var y = 0
        while y < cg.height && !foundGreen {
            var x = 0
            while x < cg.width {
                let o = y * bpr + x * bpp
                let b = ptr[o], g = ptr[o+1], r = ptr[o+2]   // BGRA
                if g > 140 && r < 120 && b < 140 { foundGreen = true; break }
                x += 6
            }
            y += 6
        }
        #expect(foundGreen, "no green pixels — card content not rendering")
    }
}
