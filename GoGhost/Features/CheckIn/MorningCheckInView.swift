import SwiftUI
import SwiftData

struct MorningCheckInView: View {
    let run: Run
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var vm = CheckInViewModel(mode: .morning)

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
        case 1: goalsStep
        case 2: motivationStep
        case 3: focusAreaStep
        default: confirmationStep
        }
    }

    private var openerStep: some View {
        slideShell {
            VStack(alignment: .leading, spacing: 8) {
                Text("DAY \(run.dayNumber)")
                    .font(GGFonts.display)
                    .foregroundStyle(GGColors.textPrimary)
                Text("MORNING.")
                    .font(GGFonts.headline)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()
            }
        } action: {
            GGPrimaryButton(title: "LET'S GO", action: vm.advance)
        }
    }

    private var goalsStep: some View {
        slideShell {
            VStack(alignment: .leading, spacing: 16) {
                Text("WHAT ARE YOU\nGETTING DONE TODAY?")
                    .font(GGFonts.title)
                    .foregroundStyle(GGColors.textPrimary)
                    .lineSpacing(2)

                VStack(spacing: 8) {
                    ForEach(Array(zip([1,2,3], [$vm.goal1, $vm.goal2, $vm.goal3])), id: \.0) { num, binding in
                        HStack(spacing: 10) {
                            Text("\(num)")
                                .font(GGFonts.label)
                                .foregroundStyle(GGColors.textTertiary)
                                .frame(width: 16)

                            TextField("", text: binding, prompt: Text("—").foregroundColor(GGColors.textTertiary))
                                .font(GGFonts.body)
                                .foregroundStyle(GGColors.textPrimary)
                                .padding(12)
                                .background(GGColors.surface)
                                .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
                        }
                    }
                }
            }
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
                .opacity(vm.goal1.isEmpty ? 0.3 : 1)
                .disabled(vm.goal1.isEmpty)
        }
    }

    private var motivationStep: some View {
        slideShell {
            VStack(alignment: .leading, spacing: 20) {
                Text("HOW LOCKED IN\nARE YOU RIGHT NOW?")
                    .font(GGFonts.title)
                    .foregroundStyle(GGColors.textPrimary)
                    .lineSpacing(2)
                RatingPicker(value: $vm.motivationLevel, max: 10)
            }
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
        }
    }

    private var focusAreaStep: some View {
        slideShell {
            VStack(alignment: .leading, spacing: 16) {
                Text("LEAD WITH WHICH\nAREA TODAY?")
                    .font(GGFonts.title)
                    .foregroundStyle(GGColors.textPrimary)
                    .lineSpacing(2)

                VStack(spacing: 0) {
                    ForEach(run.focusAreas, id: \.self) { area in
                        let isSelected = vm.selectedFocusArea == area
                        Button {
                            vm.selectedFocusArea = area
                        } label: {
                            HStack {
                                Text(area.uppercased())
                                    .font(GGFonts.bodyMed)
                                    .foregroundStyle(isSelected ? GGColors.textPrimary : GGColors.textSecondary)
                                    .tightTracking()
                                Spacer()
                                if isSelected {
                                    Rectangle()
                                        .fill(GGColors.accent)
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                        }
                        .buttonStyle(.plain)
                        .background(isSelected ? GGColors.surface : .clear)

                        if area != run.focusAreas.last {
                            Rectangle().fill(GGColors.border).frame(height: 1)
                        }
                    }
                }
                .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
            }
        } action: {
            GGPrimaryButton(title: "DONE") {
                if vm.selectedFocusArea.isEmpty, let first = run.focusAreas.first {
                    vm.selectedFocusArea = first
                }
                let entry = todayEntry(for: run, context: context)
                vm.save(to: entry, context: context)
                vm.advance()
            }
        }
    }

    private var confirmationStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                Text("LOCKED IN.")
                    .font(GGFonts.display)
                    .foregroundStyle(GGColors.accent)

                Rectangle().fill(GGColors.border).frame(height: 1)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach([vm.goal1, vm.goal2, vm.goal3].filter { !$0.isEmpty }, id: \.self) { g in
                        HStack(alignment: .top, spacing: 10) {
                            Text("—")
                                .font(GGFonts.body)
                                .foregroundStyle(GGColors.textTertiary)
                            Text(g)
                                .font(GGFonts.body)
                                .foregroundStyle(GGColors.textSecondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            GGPrimaryButton(title: "CLOSE") { dismiss() }
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
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
}
