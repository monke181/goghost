import Foundation
import WidgetKit

enum WidgetDataStore {
    private static let suiteName = "group.com.hxndrd.goghost"
    private static var ud: UserDefaults { UserDefaults(suiteName: suiteName) ?? .standard }

    static func write(from run: Run) {
        let today = Calendar.current.startOfDay(for: .now)
        let todayEntry = run.entries.first(where: { Calendar.current.startOfDay(for: $0.date) == today })

        ud.set(run.currentStreak,                              forKey: "widget.streak")
        ud.set(run.dayNumber,                                  forKey: "widget.dayNumber")
        ud.set(run.daysRemaining,                              forKey: "widget.daysRemaining")
        ud.set(run.averageDisciplineScore,                     forKey: "widget.avgScore")
        ud.set(run.allTimeBestStreak,                          forKey: "widget.bestStreak")
        ud.set(run.ghostLevel.rawValue,                        forKey: "widget.ghostLevel")
        ud.set(run.streakFreezeCount,                          forKey: "widget.freezeCount")
        ud.set(run.momentumDirection == .building,             forKey: "widget.momentumBuilding")
        ud.set(todayEntry?.morningCheckInCompleted ?? false,   forKey: "widget.morningDone")
        ud.set(todayEntry?.nightCheckInCompleted ?? false,     forKey: "widget.nightDone")
        ud.set(todayEntry?.disciplineScore ?? 0,               forKey: "widget.todayScore")
        ud.set(run.last7DayScores,                             forKey: "widget.last7Scores")
        ud.set(run.name,                                       forKey: "widget.runName")

        WidgetCenter.shared.reloadAllTimelines()
    }

    static func read() -> WidgetSnapshot {
        WidgetSnapshot(
            streak:          ud.integer(forKey: "widget.streak"),
            dayNumber:       ud.integer(forKey: "widget.dayNumber"),
            daysRemaining:   ud.integer(forKey: "widget.daysRemaining"),
            avgScore:        ud.integer(forKey: "widget.avgScore"),
            bestStreak:      ud.integer(forKey: "widget.bestStreak"),
            ghostLevel:      ud.string(forKey: "widget.ghostLevel") ?? "CIVILIAN",
            freezeCount:     ud.integer(forKey: "widget.freezeCount"),
            momentumUp:      ud.bool(forKey: "widget.momentumBuilding"),
            morningDone:     ud.bool(forKey: "widget.morningDone"),
            nightDone:       ud.bool(forKey: "widget.nightDone"),
            todayScore:      ud.integer(forKey: "widget.todayScore"),
            last7Scores:     ud.array(forKey: "widget.last7Scores") as? [Int] ?? [],
            runName:         ud.string(forKey: "widget.runName") ?? "90 DAY RUN"
        )
    }
}

struct WidgetSnapshot {
    let streak: Int
    let dayNumber: Int
    let daysRemaining: Int
    let avgScore: Int
    let bestStreak: Int
    let ghostLevel: String
    let freezeCount: Int
    let momentumUp: Bool
    let morningDone: Bool
    let nightDone: Bool
    let todayScore: Int
    let last7Scores: [Int]
    let runName: String

    static var placeholder: WidgetSnapshot {
        WidgetSnapshot(streak: 7, dayNumber: 23, daysRemaining: 67, avgScore: 74,
                       bestStreak: 12, ghostLevel: "GHOST", freezeCount: 1,
                       momentumUp: true, morningDone: true, nightDone: false,
                       todayScore: 0, last7Scores: [80, 0, 75, 90, 60, 85, 70],
                       runName: "SUMMER RUN")
    }
}
