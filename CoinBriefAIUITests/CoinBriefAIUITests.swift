import XCTest

final class CoinBriefAIUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchShowsCoinBriefExperience() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(
            app.staticTexts["CoinBrief AI"].waitForExistence(timeout: 3) ||
            app.navigationBars["Briefing"].waitForExistence(timeout: 3)
        )
    }
}

