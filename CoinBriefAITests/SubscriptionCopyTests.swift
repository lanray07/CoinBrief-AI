import XCTest
@testable import CoinBriefAI

final class SubscriptionCopyTests: XCTestCase {
    func testProCapabilitiesMatchProductBrief() {
        let capabilities = Set(ProCapability.allCases.map(\.label))

        XCTAssertTrue(capabilities.contains("Unlimited summaries"))
        XCTAssertTrue(capabilities.contains("Audio briefings"))
        XCTAssertTrue(capabilities.contains("Custom alerts"))
        XCTAssertFalse(capabilities.contains { $0.localizedCaseInsensitiveContains("trading signal") })
    }

    func testMockPurchaseActivatesProEntitlement() async throws {
        let service = MockSubscriptionService()
        let entitlement = try await service.purchase(productID: "com.coinbriefai.pro.monthly")

        XCTAssertTrue(entitlement.isActive)
        XCTAssertEqual(entitlement.tier, .pro)
        XCTAssertTrue(entitlement.capabilities.contains(.deepDive))
    }
}

