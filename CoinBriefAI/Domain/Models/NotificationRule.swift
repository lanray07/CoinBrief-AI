import Foundation

enum NotificationReason: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case morningBrief
    case eveningBrief
    case watchlistBreaking
    case securityAlert
    case narrativeShift

    var id: String { rawValue }

    var label: String {
        switch self {
        case .morningBrief: "Morning brief"
        case .eveningBrief: "Evening brief"
        case .watchlistBreaking: "Watchlist breaking"
        case .securityAlert: "Security alerts"
        case .narrativeShift: "Narrative shifts"
        }
    }
}

struct NotificationRule: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var reason: NotificationReason
    var isEnabled: Bool
    var quietHoursStart: Int
    var quietHoursEnd: Int
    var frequencyCapPerDay: Int

    static let defaults: [NotificationRule] = [
        NotificationRule(id: UUID(), reason: .morningBrief, isEnabled: true, quietHoursStart: 22, quietHoursEnd: 7, frequencyCapPerDay: 1),
        NotificationRule(id: UUID(), reason: .eveningBrief, isEnabled: true, quietHoursStart: 22, quietHoursEnd: 7, frequencyCapPerDay: 1),
        NotificationRule(id: UUID(), reason: .watchlistBreaking, isEnabled: true, quietHoursStart: 22, quietHoursEnd: 7, frequencyCapPerDay: 3),
        NotificationRule(id: UUID(), reason: .securityAlert, isEnabled: true, quietHoursStart: 22, quietHoursEnd: 7, frequencyCapPerDay: 4),
        NotificationRule(id: UUID(), reason: .narrativeShift, isEnabled: false, quietHoursStart: 22, quietHoursEnd: 7, frequencyCapPerDay: 2)
    ]
}

