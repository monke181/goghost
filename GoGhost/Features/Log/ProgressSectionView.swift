import SwiftUI
import Charts
import SwiftData

struct ProgressSectionView: View {
    @Query(
        filter: #Predicate<DailyEntry> { $0.nightCheckInCompleted },
        sort: \DailyEntry.date,
        order: .forward
    ) private var entries: [DailyEntry]

    @Query(filter: #Predicate<Run> { $0.isActive }) private var runs: [Run]
    private var run: Run? { runs.first }

    var body: some View {
        Group {
            if entries.isEmpty {
                LogEmptyState(
                    title: "NO DATA YET",
                    subtitle: "Finish your first night check-in to see your progress."
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if let run { statsHeader(run: run) }

                        Rectangle().fill(GGColors.border).frame(height: 1)
                            .padding(.horizontal, 24)

                        scoreChart
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                            .padding(.bottom, 32)

                        Spacer().frame(height: 120)
                    }
                    .padding(.top, 4)
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    // MARK: - Stats header

    private func statsHeader(run: Run) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                statCell(label: "AVG SCORE", value: "\(run.averageDisciplineScore)")
                Rectangle().fill(GGColors.border).frame(width: 1)
                statCell(label: "BEST SCORE", value: "\(run.allTimeBestScore)")
                Rectangle().fill(GGColors.border).frame(width: 1)
                statCell(label: "FOCUS",  value: "\(run.totalRunFocusMinutes / 60)H")
            }
            .frame(height: 72)
            .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1).padding(.horizontal, 24))
            .padding(.horizontal, 24)

            HStack(spacing: 0) {
                statCell(label: "SESSIONS", value: "\(run.totalNightCheckIns)")
                Rectangle().fill(GGColors.border).frame(width: 1)
                statCell(label: "BEST STREAK", value: "\(run.allTimeBestStreak) DAYS")
                Rectangle().fill(GGColors.border).frame(width: 1)
                statCell(label: "LEVEL", value: run.ghostLevel.rawValue)
            }
            .frame(height: 72)
            .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1).padding(.horizontal, 24))
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 20)
    }

    private func statCell(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(GGFonts.counterSmall)
                .foregroundStyle(GGColors.textPrimary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(label)
                .font(GGFonts.label)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
    }

    // MARK: - Score chart

    private var scoreChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DISCIPLINE OVER TIME")
                .font(GGFonts.label)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()

            Chart {
                // Locked-in zone shading
                RectangleMark(
                    xStart: .value("", 0),
                    xEnd:   .value("", 90),
                    yStart: .value("", 80),
                    yEnd:   .value("", 100)
                )
                .foregroundStyle(GGColors.accent.opacity(0.06))

                ForEach(entries) { entry in
                    // Area fill
                    AreaMark(
                        x: .value("Day", entry.dayNumber),
                        yStart: .value("", 0),
                        yEnd:   .value("Score", entry.disciplineScore)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [GGColors.accent.opacity(0.15), GGColors.accent.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    // Line
                    LineMark(
                        x: .value("Day", entry.dayNumber),
                        y: .value("Score", entry.disciplineScore)
                    )
                    .foregroundStyle(GGColors.accent.opacity(0.7))
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                    .interpolationMethod(.catmullRom)

                    // Point
                    PointMark(
                        x: .value("Day", entry.dayNumber),
                        y: .value("Score", entry.disciplineScore)
                    )
                    .foregroundStyle(pointColor(entry.disciplineScore))
                    .symbolSize(18)
                }

                // Reference line at 80
                RuleMark(y: .value("Locked In", 80))
                    .foregroundStyle(GGColors.border)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .annotation(position: .trailing, alignment: .center) {
                        Text("80")
                            .font(GGFonts.caption)
                            .foregroundStyle(GGColors.textTertiary)
                    }
            }
            .frame(height: 220)
            .chartYScale(domain: 0...100)
            .chartXScale(domain: 1...90)
            .chartXAxis {
                AxisMarks(values: [1, 30, 60, 90]) { value in
                    AxisGridLine()
                        .foregroundStyle(GGColors.border.opacity(0.4))
                    AxisValueLabel {
                        if let v = value.as(Int.self) {
                            Text("D\(v)")
                                .font(GGFonts.caption)
                                .foregroundStyle(GGColors.textTertiary)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 50, 80, 100]) { value in
                    AxisGridLine()
                        .foregroundStyle(GGColors.border.opacity(0.4))
                    AxisValueLabel {
                        if let v = value.as(Int.self) {
                            Text("\(v)")
                                .font(GGFonts.caption)
                                .foregroundStyle(GGColors.textTertiary)
                        }
                    }
                }
            }
            .chartBackground { _ in GGColors.background }

            // Legend
            HStack(spacing: 16) {
                legendDot(color: GGColors.accent, label: "LOCKED IN (80+)")
                legendDot(color: GGColors.textPrimary, label: "SOLID (50–79)")
                legendDot(color: GGColors.danger, label: "OFF (<50)")
            }
        }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label)
                .font(GGFonts.caption)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()
        }
    }

    private func pointColor(_ s: Int) -> Color {
        if s >= 80 { return GGColors.accent }
        if s >= 50 { return GGColors.textPrimary }
        return GGColors.danger
    }
}
