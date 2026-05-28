import SwiftUI

struct NameRunSlide: View {
    @Binding var runName: String
    let suggestions: [String]
    let onContinue: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name your run.")
                        .font(GGFonts.display)
                        .foregroundStyle(GGColors.textPrimary)

                    Text("This is your season.")
                        .font(GGFonts.body)
                        .foregroundStyle(GGColors.textSecondary)
                }

                TextField("", text: $runName, prompt: Text("The Dark Arc").foregroundColor(GGColors.textTertiary))
                    .font(GGFonts.title)
                    .foregroundStyle(GGColors.textPrimary)
                    .focused($focused)
                    .padding(16)
                    .background(GGColors.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                // Suggestions
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(suggestions, id: \.self) { s in
                            Button {
                                runName = s
                                focused = false
                            } label: {
                                Text(s)
                                    .font(GGFonts.caption)
                                    .foregroundStyle(runName == s ? GGColors.background : GGColors.textSecondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(runName == s ? GGColors.accent : GGColors.surfaceElevated)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            GGPrimaryButton(title: "CONTINUE", action: onContinue)
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
                .opacity(runName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.3 : 1)
                .disabled(runName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .onAppear { focused = true }
    }
}
