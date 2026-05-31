import SwiftUI
import SwiftData

@Observable
final class OnboardingViewModel {
    enum Step: Int, CaseIterable {
        case welcome, system, why, focus, goals, commit, notifications, screenTime, launch
    }

    var step: Step = .welcome
    // 1 = moving forward, -1 = moving back. Drives transition direction.
    var direction = 1

    var why = ""
    var selectedAreas: Set<String> = []
    var goals: [String] = []

    var canAdvanceFromWhy: Bool { !why.trimmingCharacters(in: .whitespaces).isEmpty }
    var canAdvanceFromAreas: Bool { !selectedAreas.isEmpty }

    var progress: Double {
        Double(step.rawValue) / Double(Step.allCases.count - 1)
    }

    func advance() {
        guard let next = Step(rawValue: step.rawValue + 1) else { return }
        direction = 1
        withAnimation(GGAnimations.slide) { step = next }
    }

    func back() {
        guard let prev = Step(rawValue: step.rawValue - 1) else { return }
        direction = -1
        withAnimation(GGAnimations.slide) { step = prev }
    }

    func toggleArea(_ area: String) {
        if selectedAreas.contains(area) {
            selectedAreas.remove(area)
        } else if selectedAreas.count < 3 {
            selectedAreas.insert(area)
        }
    }

    func commitRun(context: ModelContext) {
        let filteredGoals = goals.map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let run = Run(
            name: "90-DAY RUN",
            why: why.trimmingCharacters(in: .whitespaces),
            focusAreas: Array(selectedAreas),
            goals: filteredGoals
        )
        context.insert(run)
    }
}
