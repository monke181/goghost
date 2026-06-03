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
                        scoreChart.padding(.horizontal, 24).padding(.vertical, 24)
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
            statRow([
                ("AVG SCORE",  "\(run.averageDisciplineScore)"),
                ("BEST SCORE", "\(run.allTimeBestScore)"),
                ("FOCUS",      "\(run.totalRunFocusMinutes / 60)H \(run.totalRunFocusMinutes % 60)M")
            ])
            Rectangle().fill(GGColors.border).frame(height: 1)
            statRow([
                ("SESSIONS",     "\(run.totalNightCheckIns)"),
                ("BEST STREAK",  "\(run.allTimeBestStreak)"),
                ("LEVEL",        run.ghostLevel.rawValue)
            ])
        }
        .padding(.vertical, 20)
    }

    private func statRow(_ cells: [(String, String)]) -> some View {
        HStack(spacing: 0) {
            ForEach(cells.indices, id: \.self) { i in
                statCell(label: cells[i].0, value: cells[i].1)
                if i < cells.count - 1 {
                    Rectangle().fill(GGColors.border).frame(width: 1)
                }
            }
        }
        .frame(height: 68)
        // Stroke only wraps the HStack — no double-padding
        .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
        .padding(.horizontal, 24)
    }

    private func statCell(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(GGFonts.counterSmall)
                .foregroundStyle(GGColors.textPrimary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text(label)
                .font(GGFonts.label)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
    }

    // MARK: - Score chart

    private var scoreChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DISCIPLINE OVER TIME")
                .font(GGFonts.label)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()

            Chart {
                // Soft green zone above 80
                RectangleMark(
                    xStart: .value("", 1),
                    xEnd:   .value("", 90),
                    yStart: .value("", 80),
                    yEnd:   .value("", 100)
                )
                .foregroundStyle(GGColors.accent.opacity(0.05))

                ForEach(entries) { entry in
                    AreaMark(
                        x:      .value("Day",   entry.dayNumber),
                        yStart: .value("",      0),
                        yEnd:   .value("Score", entry.disciplineScore)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [GGColors.accent.opacity(0.18), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Day",   entry.dayNumber),
                        y: .value("Score", entry.disciplineScore)
                    )
                    .foregroundStyle(GGColors.accent.opacity(0.75))
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Day",   entry.dayNumber),
                        y: .value("Score", entry.disciplineScore)
                    )
                    .foregroundStyle(pointColor(entry.disciplineScore))
                    .symbolSize(16)
                }

                RuleMark(y: .value("80", 80))
                    .foregroundStyle(GGColors.border)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
            }
            .frame(height: 200)
            .chartYScale(domain: 0...100)
            .chartXScale(domain: 1...90)
            .chartXAxis {
                AxisMarks(values: [1, 30, 60, 90]) { value in
                    AxisGridLine().foregroundStyle(GGColors.border.opacity(0.4))
                    AxisValueLabel {
                        if let v = value.as(Int.self) {
                            Text("D\(v)").font(GGFonts.caption).foregroundStyle(GGColors.textTertiary)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 50, 80, 100]) { value in
                    AxisGridLine().foregroundStyle(GGColors.border.opacity(0.4))
                    AxisValueLabel {
                        if let v = value.as(Int.self) {
                            Text("\(v)").font(GGFonts.caption).foregroundStyle(GGColors.textTertiary)
                        }
                    }
                }
            }
            .chartBackground { _ in GGColors.background }

            // Legend
            HStack(spacing: 14) {
                legendDot(GGColors.accent,       "LOCKED IN (80+)")
                legendDot(GGColors.textPrimary,  "SOLID (50–79)")
                legendDot(GGColors.danger,       "OFF (<50)")
            }
        }
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 5, height: 5)
            Text(label).font(GGFonts.caption).foregroundStyle(GGColors.textTertiary).tightTracking()
        }
    }

    private func pointColor(_ s: Int) -> Color {
        if s >= 80 { return GGColors.accent }
        if s >= 50 { return GGColors.textPrimary }
        return GGColors.danger
    }
}
