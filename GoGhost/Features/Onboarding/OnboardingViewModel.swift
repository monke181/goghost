import SwiftUI
import SwiftData

@Observable
final class OnboardingViewModel {
    var currentSlide = 0
    var why = ""
    var runName = ""
    var selectedAreas: Set<String> = []

    var canAdvanceFromWhy: Bool { !why.trimmingCharacters(in: .whitespaces).isEmpty }
    var canAdvanceFromName: Bool { !runName.trimmingCharacters(in: .whitespaces).isEmpty }
    var canAdvanceFromAreas: Bool { !selectedAreas.isEmpty }

    let nameSuggestions = ["The Come Up", "Season Zero", "The Rebuild", "Ghost Protocol", "The Lock-In", "Year Zero"]

    func advance() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentSlide = min(currentSlide + 1, 4)
        }
    }

    func toggleArea(_ area: String) {
        if selectedAreas.contains(area) {
            selectedAreas.remove(area)
        } else if selectedAreas.count < 3 {
            selectedAreas.insert(area)
        }
    }

    func commitRun(context: ModelContext) {
        let run = Run(
            name: runName.trimmingCharacters(in: .whitespaces),
            why: why.trimmingCharacters(in: .whitespaces),
            focusAreas: Array(selectedAreas)
        )
        context.insert(run)
    }
}
