import SwiftUI

// MARK: - Data model

struct WeekSummary {
    struct DayCell: Identifiable {
        let id = UUID()
        let weekday: String   // "MON", "TUE", …
        let date: Date
        let score: Int        // 0 = no night check-in
        let focusMinutes: Int
    }

    let weekNumber: Int
    let startDate: Date
    let endDate: Date
    let dayCells: [DayCell]  // always 7, Mon → Sun
    let avgScore: Int
    let bestScore: Int
    let totalFocusMinutes: Int
    let completedDays: Int
}

// MARK: - Full screen recap view

struct WeeklyRecapView: View {
    let summary: WeekSummary
    let onDone: () -> Void

    @State private var showConfetti = false
    @State private var shareable: ShareableImage?

    var body: some View {
        ZStack {
            GGColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header bar
                HStack {
                    Spacer()
                    Button(action: onDone) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(GGColors.textTertiary)
                            .padding(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 0) {
                        WeeklyRecapCard(summary: summary)
                            .padding(.horizontal, 32)
                            .padding(.top, 12)
                            .padding(.bottom, 28)

                        // Actions
                        VStack(spacing: 12) {
                            if let shareable {
                                ShareLink(
                                    item: shareable,
                                    preview: SharePreview(
                                        "Week \(summary.weekNumber) Wrapped",
                                        image: Image(uiImage: shareable.image)
                                    )
                                ) {
                                    shareLabel
                                }
                                .buttonStyle(.plain)
                            } else {
                                shareLabel.opacity(0.4)
                            }

                            GGPrimaryButton(title: "DONE", action: onDone)
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 56)
                    }
                }
                .scrollIndicators(.hidden)
            }

            if showConfetti {
                GGConfettiView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showConfetti = true }
            }
            // Pre-render the share image so ShareLink has it ready.
            if shareable == nil, let img = renderToImage(WeeklyShareCard(summary: summary)) {
                shareable = ShareableImage(image: img, filename: "90dayrun-week-\(summary.weekNumber).png")
            }
        }
    }

    private var shareLabel: some View {
        HStack(spacing: 8) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 12, weight: .medium))
            Text("SHARE THIS WEEK")
                .font(GGFonts.label)
                .tightTracking()
        }
        .foregroundStyle(GGColors.textPrimary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
    }
}

// MARK: - Card content (shared between display and ImageRenderer)

struct WeeklyRecapCard: View {
    let summary: WeekSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title block
            VStack(alignment: .leading, spacing: 6) {
                Text("WEEK \(summary.weekNumber)")
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()

                Text("WRAPPED.")
                    .font(GGFonts.display)
                    .foregroundStyle(GGColors.textPrimary)

                Text(
                    "\(summary.startDate.formatted(.dateTime.month(.abbreviated).day()).uppercased())  →  \(summary.endDate.formatted(.dateTime.month(.abbreviated).day()).uppercased())"
                )
                .font(GGFonts.caption)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()
            }

            Rectangle().fill(GGColors.border).frame(height: 1)

            // 7-day bar chart
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(summary.dayCells) { cell in
                    VStack(spacing: 6) {
                        // Score label
                        Text(cell.score > 0 ? "\(cell.score)" : "—")
                            .font(GGFonts.caption)
                            .foregroundStyle(cell.score > 0 ? barColor(cell.score) : GGColors.textTertiary)
                            .tightTracking()
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)

                        // Bar
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .fill(GGColors.surface)
                                .frame(height: 88)
                            if cell.score > 0 {
                                Rectangle()
                                    .fill(barColor(cell.score))
                                    .frame(height: max(4, 88 * CGFloat(cell.score) / 100))
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: cell.score)
                            }
                        }
                        .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
                        .frame(maxWidth: .infinity)

                        // Weekday
                        Text(cell.weekday)
                            .font(GGFonts.caption)
                            .foregroundStyle(GGColors.textTertiary)
                            .tightTracking()
                    }
                }
            }

            Rectangle().fill(GGColors.border).frame(height: 1)

            // Stats grid — 2×2
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    statBlock("AVG SCORE",  "\(summary.avgScore)",
                              color: scoreColor(summary.avgScore))
                    Rectangle().fill(GGColors.border).frame(width: 1)
                    statBlock("BEST DAY",   "\(summary.bestScore)",
                              color: scoreColor(summary.bestScore))
                }
                Rectangle().fill(GGColors.border).frame(height: 1)
                HStack(spacing: 0) {
                    statBlock("FOCUS",
                              "\(summary.totalFocusMinutes / 60)H \(summary.totalFocusMinutes % 60)M",
                              color: GGColors.textPrimary)
                    Rectangle().fill(GGColors.border).frame(width: 1)
                    statBlock("COMPLETED",  "\(summary.completedDays) / 7",
                              color: summary.completedDays == 7 ? GGColors.accent : GGColors.textPrimary)
                }
            }
            .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
        }
    }

    private func statBlock(_ label: String, _ value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(GGFonts.counterSmall)
                .foregroundStyle(color)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text(label)
                .font(GGFonts.label)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
    }

    private func barColor(_ s: Int) -> Color {
        if s >= 80 { return GGColors.accent }
        if s >= 50 { return GGColors.textPrimary }
        return GGColors.danger
    }

    private func scoreColor(_ s: Int) -> Color { barColor(s) }
}

// MARK: - IG story share card (no buttons, branded)

private struct WeeklyShareCard: View {
    let summary: WeekSummary

    var body: some View {
        ZStack {
            Rectangle().fill(GGColors.background)  // no ignoresSafeArea — renderer has no safe area

            VStack(spacing: 0) {
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

                WeeklyRecapCard(summary: summary)
                    .padding(.horizontal, 32)

                Spacer()

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
