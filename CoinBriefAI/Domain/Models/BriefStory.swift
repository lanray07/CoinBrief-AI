import Foundation

enum StoryCategory: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case market
    case regulation
    case security
    case defi
    case infrastructure
    case adoption
    case macro

    var id: String { rawValue }

    var label: String {
        switch self {
        case .market: "Market"
        case .regulation: "Regulation"
        case .security: "Security"
        case .defi: "DeFi"
        case .infrastructure: "Infrastructure"
        case .adoption: "Adoption"
        case .macro: "Macro"
        }
    }

    var systemImage: String {
        switch self {
        case .market: "chart.line.uptrend.xyaxis"
        case .regulation: "building.columns"
        case .security: "lock.shield"
        case .defi: "square.stack.3d.up"
        case .infrastructure: "server.rack"
        case .adoption: "person.3.sequence"
        case .macro: "globe.europe.africa"
        }
    }
}

enum ImportanceLevel: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case routine
    case notable
    case high
    case critical

    var id: String { rawValue }

    var label: String {
        switch self {
        case .routine: "Routine"
        case .notable: "Notable"
        case .high: "High"
        case .critical: "Critical"
        }
    }
}

enum StorySentiment: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case constructive
    case neutral
    case mixed
    case cautious
    case risk

    var id: String { rawValue }

    var label: String {
        switch self {
        case .constructive: "Constructive"
        case .neutral: "Neutral"
        case .mixed: "Mixed"
        case .cautious: "Cautious"
        case .risk: "Risk"
        }
    }
}

enum VerificationStatus: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case sourceBacked
    case developing
    case conflicting
    case corrected

    var id: String { rawValue }

    var label: String {
        switch self {
        case .sourceBacked: "Source-backed"
        case .developing: "Developing"
        case .conflicting: "Conflicting"
        case .corrected: "Corrected"
        }
    }

    var systemImage: String {
        switch self {
        case .sourceBacked: "checkmark.seal"
        case .developing: "clock.badge.questionmark"
        case .conflicting: "exclamationmark.triangle"
        case .corrected: "arrow.triangle.2.circlepath"
        }
    }
}

enum SourceLicense: String, Codable, Hashable, Sendable {
    case licensed
    case official
    case publicRecord
    case demo

    var label: String {
        switch self {
        case .licensed: "Licensed source"
        case .official: "Official source"
        case .publicRecord: "Public record"
        case .demo: "Demo source"
        }
    }
}

struct SourceAttribution: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let publisher: String
    let domain: String
    let url: URL
    let excerpt: String
    let license: SourceLicense
    let publishedAt: Date
}

struct StoryUpdate: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let changedAt: Date
    let summary: String
    let sourceID: String
}

struct BriefStory: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let headline: String
    let summary: String
    let context: String
    let category: StoryCategory
    let importance: ImportanceLevel
    let sentiment: StorySentiment
    let verificationStatus: VerificationStatus
    let assetTags: [AssetTag]
    let sources: [SourceAttribution]
    let publishedAt: Date
    let updatedAt: Date?
    let readingMinutes: Int
    let isWatchlistMatch: Bool
    let updates: [StoryUpdate]

    var primaryURL: URL? {
        sources.first?.url
    }

    var sourceCount: Int {
        sources.count
    }
}

struct StoryCluster: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let canonicalHeadline: String
    let storyIDs: [String]
    let sourceIDs: [String]
    let confidence: Double
    let updatedAt: Date
}

