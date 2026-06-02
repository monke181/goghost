import SwiftData
import Foundation

@Model
final class JournalEntry {
    var id: UUID
    var date: Date
    var updatedAt: Date
    var text: String

    // First non-empty line, used as a row title/preview
    var preview: String {
        let line = text
            .split(separator: "\n", omittingEmptySubsequences: true)
            .first
            .map(String.init) ?? ""
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "—" : trimmed
    }

    init(date: Date = .now, text: String = "") {
        self.id = UUID()
        self.date = date
        self.updatedAt = date
        self.text = text
    }
}
