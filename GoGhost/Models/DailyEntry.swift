import SwiftData
import Foundation

@Model
final class DailyEntry {
    var id: UUID
    var date: Date
    var dayNumber: Int

    // Morning
    var morningCheckInCompleted: Bool
    var morningGoal1: String
    var morningGoal2: String
    var morningGoal3: String
    var morningFocusArea: String
    var morningMotivationLevel: Int     // 1–10

    // Night
    var nightCheckInCompleted: Bool
    var nightWins: String
    var nightLosses: String
    var nightLessons: String
    var nightScoreRating: Int           // 1–10

    // Ghost mode log for the day
    var totalFocusMinutes: Int
    var dopamineAvoided: [String]       // items user marked as avoided

    var run: Run?

    var disciplineScore: Int {
        var score = 0
        if morningCheckInCompleted { score += 25 }
        if nightCheckInCompleted   { score += 25 }
        if nightScoreRating > 0 {
            score += Int(Double(nightScoreRating) / 10.0 * 30.0)
        }
        let focusBonus = min(totalFocusMinutes / 25, 4) * 5
        score += focusBonus
        return min(score, 100)
    }

    init(date: Date, dayNumber: Int) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.dayNumber = dayNumber
        self.morningCheckInCompleted = false
        self.morningGoal1 = ""
        self.morningGoal2 = ""
        self.morningGoal3 = ""
        self.morningFocusArea = ""
        self.morningMotivationLevel = 5
        self.nightCheckInCompleted = false
        self.nightWins = ""
        self.nightLosses = ""
        self.nightLessons = ""
        self.nightScoreRating = 0
        self.totalFocusMinutes = 0
        self.dopamineAvoided = []
    }
}
