import Foundation

actor MockWatchlistService: WatchlistService {
    private var items: [WatchlistItem] = [
        WatchlistItem(
            id: UUID(),
            title: "Bitcoin",
            symbol: "BTC",
            kind: .coin,
            alertSensitivity: .importantOnly,
            isNotificationsEnabled: true,
            addedAt: .now.addingTimeInterval(-86_400),
            matchedStoryCount: 2,
            latestNarrative: "ETF flows and macro hedging"
        ),
        WatchlistItem(
            id: UUID(),
            title: "Ethereum",
            symbol: "ETH",
            kind: .coin,
            alertSensitivity: .majorOnly,
            isNotificationsEnabled: true,
            addedAt: .now.addingTimeInterval(-172_800),
            matchedStoryCount: 3,
            latestNarrative: "Client testing and DeFi governance"
        ),
        WatchlistItem(
            id: UUID(),
            title: "Stablecoin policy",
            symbol: "Policy",
            kind: .regulation,
            alertSensitivity: .importantOnly,
            isNotificationsEnabled: false,
            addedAt: .now.addingTimeInterval(-259_200),
            matchedStoryCount: 1,
            latestNarrative: "Reserve transparency proposals"
        )
    ]

    func watchlist() async throws -> [WatchlistItem] {
        items
    }

    func add(_ item: WatchlistItem) async throws {
        items.insert(item, at: 0)
    }

    func update(_ item: WatchlistItem) async throws {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index] = item
    }

    func remove(id: UUID) async throws {
        items.removeAll { $0.id == id }
    }
}

