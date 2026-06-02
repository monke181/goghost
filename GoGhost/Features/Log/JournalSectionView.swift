import SwiftUI
import SwiftData

struct JournalSectionView: View {
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]

    @State private var showNew = false
    @State private var editing: JournalEntry?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if entries.isEmpty {
                LogEmptyState(
                    title: "NOTHING WRITTEN YET",
                    subtitle: "Tap + to start your first entry."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(entries) { entry in
                            Button { editing = entry } label: {
                                JournalRow(entry: entry)
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

            // New entry button
            Button { showNew = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(GGColors.background)
                    .frame(width: 56, height: 56)
                    .background(GGColors.textPrimary)
                    .overlay(Rectangle().stroke(GGColors.textPrimary, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .padding(24)
        }
        .fullScreenCover(isPresented: $showNew) {
            JournalComposerView(entry: nil)
        }
        .fullScreenCover(item: $editing) { entry in
            JournalComposerView(entry: entry)
        }
    }
}

private struct JournalRow: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()).uppercased())
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()
                Spacer()
                Text(entry.date.formatted(.dateTime.hour().minute()))
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()
            }
            Text(entry.preview)
                .font(GGFonts.body)
                .foregroundStyle(GGColors.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .contentShape(Rectangle())
    }
}

struct JournalComposerView: View {
    let entry: JournalEntry?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @FocusState private var focused: Bool

    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ZStack {
            GGColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button { dismiss() } label: {
                        Text("CANCEL")
                            .font(GGFonts.label)
                            .tightTracking()
                            .foregroundStyle(GGColors.textTertiary)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button { save() } label: {
                        Text("SAVE")
                            .font(GGFonts.label)
                            .tightTracking()
                            .foregroundStyle(trimmed.isEmpty ? GGColors.textTertiary : GGColors.accent)
                    }
                    .buttonStyle(.plain)
                    .disabled(trimmed.isEmpty)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Text((entry?.date ?? .now).formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased())
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)

                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("What's on your mind?")
                            .font(GGFonts.body)
                            .foregroundStyle(GGColors.textTertiary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }
                    TextEditor(text: $text)
                        .font(GGFonts.body)
                        .foregroundStyle(GGColors.textPrimary)
                        .scrollContentBackground(.hidden)
                        .background(.clear)
                        .focused($focused)
                }
                .padding(.horizontal, 20)
                .frame(maxHeight: .infinity)

                if entry != nil {
                    Rectangle().fill(GGColors.border).frame(height: 1)
                    Button(role: .destructive) { delete() } label: {
                        Text("DELETE ENTRY")
                            .font(GGFonts.label)
                            .tightTracking()
                            .foregroundStyle(GGColors.danger)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear {
            text = entry?.text ?? ""
            focused = true
        }
    }

    private func save() {
        guard !trimmed.isEmpty else { dismiss(); return }
        if let entry {
            entry.text = text
            entry.updatedAt = .now
        } else {
            context.insert(JournalEntry(text: text))
        }
        try? context.save()
        dismiss()
    }

    private func delete() {
        if let entry {
            context.delete(entry)
            try? context.save()
        }
        dismiss()
    }
}
