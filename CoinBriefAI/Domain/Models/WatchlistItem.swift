import Foundation

enum AlertSensitivity: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case majorOnly
    case importantOnly
    case allUpdates

    var id: String { rawValue }

    var label: String {
        switch self {
        case .majorOnly: "Major only"
        case .importantOnly: "Important"
        case .allUpdates: "All updates"
        }
    }
}

struct WatchlistItem: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var title: String
    var symbol: String
    var kind: AssetKind
    var alertSensitivity: AlertSensitivity
    var isNotificationsEnabled: Bool
    var addedAt: Date
    var matchedStoryCount: Int
    var latestNarrative: String
}

