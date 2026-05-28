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
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            Text(run.name.uppercased())
                                .font(GGFonts.label)
                                .foregroundStyle(GGColors.textSecondary)
                                .tightTracking()
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 64)

                        // Progress ring
                        GGProgressRing(
                            progress: run.progressFraction,
                            dayNumber: run.dayNumber,
                            totalDays: run.targetDays
                        )

                        // Streak
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(run.currentStreak > 0 ? GGColors.accent : GGColors.textTertiary)
                            Text("\(run.currentStreak) DAY STREAK")
                                .font(GGFonts.label)
                                .foregroundStyle(run.currentStreak > 0 ? GGColors.accent : GGColors.textTertiary)
                                .tightTracking()
                        }

                        Spacer().frame(height: 4)

                        // Discipline + momentum
                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("DISCIPLINE")
                                    .font(GGFonts.label)
                                    .foregroundStyle(GGColors.textSecondary)
                                    .tightTracking()
                                Text("\(run.averageDisciplineScore)")
                                    .font(GGFonts.counterSmall)
                                    .foregroundStyle(GGColors.textPrimary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("7 DAYS")
                                    .font(GGFonts.label)
                                    .foregroundStyle(GGColors.textSecondary)
                                    .tightTracking()
                                GGMomentumBar(scores: run.last7DayScores)
                            }
                        }
                        .ggCard()
                        .padding(.horizontal, 24)

                        // Check-in buttons
                        HStack(spacing: 12) {
                            CheckInCard(
                                title: "MORNING",
                                isDone: todayEntryIfExists?.morningCheckInCompleted == true,
                                action: { showMorning = true }
                            )
                            CheckInCard(
                                title: "TONIGHT",
                                isDone: todayEntryIfExists?.nightCheckInCompleted == true,
                                action: { showNight = true }
                            )
                        }
                        .padding(.horizontal, 24)

                        // Why statement
                        if !run.why.isEmpty {
                            Text(run.why)
                                .font(GGFonts.caption)
                                .foregroundStyle(GGColors.textTertiary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .padding(.horizontal, 32)
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
                VStack(spacing: 16) {
                    Text("No active run.")
                        .font(GGFonts.headline)
                        .foregroundStyle(GGColors.textSecondary)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

private struct CheckInCard: View {
    let title: String
    let isDone: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(GGFonts.label)
                        .foregroundStyle(GGColors.textSecondary)
                        .tightTracking()
                    Spacer()
                    Circle()
                        .fill(isDone ? GGColors.accent : GGColors.border)
                        .frame(width: 7, height: 7)
                }
                Text(isDone ? "Done" : "Pending")
                    .font(GGFonts.bodyMedium)
                    .foregroundStyle(isDone ? GGColors.accent : GGColors.textPrimary)
            }
            .ggCard()
        }
        .buttonStyle(.plain)
    }
}
