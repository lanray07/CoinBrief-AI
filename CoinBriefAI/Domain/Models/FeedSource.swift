import Foundation

enum FeedSourceKind: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case official
    case publicRecord
    case research
    case custom

    var id: String { rawValue }

    var label: String {
        switch self {
        case .official: "Official"
        case .publicRecord: "Public record"
        case .research: "Research"
        case .custom: "Custom"
        }
    }

    var systemImage: String {
        switch self {
        case .official: "checkmark.seal"
        case .publicRecord: "building.columns"
        case .research: "doc.text.magnifyingglass"
        case .custom: "link"
        }
    }
}

struct FeedSource: Identifiable, Codable, Hashable, Sendable {
    let id: String
    var title: String
    let feedURL: URL
    let websiteURL: URL?
    let kind: FeedSourceKind
    var isEnabled: Bool
    let isBuiltIn: Bool

    init(
        id: String? = nil,
        title: String,
        feedURL: URL,
        websiteURL: URL? = nil,
        kind: FeedSourceKind,
        isEnabled: Bool = true,
        isBuiltIn: Bool = false
    ) {
        self.id = id ?? feedURL.absoluteString
        self.title = title
        self.feedURL = feedURL
        self.websiteURL = websiteURL
        self.kind = kind
        self.isEnabled = isEnabled
        self.isBuiltIn = isBuiltIn
    }
}

extension FeedSource {
    static let builtIns: [FeedSource] = [
        FeedSource(
            title: "Ethereum Foundation",
            feedURL: URL(string: "https://blog.ethereum.org/feed.xml")!,
            websiteURL: URL(string: "https://blog.ethereum.org")!,
            kind: .official,
            isBuiltIn: true
        ),
        FeedSource(
            title: "U.S. SEC Press Releases",
            feedURL: URL(string: "https://www.sec.gov/news/pressreleases.rss")!,
            websiteURL: URL(string: "https://www.sec.gov/newsroom/press-releases")!,
            kind: .publicRecord,
            isBuiltIn: true
        ),
        FeedSource(
            title: "U.S. CFTC Press Releases",
            feedURL: URL(string: "https://www.cftc.gov/RSS/RSSGP/rssgp.xml")!,
            websiteURL: URL(string: "https://www.cftc.gov/PressRoom/PressReleases")!,
            kind: .publicRecord,
            isBuiltIn: true
        ),
        FeedSource(
            title: "Bitcoin Optech",
            feedURL: URL(string: "https://bitcoinops.org/feed.xml")!,
            websiteURL: URL(string: "https://bitcoinops.org")!,
            kind: .research,
            isBuiltIn: true
        )
    ]
}
