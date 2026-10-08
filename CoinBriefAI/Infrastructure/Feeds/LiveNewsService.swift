import Foundation

actor LiveNewsService: NewsService {
    private let sourceStore: SourceStore
    private let cacheURL: URL
    private var memoryCache: CachedStoryPayload?

    init(sourceStore: SourceStore = .shared, cacheURL: URL? = nil) {
        self.sourceStore = sourceStore
        if let cacheURL {
            self.cacheURL = cacheURL
        } else {
            let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                .appendingPathComponent("CoinBriefAI", isDirectory: true)
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            self.cacheURL = directory.appendingPathComponent("live-stories.json")
        }
    }

    func fetchBriefing(preferences: UserPreferences, edition: BriefingEdition) async throws -> Briefing {
        let stories = try await loadStories()
        let storyLimit = switch preferences.summaryMode {
        case .quickScan: 8
        case .standard: 20
        case .deepDive: 40
        }
        let selected = Array(stories.prefix(storyLimit))
        let sourceCount = Set(selected.flatMap(\.sources).map(\.publisher)).count

        return Briefing(
            id: "briefing-\(edition.rawValue)-\(Int(Date.now.timeIntervalSince1970 / 900))",
            title: "Source Desk",
            edition: edition,
            generatedAt: .now,
            readTimeMinutes: max(2, min(12, selected.reduce(0) { $0 + $1.readingMinutes } / 3)),
            marketPulse: "\(selected.count) current reports from \(sourceCount) enabled sources. Each brief preserves its original link and publication time for verification.",
            sections: makeSections(from: selected)
        )
    }

    func searchStories(query: String, filter: StorySearchFilter) async throws -> [BriefStory] {
        let stories = try await loadStories()
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        var filtered = stories.filter { story in
            guard !normalizedQuery.isEmpty else { return true }
            return story.headline.lowercased().contains(normalizedQuery)
                || story.summary.lowercased().contains(normalizedQuery)
                || story.sources.contains { $0.publisher.lowercased().contains(normalizedQuery) }
                || story.assetTags.contains { $0.symbol.lowercased().contains(normalizedQuery) || $0.name.lowercased().contains(normalizedQuery) }
        }

        if let category = filter.category {
            filtered = filtered.filter { $0.category == category }
        }
        if let assetSymbol = filter.assetSymbol {
            filtered = filtered.filter { story in
                story.assetTags.contains { $0.symbol.caseInsensitiveCompare(assetSymbol) == .orderedSame }
            }
        }

        switch filter.sort {
        case .recent:
            filtered.sort { $0.publishedAt > $1.publishedAt }
        case .importance:
            let rank: [ImportanceLevel: Int] = [.critical: 0, .high: 1, .notable: 2, .routine: 3]
            filtered.sort { rank[$0.importance, default: 9] < rank[$1.importance, default: 9] }
        case .tagged:
            filtered.sort { ($0.isWatchlistMatch ? 0 : 1) < ($1.isWatchlistMatch ? 0 : 1) }
        case .sourceCount:
            filtered.sort { $0.sourceCount > $1.sourceCount }
        }
        return filtered
    }

    func story(id: String) async throws -> BriefStory {
        let stories = try await loadStories()
        guard let story = stories.first(where: { $0.id == id }) else {
            throw LiveNewsError.storyNotFound
        }
        return story
    }

    private func loadStories() async throws -> [BriefStory] {
        let sources = await sourceStore.sources().filter(\.isEnabled)
        guard !sources.isEmpty else { throw LiveNewsError.noEnabledSources }
        let sourceKey = sources.map(\.id).sorted().joined(separator: "|")

        if let memoryCache,
           memoryCache.sourceKey == sourceKey,
           Date.now.timeIntervalSince(memoryCache.fetchedAt) < 300 {
            return memoryCache.stories
        }

        let fetched = await withTaskGroup(of: (FeedSource, RSSFeedDocument)?.self) { group in
            for source in sources {
                group.addTask {
                    guard let document = try? await RSSFeedClient.fetch(url: source.feedURL) else { return nil }
                    return (source, document)
                }
            }

            var documents: [(FeedSource, RSSFeedDocument)] = []
            for await result in group {
                if let result { documents.append(result) }
            }
            return documents
        }

        if !fetched.isEmpty {
            let stories = fetched
                .flatMap { source, document in
                    document.items.prefix(30).map { Self.makeStory(item: $0, source: source) }
                }
                .sorted { $0.publishedAt > $1.publishedAt }
            let payload = CachedStoryPayload(fetchedAt: .now, sourceKey: sourceKey, stories: Array(stories.prefix(100)))
            memoryCache = payload
            try? JSONEncoder().encode(payload).write(to: cacheURL, options: .atomic)
            return payload.stories
        }

        if let cached = readDiskCache(), !cached.stories.isEmpty {
            memoryCache = cached
            return cached.stories
        }
        throw LiveNewsError.sourcesUnavailable
    }

    private func readDiskCache() -> CachedStoryPayload? {
        guard let data = try? Data(contentsOf: cacheURL) else { return nil }
        return try? JSONDecoder().decode(CachedStoryPayload.self, from: data)
    }

    private func makeSections(from stories: [BriefStory]) -> [BriefingSection] {
        [
            BriefingSection(
                id: "public-record",
                title: "Public Record",
                subtitle: "Regulatory and institutional updates from primary sources.",
                systemImage: "building.columns",
                stories: stories.filter { $0.sources.first?.license == .publicRecord }
            ),
            BriefingSection(
                id: "protocol",
                title: "Protocol And Security",
                subtitle: "Technical updates with direct links to the publishing organization.",
                systemImage: "checkmark.shield",
                stories: stories.filter { $0.category == .infrastructure || $0.category == .security }
            ),
            BriefingSection(
                id: "research",
                title: "Research Queue",
                subtitle: "The remaining newest reports across your enabled source library.",
                systemImage: "doc.text.magnifyingglass",
                stories: stories.filter { story in
                    story.sources.first?.license != .publicRecord
                        && story.category != .infrastructure
                        && story.category != .security
                }
            )
        ]
    }

    nonisolated static func makeStory(item: RSSFeedItem, source: FeedSource) -> BriefStory {
        let combined = "\(item.title) \(item.summary)".lowercased()
        let category = classify(combined)
        let tags = assetTags(in: combined)
        let sourceLicense: SourceLicense = switch source.kind {
        case .publicRecord: .publicRecord
        case .official: .official
        case .research, .custom: .syndicated
        }
        let cleanedSummary = item.summary.isEmpty
            ? "Open the original report to review the publisher's full update."
            : String(item.summary.prefix(600))
        let domain = item.link.host ?? source.feedURL.host ?? "Source"
        let attribution = SourceAttribution(
            id: "\(source.id)|\(item.id)",
            title: item.title,
            publisher: source.title,
            domain: domain,
            url: item.link,
            excerpt: cleanedSummary,
            license: sourceLicense,
            publishedAt: item.publishedAt
        )

        return BriefStory(
            id: stableIdentifier("\(source.id)|\(item.id)"),
            headline: item.title,
            summary: cleanedSummary,
            context: "This brief is derived from the feed excerpt published by \(source.title). CoinBrief preserves the original link, publisher, and timestamp so you can inspect the complete source before drawing conclusions.",
            category: category,
            importance: importance(for: combined, sourceKind: source.kind),
            sentiment: sentiment(for: combined),
            verificationStatus: .sourceBacked,
            assetTags: tags,
            sources: [attribution],
            publishedAt: item.publishedAt,
            updatedAt: nil,
            readingMinutes: max(1, min(8, cleanedSummary.split(separator: " ").count / 180 + 1)),
            isWatchlistMatch: !tags.isEmpty,
            updates: []
        )
    }

    nonisolated static func classify(_ text: String) -> StoryCategory {
        if containsAny(text, ["sec ", "cftc", "regulation", "regulator", "policy", "law", "enforcement", "court"]) { return .regulation }
        if containsAny(text, ["security", "vulnerability", "exploit", "hack", "phishing", "malware"]) { return .security }
        if containsAny(text, ["defi", "liquidity", "lending", "staking", "stablecoin"]) { return .defi }
        if containsAny(text, ["protocol", "upgrade", "client", "node", "testnet", "mainnet", "consensus"]) { return .infrastructure }
        if containsAny(text, ["adoption", "payment", "institution", "launch", "integration"]) { return .adoption }
        if containsAny(text, ["inflation", "rates", "federal reserve", "macro", "economy"]) { return .macro }
        return .market
    }

    nonisolated static func assetTags(in text: String) -> [AssetTag] {
        var tags: [AssetTag] = []
        if containsAny(text, ["bitcoin", " btc"]) { tags.append(.bitcoin) }
        if containsAny(text, ["ethereum", " ether", " eth"]) { tags.append(.ethereum) }
        if containsAny(text, ["solana", " sol"]) { tags.append(.solana) }
        if containsAny(text, ["defi", "decentralized finance"]) { tags.append(.defi) }
        if containsAny(text, ["regulation", "regulator", " sec ", "cftc", "policy", "enforcement"]) { tags.append(.regulation) }
        return tags
    }

    nonisolated private static func importance(for text: String, sourceKind: FeedSourceKind) -> ImportanceLevel {
        if containsAny(text, ["critical", "emergency", "exploit", "breach", "enforcement action"]) { return .critical }
        if sourceKind == .publicRecord || containsAny(text, ["mainnet", "upgrade", "security", "final rule"]) { return .high }
        if containsAny(text, ["proposal", "testnet", "research", "release"]) { return .notable }
        return .routine
    }

    nonisolated private static func sentiment(for text: String) -> StorySentiment {
        if containsAny(text, ["exploit", "breach", "fraud", "attack", "scam"]) { return .risk }
        if containsAny(text, ["warning", "risk", "decline", "enforcement"]) { return .cautious }
        if containsAny(text, ["launch", "improve", "growth", "advance", "successful"]) { return .constructive }
        return .neutral
    }

    nonisolated private static func containsAny(_ text: String, _ terms: [String]) -> Bool {
        terms.contains { text.contains($0) }
    }

    nonisolated private static func stableIdentifier(_ value: String) -> String {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in value.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1_099_511_628_211
        }
        return String(hash, radix: 16)
    }
}

private struct CachedStoryPayload: Codable, Sendable {
    let fetchedAt: Date
    let sourceKey: String
    let stories: [BriefStory]
}

enum LiveNewsError: LocalizedError {
    case noEnabledSources
    case sourcesUnavailable
    case storyNotFound

    var errorDescription: String? {
        switch self {
        case .noEnabledSources: "Enable at least one source in the Source Library."
        case .sourcesUnavailable: "No source could be reached and no cached reports are available."
        case .storyNotFound: "The requested report is no longer available."
        }
    }
}
