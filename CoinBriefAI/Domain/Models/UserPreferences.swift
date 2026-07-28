import Foundation

enum SummaryMode: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case quickScan
    case standard
    case deepDive

    var id: String { rawValue }

    var label: String {
        switch self {
        case .quickScan: "Quick Scan"
        case .standard: "Standard"
        case .deepDive: "Deep Dive"
        }
    }
}

enum ExperienceLevel: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case beginner
    case experienced

    var id: String { rawValue }

    var label: String {
        switch self {
        case .beginner: "Beginner"
        case .experienced: "Experienced"
        }
    }
}

struct UserPreferences: Codable, Hashable, Sendable {
    var summaryMode: SummaryMode
    var experienceLevel: ExperienceLevel
    var quietHoursStart: Int
    var quietHoursEnd: Int
    var wantsBroadenMyView: Bool
    var prefersAudioBriefings: Bool
    var followedCategories: [StoryCategory]

    static let demo = UserPreferences(
        summaryMode: .standard,
        experienceLevel: .experienced,
        quietHoursStart: 22,
        quietHoursEnd: 7,
        wantsBroadenMyView: true,
        prefersAudioBriefings: true,
        followedCategories: [.market, .regulation, .security, .defi]
    )
}

