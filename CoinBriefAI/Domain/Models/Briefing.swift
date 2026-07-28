import Foundation

enum BriefingEdition: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case morning
    case evening
    case breaking

    var id: String { rawValue }

    var label: String {
        switch self {
        case .morning: "Morning"
        case .evening: "Evening"
        case .breaking: "Breaking"
        }
    }
}

struct BriefingSection: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let stories: [BriefStory]
}

struct Briefing: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let edition: BriefingEdition
    let generatedAt: Date
    let readTimeMinutes: Int
    let marketPulse: String
    let sections: [BriefingSection]
}

