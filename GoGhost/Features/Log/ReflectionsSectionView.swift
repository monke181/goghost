import SwiftUI
import SwiftData

struct ReflectionsSectionView: View {
    @Query(
        filter: #Predicate<DailyEntry> { $0.nightCheckInCompleted },
        sort: \DailyEntry.date,
        order: .reverse
    ) private var entries: [DailyEntry]

    @State private var selected: DailyEntry?

    var body: some View {
        Group {
            if entries.isEmpty {
                LogEmptyState(
                    title: "NO REFLECTIONS YET",
                    subtitle: "Finish a night check-in and it shows up here."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(entries) { entry in
                            Button { selected = entry } label: {
                                ReflectionRow(entry: entry)
                            }
                            .buttonStyle(.plain)

                            Rectangle().fill(GGColors.border).frame(height: 1)
                                .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 4)

                    Spacer().frame(height: 120)
                }
                .scrollIndicators(.hidden)
            }
        }
        .fullScreenCover(item: $selected) { entry in
            ReflectionDetailView(entry: entry)
        }
    }
}

private struct ReflectionRow: View {
    let entry: DailyEntry

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("DAY \(entry.dayNumber)")
                    .font(GGFonts.bodyMed)
                    .foregroundStyle(GGColors.textPrimary)
                    .tightTracking()
                Text(entry.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().year()).uppercased())
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.disciplineScore)")
                    .font(GGFonts.counterSmall)
                    .foregroundStyle(ReflectionStyle.scoreColor(entry.disciplineScore))
                Text("SCORE")
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .contentShape(Rectangle())
    }
}

struct ReflectionDetailView: View {
    let entry: DailyEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            GGColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Text("DAY \(entry.dayNumber)")
                        .font(GGFonts.label)
                        .tightTracking()
                        .foregroundStyle(GGColors.textTertiary)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(GGColors.textTertiary)
                            .padding(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header: date + score
                        HStack(alignment: .firstTextBaseline) {
                            Text(entry.date.formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased())
                                .font(GGFonts.title)
                                .foregroundStyle(GGColors.textPrimary)
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 12)

                        HStack(spacing: 24) {
                            stat(label: "SCORE", value: "\(entry.disciplineScore)", color: ReflectionStyle.scoreColor(entry.disciplineScore))
                            stat(label: "RATING", value: "\(entry.nightScoreRating)/10", color: GGColors.textPrimary)
                            stat(label: "FOCUS", value: "\(entry.totalFocusMinutes)m", color: GGColors.textPrimary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 24)

                        Rectangle().fill(GGColors.border).frame(height: 1).padding(.horizontal, 24)

                        field("WHAT YOU DID", entry.nightWins)
                        field("WHAT YOU DIDN'T", entry.nightLosses)
                        field("DISTRACTIONS", entry.nightDistractedBy)
                        field("LESSONS LEARNED", entry.nightLessons)
                        field("TOMORROW MUST DO", entry.nightTomorrowMustDo)
                        field("JOURNAL", entry.nightJournal)
                        field("IMPROVED ON", entry.nightImprovedOn)

                        if !entry.dopamineAvoided.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("STAYED AWAY FROM")
                                    .font(GGFonts.label)
                                    .foregroundStyle(GGColors.textTertiary)
                                    .tightTracking()
                                FlowLayout(spacing: 8) {
                                    ForEach(entry.dopamineAvoided, id: \.self) { item in
                                        Text(item.uppercased())
                                            .font(GGFonts.caption)
                                            .tightTracking()
                                            .foregroundStyle(GGColors.textSecondary)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                        }

                        Spacer().frame(height: 60)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private func stat(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(GGFonts.counterSmall)
                .foregroundStyle(color)
            Text(label)
                .font(GGFonts.label)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()
        }
    }

    @ViewBuilder
    private func field(_ label: String, _ value: String) -> some View {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(label)
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()
                Text(value)
                    .font(GGFonts.body)
                    .foregroundStyle(GGColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)

            Rectangle().fill(GGColors.border).frame(height: 1).padding(.horizontal, 24)
        }
    }
}

// MARK: - Shared

enum ReflectionStyle {
    static func scoreColor(_ s: Int) -> Color {
        if s >= 80 { return GGColors.accent }
        if s >= 50 { return GGColors.textPrimary }
        return GGColors.danger
    }
}

struct LogEmptyState: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Text(title)
                .font(GGFonts.label)
                .tightTracking()
                .foregroundStyle(GGColors.textTertiary)
            Text(subtitle)
                .font(GGFonts.caption)
                .foregroundStyle(GGColors.textTertiary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
}
