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
                VStack(alignment: .leading, spacing: 6) {
                    Text("NAME YOUR RUN.")
                        .font(GGFonts.title)
                        .foregroundStyle(GGColors.textPrimary)

                    Text("This is your season.")
                        .font(GGFonts.caption)
                        .foregroundStyle(GGColors.textSecondary)
                }

                TextField("", text: $runName, prompt: Text("THE DARK ARC").foregroundColor(GGColors.textTertiary))
                    .font(GGFonts.headline)
                    .foregroundStyle(GGColors.textPrimary)
                    .focused($focused)
                    .padding(14)
                    .background(GGColors.surface)
                    .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))

                VStack(alignment: .leading, spacing: 8) {
                    Text("SUGGESTIONS")
                        .font(GGFonts.label)
                        .foregroundStyle(GGColors.textTertiary)
                        .tightTracking()

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(suggestions, id: \.self) { s in
                                Button {
                                    runName = s
                                    focused = false
                                } label: {
                                    Text(s.uppercased())
                                        .font(GGFonts.label)
                                        .tightTracking()
                                        .foregroundStyle(runName == s ? GGColors.background : GGColors.textSecondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(runName == s ? GGColors.textPrimary : .clear)
                                        .overlay(
                                            Rectangle()
                                                .stroke(runName == s ? GGColors.textPrimary : GGColors.border, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
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
