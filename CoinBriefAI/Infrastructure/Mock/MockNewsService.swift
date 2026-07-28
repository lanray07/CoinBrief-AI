import Foundation

struct MockNewsService: NewsService {
    func fetchBriefing(preferences: UserPreferences, edition: BriefingEdition) async throws -> Briefing {
        try await Task.sleep(nanoseconds: 250_000_000)

        let stories = Self.demoStories
        return Briefing(
            id: "briefing-\(edition.rawValue)-demo",
            title: "Your 5-Minute Brief",
            edition: edition,
            generatedAt: .now,
            readTimeMinutes: 5,
            marketPulse: "Demo briefing: policy, ETF flow, and security stories are moving together. This is research context only, not financial advice.",
            sections: [
                BriefingSection(
                    id: "breaking",
                    title: "Breaking",
                    subtitle: "High-importance stories with fresh source checks.",
                    systemImage: "bolt",
                    stories: stories.filter { $0.importance == .high || $0.importance == .critical }
                ),
                BriefingSection(
                    id: "market",
                    title: "Market Developments",
                    subtitle: "Macro and flow context without trade calls.",
                    systemImage: "chart.line.uptrend.xyaxis",
                    stories: stories.filter { $0.category == .market || $0.category == .macro }
                ),
                BriefingSection(
                    id: "narratives",
                    title: "Trending Narratives",
                    subtitle: "Themes gaining attention across multiple sources.",
                    systemImage: "waveform.path.ecg",
                    stories: stories.filter { $0.category == .defi || $0.category == .infrastructure }
                ),
                BriefingSection(
                    id: "watchlist",
                    title: "From Your Watchlist",
                    subtitle: "Items connected to followed assets and topics.",
                    systemImage: "star",
                    stories: stories.filter(\.isWatchlistMatch)
                )
            ]
        )
    }

    func searchStories(query: String, filter: StorySearchFilter) async throws -> [BriefStory] {
        try await Task.sleep(nanoseconds: 180_000_000)

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var stories = Self.demoStories

        if !trimmedQuery.isEmpty {
            stories = stories.filter { story in
                story.headline.lowercased().contains(trimmedQuery) ||
                story.summary.lowercased().contains(trimmedQuery) ||
                story.assetTags.contains { $0.symbol.lowercased().contains(trimmedQuery) || $0.name.lowercased().contains(trimmedQuery) }
            }
        }

        if let category = filter.category {
            stories = stories.filter { $0.category == category }
        }

        if let assetSymbol = filter.assetSymbol {
            stories = stories.filter { story in
                story.assetTags.contains { $0.symbol.caseInsensitiveCompare(assetSymbol) == .orderedSame }
            }
        }

        switch filter.sort {
        case .recent:
            stories.sort { $0.publishedAt > $1.publishedAt }
        case .importance:
            let order: [ImportanceLevel: Int] = [.critical: 0, .high: 1, .notable: 2, .routine: 3]
            stories.sort { (order[$0.importance] ?? 9) < (order[$1.importance] ?? 9) }
        case .watchlist:
            stories.sort { ($0.isWatchlistMatch ? 0 : 1) < ($1.isWatchlistMatch ? 0 : 1) }
        case .sourceCount:
            stories.sort { $0.sourceCount > $1.sourceCount }
        }

        return stories
    }

    func story(id: String) async throws -> BriefStory {
        guard let story = Self.demoStories.first(where: { $0.id == id }) else {
            throw MockServiceError.notFound
        }
        return story
    }
}

extension MockNewsService {
    static let demoStories: [BriefStory] = {
        let now = Date()
        let sourceA = SourceAttribution(
            id: "src-demo-001",
            title: "ETF flow desk publishes weekly digital asset fund note",
            publisher: "Demo Market Wire",
            domain: "example.com",
            url: URL(string: "https://example.com/demo/etf-flow-note")!,
            excerpt: "Demo excerpt: weekly flows cooled while derivatives open interest increased.",
            license: .demo,
            publishedAt: now.addingTimeInterval(-1_800)
        )
        let sourceB = SourceAttribution(
            id: "src-demo-002",
            title: "Exchange research team notes changing options positioning",
            publisher: "Demo Exchange Research",
            domain: "example.com",
            url: URL(string: "https://example.com/demo/options-positioning")!,
            excerpt: "Demo excerpt: options positioning widened around near-term policy dates.",
            license: .demo,
            publishedAt: now.addingTimeInterval(-2_600)
        )
        let sourceC = SourceAttribution(
            id: "src-demo-003",
            title: "Regulator opens consultation on stablecoin disclosures",
            publisher: "Demo Public Register",
            domain: "example.org",
            url: URL(string: "https://example.org/demo/stablecoin-consultation")!,
            excerpt: "Demo excerpt: the consultation asks issuers to explain reserves and redemption practices.",
            license: .demo,
            publishedAt: now.addingTimeInterval(-5_200)
        )
        let sourceD = SourceAttribution(
            id: "src-demo-004",
            title: "Protocol foundation posts upgrade testnet status",
            publisher: "Demo Protocol Foundation",
            domain: "example.net",
            url: URL(string: "https://example.net/demo/testnet-status")!,
            excerpt: "Demo excerpt: validators are testing client releases before a proposed mainnet window.",
            license: .demo,
            publishedAt: now.addingTimeInterval(-7_200)
        )
        let sourceE = SourceAttribution(
            id: "src-demo-005",
            title: "Security researchers describe wallet-drainer campaign",
            publisher: "Demo Security Lab",
            domain: "example.security",
            url: URL(string: "https://example.security/demo/wallet-drainer")!,
            excerpt: "Demo excerpt: researchers found a phishing kit targeting multiple EVM chains.",
            license: .demo,
            publishedAt: now.addingTimeInterval(-10_400)
        )
        let sourceF = SourceAttribution(
            id: "src-demo-006",
            title: "DeFi lending protocol proposes risk-parameter update",
            publisher: "Demo Governance Forum",
            domain: "example.community",
            url: URL(string: "https://example.community/demo/risk-parameters")!,
            excerpt: "Demo excerpt: governance members are debating collateral and oracle assumptions.",
            license: .demo,
            publishedAt: now.addingTimeInterval(-12_100)
        )

        return [
            BriefStory(
                id: "story-etf-derivatives",
                headline: "ETF inflows cool as derivatives activity picks up",
                summary: "Demo sources show fund inflows easing while options positioning expands around macro events. The takeaway is a more cautious market structure, not a directional trading signal.",
                context: "Brief: flows cooled but activity did not disappear. Understand: traders may be hedging around policy dates while spot demand normalizes. Verify: two demo sources support the flow and derivatives claims.",
                category: .market,
                importance: .high,
                sentiment: .mixed,
                verificationStatus: .sourceBacked,
                assetTags: [.bitcoin, .ethereum],
                sources: [sourceA, sourceB],
                publishedAt: now.addingTimeInterval(-1_500),
                updatedAt: now.addingTimeInterval(-600),
                readingMinutes: 3,
                isWatchlistMatch: true,
                updates: [
                    StoryUpdate(id: "upd-etf-001", changedAt: now.addingTimeInterval(-600), summary: "Added second source on options positioning.", sourceID: sourceB.id)
                ]
            ),
            BriefStory(
                id: "story-stablecoin-consultation",
                headline: "Stablecoin disclosure consultation puts reserves in focus",
                summary: "A demo public-register notice outlines proposed reserve and redemption disclosures for stablecoin issuers. The story matters because compliance expectations could shape exchange listings and issuer reporting.",
                context: "Brief: policy attention is centered on reserve transparency. Understand: issuers may need clearer reporting if the proposal advances. Verify: the demo public-register source is the anchor.",
                category: .regulation,
                importance: .high,
                sentiment: .cautious,
                verificationStatus: .developing,
                assetTags: [.regulation],
                sources: [sourceC],
                publishedAt: now.addingTimeInterval(-4_900),
                updatedAt: nil,
                readingMinutes: 4,
                isWatchlistMatch: true,
                updates: []
            ),
            BriefStory(
                id: "story-network-upgrade",
                headline: "Network upgrade testing advances before mainnet proposal",
                summary: "A demo protocol foundation update says client teams are testing release candidates on a public testnet. The summary does not assume mainnet timing until a final source confirms it.",
                context: "Brief: testing moved forward. Understand: operators still need final client releases and governance confirmation. Verify: current evidence is one official-style demo source.",
                category: .infrastructure,
                importance: .notable,
                sentiment: .constructive,
                verificationStatus: .developing,
                assetTags: [.ethereum],
                sources: [sourceD],
                publishedAt: now.addingTimeInterval(-7_000),
                updatedAt: nil,
                readingMinutes: 3,
                isWatchlistMatch: true,
                updates: []
            ),
            BriefStory(
                id: "story-wallet-drainer",
                headline: "Security researchers flag multi-chain wallet-drainer campaign",
                summary: "A demo security-lab report describes phishing pages that impersonate common DeFi flows across EVM chains. Users should verify domains and avoid signing unexpected approvals; this is a security notice, not asset advice.",
                context: "Brief: a phishing kit is active in demo reporting. Understand: the risk is transaction approval abuse rather than protocol insolvency. Verify: one security research source is currently available.",
                category: .security,
                importance: .critical,
                sentiment: .risk,
                verificationStatus: .sourceBacked,
                assetTags: [.defi],
                sources: [sourceE],
                publishedAt: now.addingTimeInterval(-9_900),
                updatedAt: now.addingTimeInterval(-1_200),
                readingMinutes: 2,
                isWatchlistMatch: false,
                updates: [
                    StoryUpdate(id: "upd-security-001", changedAt: now.addingTimeInterval(-1_200), summary: "Added affected-chain context from the demo security source.", sourceID: sourceE.id)
                ]
            ),
            BriefStory(
                id: "story-defi-risk-parameters",
                headline: "DeFi lending forum debates risk-parameter changes",
                summary: "A demo governance thread proposes changes to collateral limits and oracle assumptions. The proposal is not final, so CoinBrief labels it as governance context rather than a protocol outcome.",
                context: "Brief: governance is discussing risk settings. Understand: proposals can change before vote execution. Verify: the demo forum thread is the only current evidence.",
                category: .defi,
                importance: .notable,
                sentiment: .mixed,
                verificationStatus: .developing,
                assetTags: [.defi, .ethereum],
                sources: [sourceF],
                publishedAt: now.addingTimeInterval(-12_000),
                updatedAt: nil,
                readingMinutes: 4,
                isWatchlistMatch: true,
                updates: []
            )
        ]
    }()
}

enum MockServiceError: Error {
    case notFound
}

