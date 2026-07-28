import XCTest
@testable import CoinBriefAI

final class SummaryGroundingTests: XCTestCase {
    func testEveryDemoStoryHasAtLeastOneSource() async throws {
        let service = MockNewsService()
        let briefing = try await service.fetchBriefing(preferences: .demo, edition: .morning)
        let stories = briefing.sections.flatMap(\.stories)

        XCTAssertFalse(stories.isEmpty)
        XCTAssertTrue(stories.allSatisfy { !$0.sources.isEmpty })
        XCTAssertTrue(stories.allSatisfy { $0.summary.localizedCaseInsensitiveContains("buy") == false })
    }

    func testSearchPreservesSourceAttribution() async throws {
        let service = MockNewsService()
        let results = try await service.searchStories(query: "security", filter: .default)

        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { !$0.sources.isEmpty })
    }
}

