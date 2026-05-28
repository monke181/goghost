import SwiftData
import Foundation

@Model
final class FocusSession {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var plannedDurationMinutes: Int
    var actualDurationSeconds: Int
    var wasCompleted: Bool
    var sessionLabel: String

    var run: Run?

    var durationMinutes: Int { actualDurationSeconds / 60 }

    init(plannedDurationMinutes: Int, sessionLabel: String = "") {
        self.id = UUID()
        self.startTime = .now
        self.plannedDurationMinutes = plannedDurationMinutes
        self.actualDurationSeconds = 0
        self.wasCompleted = false
        self.sessionLabel = sessionLabel
    }
}
