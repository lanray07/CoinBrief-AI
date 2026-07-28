import XCTest
@testable import CoinBriefAI

final class WatchlistTests: XCTestCase {
    func testWatchlistCanAddTopicWithoutTradingLanguage() async throws {
        let service = MockWatchlistService()
        let item = WatchlistItem(
            id: UUID(),
            title: "Layer 2 scaling",
            symbol: "L2",
            kind: .sector,
            alertSensitivity: .importantOnly,
            isNotificationsEnabled: true,
            addedAt: .now,
            matchedStoryCount: 0,
            latestNarrative: "Throughput and fee discussions"
        )

        try await service.add(item)
        let items = try await service.watchlist()

        XCTAssertTrue(items.contains { $0.symbol == "L2" })
        XCTAssertFalse(items.contains { $0.latestNarrative.localizedCaseInsensitiveContains("buy") })
    }
}

