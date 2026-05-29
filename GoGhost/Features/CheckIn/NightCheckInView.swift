import SwiftUI
import SwiftData

struct NightCheckInView: View {
    let run: Run
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var vm = CheckInViewModel(mode: .night)

    var body: some View {
        ZStack {
            GGColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                stepContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .id(vm.step)
            }
        }
        .interactiveDismissDisabled(!vm.isComplete)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch vm.step {
        case 0: openerStep
        case 1: winsStep
        case 2: lossesStep
        case 3: lessonsStep
        case 4: dopamineStep
        case 5: ratingStep
        default: scoreRevealStep
        }
    }

    private var openerStep: some View {
        slideShell {
            VStack(alignment: .leading, spacing: 8) {
                Text("DAY \(run.dayNumber)")
                    .font(GGFonts.display)
                    .foregroundStyle(GGColors.textPrimary)
                Text("DONE.")
                    .font(GGFonts.headline)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()
            }
        } action: {
            GGPrimaryButton(title: "REFLECT", action: vm.advance)
        }
    }

    private var winsStep: some View {
        slideShell {
            journalField(prompt: "WHAT DID YOU\nACTUALLY WIN TODAY?", binding: $vm.wins)
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
                .opacity(vm.wins.isEmpty ? 0.3 : 1)
                .disabled(vm.wins.isEmpty)
        }
    }

    private var lossesStep: some View {
        slideShell {
            journalField(prompt: "WHERE DID\nYOU SLIP?", binding: $vm.losses)
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
        }
    }

    private var lessonsStep: some View {
        slideShell {
            journalField(prompt: "WHAT'S THE\nONE LESSON?", binding: $vm.lessons)
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
        }
    }

    private var dopamineStep: some View {
        slideShell {
            VStack(alignment: .leading, spacing: 16) {
                Text("WHAT DID YOU\nSTAY AWAY FROM?")
                    .font(GGFonts.title)
                    .foregroundStyle(GGColors.textPrimary)
                    .lineSpacing(2)

                VStack(spacing: 0) {
                    ForEach(CheckInViewModel.dopamineItems, id: \.self) { item in
                        let isOn = vm.dopamineAvoided.contains(item)
                        Button {
                            if isOn { vm.dopamineAvoided.remove(item) }
                            else { vm.dopamineAvoided.insert(item) }
                        } label: {
                            HStack {
                                Text(item.uppercased())
                                    .font(GGFonts.bodyMed)
                                    .foregroundStyle(isOn ? GGColors.textPrimary : GGColors.textSecondary)
                                    .tightTracking()
                                Spacer()
                                Rectangle()
                                    .fill(isOn ? GGColors.accent : .clear)
                                    .frame(width: 8, height: 8)
                                    .overlay(Rectangle().stroke(isOn ? GGColors.accent : GGColors.border, lineWidth: 1))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)

                        if item != CheckInViewModel.dopamineItems.last {
                            Rectangle().fill(GGColors.border).frame(height: 1)
                        }
                    }
                }
                .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
            }
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
        }
    }

    private var ratingStep: some View {
        slideShell {
            VStack(alignment: .leading, spacing: 20) {
                Text("RATE THE DAY.")
                    .font(GGFonts.title)
                    .foregroundStyle(GGColors.textPrimary)
                RatingPicker(value: $vm.dayRating, max: 10)
            }
        } action: {
            GGPrimaryButton(title: "SUBMIT") {
                let entry = todayEntry(for: run, context: context)
                vm.save(to: entry, context: context)
                vm.advance()
            }
        }
    }

    private var scoreRevealStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                Text("DISCIPLINE SCORE")
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()

                Text("\(vm.computedScore)")
                    .font(GGFonts.hero)
                    .foregroundStyle(scoreColor(vm.computedScore))
                    .contentTransition(.numericText())

                Rectangle().fill(GGColors.border).frame(height: 1)

                Text(scoreTagline(vm.computedScore))
                    .font(GGFonts.body)
                    .foregroundStyle(GGColors.textSecondary)
            }
            .padding(.horizontal, 32)

            Spacer()

            GGPrimaryButton(title: "DONE") { dismiss() }
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
        }
    }

    private func journalField(prompt: String, binding: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(prompt)
                .font(GGFonts.title)
                .foregroundStyle(GGColors.textPrimary)
                .lineSpacing(2)

            ZStack(alignment: .topLeading) {
                if binding.wrappedValue.isEmpty {
                    Text("—")
                        .font(GGFonts.body)
                        .foregroundStyle(GGColors.textTertiary)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                TextEditor(text: binding)
                    .font(GGFonts.body)
                    .foregroundStyle(GGColors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .frame(minHeight: 120)
            }
            .padding(14)
            .background(GGColors.surface)
            .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
        }
    }

    private func slideShell<C: View, A: View>(
        @ViewBuilder content: () -> C,
        @ViewBuilder action: () -> A
    ) -> some View {
        VStack(spacing: 0) {
            Spacer()
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
            Spacer()
            action()
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
        }
    }

    private func scoreColor(_ s: Int) -> Color {
        if s >= 80 { return GGColors.accent }
        if s >= 50 { return GGColors.textPrimary }
        return GGColors.danger
    }

    private func scoreTagline(_ s: Int) -> String {
        if s >= 80 { return "Locked in." }
        if s >= 60 { return "Solid day." }
        if s >= 40 { return "You can do better." }
        return "Tomorrow is the one."
    }
}
