import Foundation

enum FocusArea: String, CaseIterable, Identifiable, Codable {
    case business      = "Business"
    case fitness       = "Fitness"
    case mindset       = "Mindset"
    case creative      = "Creative"
    case finance       = "Finance"
    case relationships = "Relationships"
    case skill         = "Skill"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .business:      return "briefcase.fill"
        case .fitness:       return "flame.fill"
        case .mindset:       return "brain.head.profile"
        case .creative:      return "paintbrush.fill"
        case .finance:       return "chart.line.uptrend.xyaxis"
        case .relationships: return "person.2.fill"
        case .skill:         return "graduationcap.fill"
        }
    }

    var tagline: String {
        switch self {
        case .business:      return "Build the empire"
        case .fitness:       return "Forge the body"
        case .mindset:       return "Own your head"
        case .creative:      return "Make the work"
        case .finance:       return "Stack and protect"
        case .relationships: return "Earn the room"
        case .skill:         return "Sharpen the edge"
        }
    }
}
