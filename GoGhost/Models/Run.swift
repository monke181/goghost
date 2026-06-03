import SwiftData
import Foundation
import SwiftUI

@Model
final class Run {
    var id: UUID
    var name: String
    var why: String
    var focusAreas: [String]
    var goals: [String]
    var completedGoals: [String]
    var streakFreezeCount: Int
    var streakFreezeUsedDates: [Date]
    var allTimeBestStreak: Int
    var hasSeenCompletionCeremony: Bool
    var startDate: Date
    var targetDays: Int
    var isActive: Bool
    var isCompleted: Bool
    var completedDate: Date?

    @Relationship(deleteRule: .cascade, inverse: \DailyEntry.run)
    var entries: [DailyEntry]

    @Relationship(deleteRule: .cascade, inverse: \FocusSession.run)
    var focusSessions: [FocusSession]

    var dayNumber: Int {
        let elapsed = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: startDate), to: Calendar.current.startOfDay(for: .now)).day ?? 0
        return min(elapsed + 1, targetDays)
    }

    var daysRemaining: Int { max(targetDays - dayNumber, 0) }

    var progressFraction: Double { Double(dayNumber) / Double(targetDays) }

    var currentStreak: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let freezeSet = Set(streakFreezeUsedDates.map { cal.startOfDay(for: $0) })
        var streak = 0
        var checkDay = today

        while streak <= 365 {
            let isToday = checkDay == today
            let dayEntry = entries.first(where: { cal.startOfDay(for: $0.date) == checkDay })
            let hasCheckIn = isToday
                ? dayEntry?.morningCheckInCompleted == true
                : dayEntry?.nightCheckInCompleted == true

            if hasCheckIn || freezeSet.contains(checkDay) {
                streak += 1
            } else {
                break
            }

            guard let prev = cal.date(byAdding: .day, value: -1, to: checkDay) else { break }
            checkDay = prev
        }

        return streak
    }

    var last7DayScores: [Int] {
        let today = Calendar.current.startOfDay(for: .now)
        return (0..<7).reversed().map { offset in
            guard let date = Calendar.current.date(byAdding: .day, value: -offset, to: today) else { return 0 }
            return entries.first(where: {
                Calendar.current.startOfDay(for: $0.date) == date
            })?.disciplineScore ?? 0
        }
    }

    var averageDisciplineScore: Int {
        let scored = entries.filter { $0.nightCheckInCompleted }
        guard !scored.isEmpty else { return 0 }
        return scored.reduce(0) { $0 + $1.disciplineScore } / scored.count
    }

    var allTimeBestScore: Int {
        entries.map { $0.disciplineScore }.max() ?? 0
    }

    var ghostLevel: GhostLevel {
        let avg = averageDisciplineScore
        if avg >= 85 { return .elite }
        if avg >= 70 { return .phantom }
        if avg >= 55 { return .ghost }
        if avg >= 40 { return .grinder }
        return .civilian
    }

    var momentumDirection: MomentumDirection {
        let scores = last14DayScores
        let recent = Array(scores.suffix(7)).filter { $0 > 0 }
        let prior  = Array(scores.prefix(7)).filter { $0 > 0 }
        guard !recent.isEmpty, !prior.isEmpty else { return .steady }
        let recentAvg = recent.reduce(0, +) / recent.count
        let priorAvg  = prior.reduce(0, +) / prior.count
        if recentAvg >= priorAvg + 5 { return .building }
        if recentAvg <= priorAvg - 5 { return .fading }
        return .steady
    }

    var last14DayScores: [Int] {
        let today = Calendar.current.startOfDay(for: .now)
        return (0..<14).reversed().map { offset in
            guard let date = Calendar.current.date(byAdding: .day, value: -offset, to: today) else { return 0 }
            return entries.first(where: { Calendar.current.startOfDay(for: $0.date) == date })?.disciplineScore ?? 0
        }
    }

    var last7DayAvgScore: Int {
        let scored = last7DayScores.filter { $0 > 0 }
        guard !scored.isEmpty else { return 0 }
        return scored.reduce(0, +) / scored.count
    }

    var isCleanWeek: Bool {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        var completed = 0
        var total = 0
        for offset in 0..<7 {
            guard let date = cal.date(byAdding: .day, value: -offset, to: today) else { continue }
            if let entry = entries.first(where: { cal.startOfDay(for: $0.date) == date }),
               entry.nightCheckInCompleted {
                completed += 1
                total += entry.disciplineScore
            }
        }
        return completed == 7 && total / 7 >= 70
    }

    var totalRunFocusMinutes: Int { entries.reduce(0) { $0 + $1.totalFocusMinutes } }
    var totalNightCheckIns: Int  { entries.filter { $0.nightCheckInCompleted }.count }
    var totalMorningCheckIns: Int { entries.filter { $0.morningCheckInCompleted }.count }

    var weekNumber: Int {
        let days = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: startDate),
            to:   Calendar.current.startOfDay(for: .now)
        ).day ?? 0
        return days / 7 + 1
    }

    var endDate: Date {
        Calendar.current.date(byAdding: .day, value: targetDays - 1, to: startDate) ?? startDate
    }

    init(name: String, why: String, focusAreas: [String], goals: [String] = [], startDate: Date = .now) {
        self.id = UUID()
        self.name = name
        self.why = why
        self.focusAreas = focusAreas
        self.goals = goals
        self.completedGoals = []
        self.streakFreezeCount = 1
        self.streakFreezeUsedDates = []
        self.allTimeBestStreak = 0
        self.hasSeenCompletionCeremony = false
        self.startDate = startDate
        self.targetDays = 90
        self.isActive = true
        self.isCompleted = false
        self.entries = []
        self.focusSessions = []
    }
}

enum GhostLevel: String {
    case civilian = "CIVILIAN"
    case grinder  = "GRINDER"
    case ghost    = "GHOST"
    case phantom  = "PHANTOM"
    case elite    = "ELITE"

    var tagline: String {
        switch self {
        case .civilian: return "Just getting started."
        case .grinder:  return "Putting in the work."
        case .ghost:    return "Locked in. Fading into the work."
        case .phantom:  return "They don't even see you coming."
        case .elite:    return "A different breed entirely."
        }
    }

    var sortOrder: Int {
        switch self { case .civilian: 0; case .grinder: 1; case .ghost: 2; case .phantom: 3; case .elite: 4 }
    }
}

enum MomentumDirection {
    case building, steady, fading

    var label: String {
        switch self {
        case .building: return "MOMENTUM BUILDING"
        case .steady:   return "MOMENTUM STEADY"
        case .fading:   return "MOMENTUM FADING"
        }
    }

    var symbol: String {
        switch self { case .building: return "↑"; case .steady: return "→"; case .fading: return "↓" }
    }

    var color: Color { self == .fading ? .red : (self == .building ? Color(hex: "22C55E") : Color(hex: "888888")) }
}
