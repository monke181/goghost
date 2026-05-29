import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Run> { $0.isActive }) private var runs: [Run]

    @State private var showMorning = false
    @State private var showNight = false

    private var run: Run? { runs.first }

    private var todayEntryIfExists: DailyEntry? {
        guard let run else { return nil }
        let today = Calendar.current.startOfDay(for: .now)
        return run.entries.first(where: { Calendar.current.startOfDay(for: $0.date) == today })
    }

    var body: some View {
        ZStack {
            GGColors.background.ignoresSafeArea()

            if let run {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        // Header
                        HStack {
                            Text(run.name.uppercased())
                                .font(GGFonts.label)
                                .foregroundStyle(GGColors.textTertiary)
                                .tightTracking()
                                .lineLimit(1)
                            Spacer()
                            Text("\(run.daysRemaining) DAYS LEFT")
                                .font(GGFonts.label)
                                .foregroundStyle(GGColors.textTertiary)
                                .tightTracking()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 64)
                        .padding(.bottom, 32)

                        // Progress ring
                        GGProgressRing(
                            progress: run.progressFraction,
                            dayNumber: run.dayNumber,
                            totalDays: run.targetDays
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)

                        // Streak
                        HStack {
                            Spacer()
                            Text(run.currentStreak > 0 ? "\(run.currentStreak) DAY STREAK" : "NO STREAK")
                                .font(GGFonts.label)
                                .foregroundStyle(run.currentStreak > 0 ? GGColors.accent : GGColors.textTertiary)
                                .tightTracking()
                            Spacer()
                        }
                        .padding(.bottom, 32)

                        // Divider
                        Rectangle().fill(GGColors.border).frame(height: 1).padding(.horizontal, 24)

                        // Discipline + momentum row
                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("DISCIPLINE")
                                    .font(GGFonts.label)
                                    .foregroundStyle(GGColors.textTertiary)
                                    .tightTracking()
                                Text("\(run.averageDisciplineScore)")
                                    .font(GGFonts.counterSmall)
                                    .foregroundStyle(GGColors.textPrimary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 6) {
                                Text("LAST 7")
                                    .font(GGFonts.label)
                                    .foregroundStyle(GGColors.textTertiary)
                                    .tightTracking()
                                GGMomentumBar(scores: run.last7DayScores)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)

                        Rectangle().fill(GGColors.border).frame(height: 1).padding(.horizontal, 24)

                        // Check-ins
                        HStack(spacing: 0) {
                            CheckInRow(
                                label: "MORNING",
                                status: todayEntryIfExists?.morningCheckInCompleted == true ? "DONE" : "PENDING",
                                isDone: todayEntryIfExists?.morningCheckInCompleted == true,
                                action: { showMorning = true }
                            )
                            Rectangle().fill(GGColors.border).frame(width: 1)
                            CheckInRow(
                                label: "TONIGHT",
                                status: todayEntryIfExists?.nightCheckInCompleted == true ? "DONE" : "PENDING",
                                isDone: todayEntryIfExists?.nightCheckInCompleted == true,
                                action: { showNight = true }
                            )
                        }
                        .frame(height: 80)
                        .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1).padding(.horizontal, 24))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)

                        Rectangle().fill(GGColors.border).frame(height: 1).padding(.horizontal, 24)

                        // Why statement
                        if !run.why.isEmpty {
                            Text(run.why)
                                .font(GGFonts.caption)
                                .foregroundStyle(GGColors.textTertiary)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 20)
                                .lineLimit(3)
                        }

                        Spacer().frame(height: 100)
                    }
                }
                .scrollIndicators(.hidden)
                .fullScreenCover(isPresented: $showMorning) {
                    MorningCheckInView(run: run)
                }
                .fullScreenCover(isPresented: $showNight) {
                    NightCheckInView(run: run)
                }
            } else {
                VStack {
                    Text("NO ACTIVE RUN")
                        .font(GGFonts.label)
                        .foregroundStyle(GGColors.textTertiary)
                        .tightTracking()
                }
            }
        }
        .navigationBarHidden(true)
    }
}

private struct CheckInRow: View {
    let label: String
    let status: String
    let isDone: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()
                Text(status)
                    .font(GGFonts.bodyMed)
                    .foregroundStyle(isDone ? GGColors.accent : GGColors.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }
}
