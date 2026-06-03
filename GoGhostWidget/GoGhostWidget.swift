import WidgetKit
import SwiftUI

// MARK: - Timeline provider

struct GoGhostProvider: TimelineProvider {
    private static let suiteName = "group.com.hxndrd.goghost"
    private static var ud: UserDefaults { UserDefaults(suiteName: suiteName) ?? .standard }

    func placeholder(in context: Context) -> GoGhostEntry {
        GoGhostEntry(date: Date(), snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (GoGhostEntry) -> Void) {
        completion(GoGhostEntry(date: Date(), snapshot: readSnapshot()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GoGhostEntry>) -> Void) {
        let entry = GoGhostEntry(date: Date(), snapshot: readSnapshot())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func readSnapshot() -> WidgetSnapshot {
        let ud = Self.ud
        return WidgetSnapshot(
            streak:        ud.integer(forKey: "widget.streak"),
            dayNumber:     ud.integer(forKey: "widget.dayNumber"),
            daysRemaining: ud.integer(forKey: "widget.daysRemaining"),
            avgScore:      ud.integer(forKey: "widget.avgScore"),
            bestStreak:    ud.integer(forKey: "widget.bestStreak"),
            ghostLevel:    ud.string(forKey: "widget.ghostLevel") ?? "CIVILIAN",
            freezeCount:   ud.integer(forKey: "widget.freezeCount"),
            momentumUp:    ud.bool(forKey: "widget.momentumBuilding"),
            morningDone:   ud.bool(forKey: "widget.morningDone"),
            nightDone:     ud.bool(forKey: "widget.nightDone"),
            todayScore:    ud.integer(forKey: "widget.todayScore"),
            last7Scores:   ud.array(forKey: "widget.last7Scores") as? [Int] ?? [],
            runName:       ud.string(forKey: "widget.runName") ?? "90 DAY RUN"
        )
    }
}

struct GoGhostEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

// MARK: - Widget bundle

@main
struct GoGhostWidgetBundle: WidgetBundle {
    var body: some Widget {
        GoGhostSmallWidget()
        GoGhostMediumWidget()
        GoGhostLockScreenCircularWidget()
        GoGhostLockScreenRectangularWidget()
        GoGhostLockScreenInlineWidget()
    }
}

// MARK: - Small widget (2×2) — Streak + today status

struct GoGhostSmallWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "GoGhostSmall", provider: GoGhostProvider()) { entry in
            SmallWidgetView(entry: entry)
                .containerBackground(Color(hex: "0A0A0A"), for: .widget)
        }
        .configurationDisplayName("Streak")
        .description("Today's streak and check-in status.")
        .supportedFamilies([.systemSmall])
    }
}

struct SmallWidgetView: View {
    let entry: GoGhostEntry
    private var snap: WidgetSnapshot { entry.snapshot }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(snap.runName.uppercased())
                .font(widgetFont(size: 9, weight: .semibold))
                .foregroundStyle(Color(hex: "3C3C3C"))
                .lineLimit(1)
                .padding(.bottom, 8)

            Text("\(snap.streak)")
                .font(widgetFont(size: 56, weight: .regular, design: .default))
                .foregroundStyle(snap.streak > 0 ? Color(hex: "22C55E") : Color(hex: "3C3C3C"))
                .minimumScaleFactor(0.6)

            Text("DAY STREAK")
                .font(widgetFont(size: 9, weight: .semibold))
                .foregroundStyle(Color(hex: "888888"))

            Spacer()

            HStack(spacing: 8) {
                statusDot(done: snap.morningDone, label: "AM")
                statusDot(done: snap.nightDone,   label: "PM")
            }
        }
        .padding(16)
    }

    private func statusDot(done: Bool, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(done ? Color(hex: "22C55E") : Color(hex: "2C2C2C"))
                .frame(width: 6, height: 6)
            Text(label)
                .font(widgetFont(size: 9, weight: .semibold))
                .foregroundStyle(done ? Color(hex: "22C55E") : Color(hex: "3C3C3C"))
        }
    }
}

// MARK: - Medium widget (2×4) — Streak + 7-day bar + day number

struct GoGhostMediumWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "GoGhostMedium", provider: GoGhostProvider()) { entry in
            MediumWidgetView(entry: entry)
                .containerBackground(Color(hex: "0A0A0A"), for: .widget)
        }
        .configurationDisplayName("Dashboard")
        .description("Streak, momentum, and today's status.")
        .supportedFamilies([.systemMedium])
    }
}

struct MediumWidgetView: View {
    let entry: GoGhostEntry
    private var snap: WidgetSnapshot { entry.snapshot }

    var body: some View {
        HStack(spacing: 0) {
            // Left: streak + level
            VStack(alignment: .leading, spacing: 4) {
                Text(snap.runName.uppercased())
                    .font(widgetFont(size: 9, weight: .semibold))
                    .foregroundStyle(Color(hex: "3C3C3C"))
                    .lineLimit(1)

                Spacer()

                Text("\(snap.streak)")
                    .font(widgetFont(size: 52, weight: .regular))
                    .foregroundStyle(snap.streak > 0 ? Color(hex: "22C55E") : Color(hex: "3C3C3C"))

                Text("DAY STREAK")
                    .font(widgetFont(size: 9, weight: .semibold))
                    .foregroundStyle(Color(hex: "888888"))

                Spacer()

                Text(snap.ghostLevel)
                    .font(widgetFont(size: 9, weight: .semibold))
                    .foregroundStyle(Color(hex: "888888"))
            }
            .padding(16)
            .frame(maxHeight: .infinity)

            Rectangle()
                .fill(Color(hex: "2C2C2C"))
                .frame(width: 1)

            // Right: day, bar, status
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("DAY \(snap.dayNumber)")
                        .font(widgetFont(size: 11, weight: .semibold))
                        .foregroundStyle(Color.white)
                    Spacer()
                    Text("\(snap.daysRemaining) LEFT")
                        .font(widgetFont(size: 9, weight: .semibold))
                        .foregroundStyle(Color(hex: "3C3C3C"))
                }

                // 7-day bar
                HStack(spacing: 3) {
                    ForEach(snap.last7Scores.indices, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(barColor(snap.last7Scores[i], isLast: i == snap.last7Scores.count - 1))
                            .frame(maxWidth: .infinity)
                            .frame(height: 20)
                    }
                }

                Spacer()

                HStack(spacing: 12) {
                    checkInPill(label: "MORNING", done: snap.morningDone)
                    checkInPill(label: "TONIGHT", done: snap.nightDone,
                                score: snap.nightDone ? snap.todayScore : nil)
                }
            }
            .padding(14)
            .frame(maxHeight: .infinity)
        }
    }

    private func barColor(_ score: Int, isLast: Bool) -> Color {
        if score == 0 { return isLast ? Color(hex: "22C55E").opacity(0.3) : Color(hex: "2C2C2C") }
        if score >= 80 { return Color(hex: "22C55E") }
        if score >= 50 { return Color(hex: "22C55E").opacity(0.45) }
        return Color(hex: "EF4444").opacity(0.5)
    }

    private func checkInPill(label: String, done: Bool, score: Int? = nil) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(done ? Color(hex: "22C55E") : Color(hex: "2C2C2C"))
                .frame(width: 5, height: 5)
            Text(label)
                .font(widgetFont(size: 9, weight: .semibold))
                .foregroundStyle(done ? Color(hex: "22C55E") : Color(hex: "3C3C3C"))
            if let score, done {
                Text("/ \(score)")
                    .font(widgetFont(size: 9, weight: .regular))
                    .foregroundStyle(Color(hex: "888888"))
            }
        }
    }
}

// MARK: - Lock screen: circular

struct GoGhostLockScreenCircularWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "GoGhostCircular", provider: GoGhostProvider()) { entry in
            CircularWidgetView(entry: entry)
                .containerBackground(Color.clear, for: .widget)
        }
        .configurationDisplayName("Streak Circle")
        .description("Your current streak.")
        .supportedFamilies([.accessoryCircular])
    }
}

struct CircularWidgetView: View {
    let entry: GoGhostEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text("\(entry.snapshot.streak)")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                Text("STREAK")
                    .font(.system(size: 7, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Lock screen: rectangular

struct GoGhostLockScreenRectangularWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "GoGhostRectangular", provider: GoGhostProvider()) { entry in
            RectangularWidgetView(entry: entry)
                .containerBackground(Color.clear, for: .widget)
        }
        .configurationDisplayName("Day + Streak")
        .description("Your current day and streak.")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct RectangularWidgetView: View {
    let entry: GoGhostEntry
    private var snap: WidgetSnapshot { entry.snapshot }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("DAY \(snap.dayNumber) / 90")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
            HStack(spacing: 6) {
                Circle()
                    .fill(snap.morningDone ? Color(hex: "22C55E") : Color.secondary)
                    .frame(width: 5, height: 5)
                Circle()
                    .fill(snap.nightDone ? Color(hex: "22C55E") : Color.secondary)
                    .frame(width: 5, height: 5)
                Text("\(snap.streak) DAY STREAK")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            Text(snap.ghostLevel)
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - Lock screen: inline

struct GoGhostLockScreenInlineWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "GoGhostInline", provider: GoGhostProvider()) { entry in
            InlineWidgetView(entry: entry)
                .containerBackground(Color.clear, for: .widget)
        }
        .configurationDisplayName("Inline Status")
        .description("Day and streak in one line.")
        .supportedFamilies([.accessoryInline])
    }
}

struct InlineWidgetView: View {
    let entry: GoGhostEntry

    var body: some View {
        Text("DAY \(entry.snapshot.dayNumber)  ·  \(entry.snapshot.streak) STREAK")
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
    }
}

// MARK: - Helpers

private func widgetFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .monospaced) -> Font {
    .system(size: size, weight: weight, design: design)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >>  8) & 0xFF) / 255
        let b = Double((int >>  0) & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
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
