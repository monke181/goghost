import SwiftUI

struct WhySlide: View {
    @Binding var why: String
    let onContinue: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 24) {
                Text("What are you\nrunning toward?")
                    .font(GGFonts.display)
                    .foregroundStyle(GGColors.textPrimary)
                    .lineSpacing(4)

                ZStack(alignment: .topLeading) {
                    if why.isEmpty {
                        Text("Write it down.")
                            .font(GGFonts.body)
                            .foregroundStyle(GGColors.textTertiary)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                    TextEditor(text: $why)
                        .font(GGFonts.body)
                        .foregroundStyle(GGColors.textPrimary)
                        .scrollContentBackground(.hidden)
                        .background(.clear)
                        .focused($focused)
                        .frame(minHeight: 120, maxHeight: 200)
                }
                .padding(16)
                .background(GGColors.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                HStack {
                    Spacer()
                    Text("\(why.count)/300")
                        .font(GGFonts.caption)
                        .foregroundStyle(GGColors.textTertiary)
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            GGPrimaryButton(title: "CONTINUE", action: onContinue)
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
                .opacity(why.trimmingCharacters(in: .whitespaces).isEmpty ? 0.3 : 1)
                .disabled(why.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .onAppear { focused = true }
        .onChange(of: why) { _, new in
            if new.count > 300 { why = String(new.prefix(300)) }
        }
    }
}
