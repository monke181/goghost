import SwiftUI

// MARK: - Main ceremony view

struct RunCompleteView: View {
    let run: Run
    let onClose: () -> Void

    @State private var page = 0
    @State private var confettiID = UUID()   // changing this re-spawns confetti

    private let totalCards = 6
    // Confetti fires on intro (0) and final summary (5) cards
    private let celebrationCards: Set<Int> = [0, 5]

    var body: some View {
        ZStack {
            GGColors.background.ignoresSafeArea()

            TabView(selection: $page) {
                ForEach(0..<totalCards, id: \.self) { i in
                    cardShell(index: i)
                        .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Confetti overlay — only on celebration cards
            if celebrationCards.contains(page) {
                GGConfettiView()
                    .id(confettiID)
                    .transition(.opacity)
            }

            // Dot indicators
            VStack {
                Spacer()
                HStack(spacing: 6) {
                    ForEach(0..<totalCards, id: \.self) { i in
                        Circle()
                            .fill(i == page ? GGColors.textPrimary : GGColors.border)
                            .frame(width: 4, height: 4)
                    }
                }
                .padding(.bottom, 28)
            }
        }
        .onChange(of: page) { _, newPage in
            if celebrationCards.contains(newPage) {
                confettiID = UUID()
            }
        }
    }

    // MARK: - Card shell (chrome + content + nav)

    @ViewBuilder
    private func cardShell(index: Int) -> some View {
        ZStack {
            GGColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Text("\(index + 1) / \(totalCards)")
                        .font(GGFonts.label)
                        .foregroundStyle(GGColors.textTertiary)
                        .tightTracking()
                    Spacer()
                    Button {
                        shareCard(at: index)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(GGColors.textSecondary)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 64)

                Spacer()

                cardContent(index: index)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 32)

                Spacer()

                // Navigation
                if index == totalCards - 1 {
                    GGPrimaryButton(title: "CLOSE THE RUN", action: onClose)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 60)
                } else {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) { page = index + 1 }
                    } label: {
                        Text("NEXT  →")
                            .font(GGFonts.label)
                            .foregroundStyle(GGColors.textSecondary)
                            .tightTracking()
                    }
                    .padding(.bottom, 60)
                }
            }
        }
    }

    // MARK: - Card content dispatcher

    @ViewBuilder
    private func cardContent(index: Int) -> some View {
        switch index {
        case 0: IntroCardContent(run: run)
        case 1: DisciplineCardContent(avg: run.averageDisciplineScore, best: run.allTimeBestScore)
        case 2: StreakCardContent(best: run.allTimeBestStreak, total: run.totalNightCheckIns)
        case 3: FocusCardContent(totalMinutes: run.totalRunFocusMinutes)
        case 4: LevelCardContent(level: run.ghostLevel)
        default: SummaryCardContent(run: run)
        }
    }

    // MARK: - Share

    @MainActor
    private func shareCard(at index: Int) {
        guard let img = renderToImage(ShareCardWrapper(index: index, run: run)) else { return }
        presentShareSheet(items: [img])
    }
}

// MARK: - Share card wrapper (no chrome, full-bleed for IG)

private struct ShareCardWrapper: View {
    let index: Int
    let run: Run

    var body: some View {
        ZStack {
            Rectangle().fill(GGColors.background)  // no ignoresSafeArea — renderer has no safe area

            VStack(spacing: 0) {
                // Branding header
                HStack {
                    Text("90DAYRUN")
                        .font(GGFonts.label)
                        .foregroundStyle(GGColors.textTertiary)
                        .tightTracking()
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.top, 56)

                Spacer()

                Group {
                    switch index {
                    case 0: IntroCardContent(run: run)
                    case 1: DisciplineCardContent(avg: run.averageDisciplineScore, best: run.allTimeBestScore)
                    case 2: StreakCardContent(best: run.allTimeBestStreak, total: run.totalNightCheckIns)
                    case 3: FocusCardContent(totalMinutes: run.totalRunFocusMinutes)
                    case 4: LevelCardContent(level: run.ghostLevel)
                    default: SummaryCardContent(run: run)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)

                Spacer()

                // Branding footer
                HStack {
                    Spacer()
                    Text("90DAYRUN.APP")
                        .font(GGFonts.caption)
                        .foregroundStyle(GGColors.textTertiary)
                        .tightTracking()
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }
}

// MARK: - Individual card content views

struct IntroCardContent: View {
    let run: Run

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("THE RUN")
                .font(GGFonts.label)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()

            Text("IS\nCOMPLETE.")
                .font(GGFonts.hero)
                .foregroundStyle(GGColors.accent)
                .lineSpacing(2)

            Rectangle().fill(GGColors.border).frame(height: 1).padding(.top, 4)

            Text(run.name.uppercased())
                .font(GGFonts.bodyMed)
                .foregroundStyle(GGColors.textPrimary)
                .tightTracking()

            Text("\(run.startDate.formatted(.dateTime.month(.abbreviated).day().year()).uppercased()) → \(run.endDate.formatted(.dateTime.month(.abbreviated).day().year()).uppercased())")
                .font(GGFonts.caption)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()

            Text("90 DAYS.")
                .font(GGFonts.display)
                .foregroundStyle(GGColors.textPrimary)
                .padding(.top, 4)
        }
    }
}

struct DisciplineCardContent: View {
    let avg: Int
    let best: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DISCIPLINE")
                .font(GGFonts.label)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()

            Text("\(avg)")
                .font(GGFonts.hero)
                .foregroundStyle(scoreColor(avg))

            Text("AVERAGE SCORE")
                .font(GGFonts.bodyMed)
                .foregroundStyle(GGColors.textSecondary)
                .tightTracking()

            Rectangle().fill(GGColors.border).frame(height: 1).padding(.top, 8)

            HStack(spacing: 4) {
                Text("PERSONAL BEST:")
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()
                Text("\(best)")
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.accent)
                    .tightTracking()
            }
        }
    }

    private func scoreColor(_ s: Int) -> Color {
        if s >= 80 { return GGColors.accent }
        if s >= 50 { return GGColors.textPrimary }
        return GGColors.danger
    }
}

struct StreakCardContent: View {
    let best: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("STREAK")
                .font(GGFonts.label)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()

            Text("\(best)")
                .font(GGFonts.hero)
                .foregroundStyle(GGColors.accent)

            Text("DAY BEST STREAK")
                .font(GGFonts.bodyMed)
                .foregroundStyle(GGColors.textSecondary)
                .tightTracking()

            Rectangle().fill(GGColors.border).frame(height: 1).padding(.top, 8)

            HStack(spacing: 4) {
                Text("TOTAL SESSIONS:")
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()
                Text("\(total)")
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textPrimary)
                    .tightTracking()
            }
        }
    }
}

struct FocusCardContent: View {
    let totalMinutes: Int

    private var hours: Int { totalMinutes / 60 }
    private var mins: Int  { totalMinutes % 60 }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FOCUS")
                .font(GGFonts.label)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(hours)")
                    .font(GGFonts.hero)
                    .foregroundStyle(GGColors.textPrimary)
                Text("HR")
                    .font(GGFonts.display)
                    .foregroundStyle(GGColors.textTertiary)
                if mins > 0 {
                    Text("\(mins)")
                        .font(GGFonts.display)
                        .foregroundStyle(GGColors.textPrimary)
                    Text("MIN")
                        .font(GGFonts.headline)
                        .foregroundStyle(GGColors.textTertiary)
                }
            }

            Text("LOCKED IN")
                .font(GGFonts.bodyMed)
                .foregroundStyle(GGColors.textSecondary)
                .tightTracking()

            Rectangle().fill(GGColors.border).frame(height: 1).padding(.top, 8)

            Text("Ghost Mode sessions completed.")
                .font(GGFonts.caption)
                .foregroundStyle(GGColors.textTertiary)
        }
    }
}

struct LevelCardContent: View {
    let level: GhostLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LEVEL UNLOCKED")
                .font(GGFonts.label)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()

            Text(level.rawValue)
                .font(GGFonts.hero)
                .foregroundStyle(GGColors.accent)

            Rectangle().fill(GGColors.border).frame(height: 1).padding(.top, 8)

            Text(level.tagline)
                .font(GGFonts.body)
                .foregroundStyle(GGColors.textSecondary)
        }
    }
}

struct SummaryCardContent: View {
    let run: Run

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(run.name.uppercased())
                .font(GGFonts.label)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()

            Text("90\nDAYS\nDONE.")
                .font(GGFonts.display)
                .foregroundStyle(GGColors.textPrimary)
                .lineSpacing(2)

            Rectangle().fill(GGColors.border).frame(height: 1)

            VStack(spacing: 0) {
                summaryRow(label: "AVG SCORE",  value: "\(run.averageDisciplineScore)")
                Rectangle().fill(GGColors.border).frame(height: 1)
                summaryRow(label: "BEST STREAK", value: "\(run.allTimeBestStreak) DAYS")
                Rectangle().fill(GGColors.border).frame(height: 1)
                summaryRow(label: "FOCUS",       value: "\(run.totalRunFocusMinutes / 60)H \(run.totalRunFocusMinutes % 60)M")
                Rectangle().fill(GGColors.border).frame(height: 1)
                summaryRow(label: "LEVEL",       value: run.ghostLevel.rawValue)
            }
            .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
        }
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(GGFonts.label)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()
            Spacer()
            Text(value)
                .font(GGFonts.bodyMed)
                .foregroundStyle(GGColors.textPrimary)
                .tightTracking()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

