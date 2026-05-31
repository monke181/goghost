import SwiftUI

struct GoalsSlide: View {
    @Binding var goals: [String]
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("YOUR GOALS.")
                        .font(GGFonts.title)
                        .foregroundStyle(GGColors.textPrimary)

                    Text("What do you want to achieve in 90 days?")
                        .font(GGFonts.caption)
                        .foregroundStyle(GGColors.textSecondary)
                }

                VStack(spacing: 8) {
                    ForEach(goals.indices, id: \.self) { i in
                        GoalInputRow(
                            text: Binding(
                                get: { i < goals.count ? goals[i] : "" },
                                set: { if i < goals.count { goals[i] = $0 } }
                            ),
                            onRemove: {
                                if goals.count > 1 {
                                    goals.remove(at: i)
                                }
                            }
                        )
                    }

                    if goals.count < 5 {
                        Button { goals.append("") } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("ADD GOAL")
                                    .font(GGFonts.label)
                                    .tightTracking()
                            }
                            .foregroundStyle(GGColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                            .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            GGPrimaryButton(title: "CONTINUE", action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 56)
        }
        .onAppear {
            if goals.isEmpty { goals.append("") }
        }
    }
}

private struct GoalInputRow: View {
    @Binding var text: String
    let onRemove: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(text.trimmingCharacters(in: .whitespaces).isEmpty ? GGColors.border : GGColors.accent)
                .frame(width: 3, height: 20)

            TextField("Write your goal", text: $text)
                .font(GGFonts.body)
                .foregroundStyle(GGColors.textPrimary)
                .focused($focused)
                .tint(GGColors.accent)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(GGColors.textTertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(GGColors.surface)
        .overlay(Rectangle().stroke(focused ? GGColors.textSecondary : GGColors.border, lineWidth: 1))
    }
}
