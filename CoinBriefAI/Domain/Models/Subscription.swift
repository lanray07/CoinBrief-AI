import Foundation

enum SubscriptionTier: String, Codable, Hashable, Sendable {
    case free
    case pro

    var label: String {
        switch self {
        case .free: "Free"
        case .pro: "Pro"
        }
    }
}

enum ProCapability: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case unlimitedSummaries
    case personalFeed
    case unlimitedWatchlist
    case deepDive
    case audioBriefings
    case offline
    case customAlerts
    case premiumWidgets

    var id: String { rawValue }

    var label: String {
        switch self {
        case .unlimitedSummaries: "Unlimited summaries"
        case .personalFeed: "Personal feed"
        case .unlimitedWatchlist: "Unlimited watchlist"
        case .deepDive: "Standard and Deep Dive modes"
        case .audioBriefings: "Audio briefings"
        case .offline: "Offline reading"
        case .customAlerts: "Custom alerts"
        case .premiumWidgets: "Premium widgets"
        }
    }
}

struct SubscriptionProduct: Identifiable, Hashable, Sendable {
    let id: String
    let displayName: String
    let displayPrice: String
    let period: String
    let isFamilyShareable: Bool
}

struct SubscriptionEntitlement: Hashable, Sendable {
    var tier: SubscriptionTier
    var isActive: Bool
    var renewalDate: Date?
    var capabilities: Set<ProCapability>

    static let free = SubscriptionEntitlement(
        tier: .free,
        isActive: false,
        renewalDate: nil,
        capabilities: []
    )

    static func pro(renewalDate: Date? = nil) -> SubscriptionEntitlement {
        SubscriptionEntitlement(
            tier: .pro,
            isActive: true,
            renewalDate: renewalDate,
            capabilities: Set(ProCapability.allCases)
        )
    }
}

