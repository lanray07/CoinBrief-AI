import XCTest
@testable import CoinBriefAI

final class LiveSourceTests: XCTestCase {
    func testParsesRSSWithEvidenceMetadata() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
          <channel>
            <title>Protocol Updates</title>
            <link>https://example.org</link>
            <item>
              <guid>update-1</guid>
              <title>Network upgrade reaches public testnet</title>
              <link>https://example.org/upgrade</link>
              <description><![CDATA[Client teams published the upgrade test plan.]]></description>
              <pubDate>Thu, 08 Oct 2026 09:30:00 +0000</pubDate>
            </item>
          </channel>
        </rss>
        """

        let document = try RSSFeedClient.parse(
            data: Data(xml.utf8),
            sourceURL: URL(string: "https://example.org/feed.xml")!
        )

        XCTAssertEqual(document.title, "Protocol Updates")
        XCTAssertEqual(document.items.count, 1)
        XCTAssertEqual(document.items[0].id, "update-1")
        XCTAssertEqual(document.items[0].link.absoluteString, "https://example.org/upgrade")
        XCTAssertEqual(document.items[0].summary, "Client teams published the upgrade test plan.")
    }

    func testParsesAtomAlternateLink() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <feed xmlns="http://www.w3.org/2005/Atom">
          <title>Research Desk</title>
          <link href="https://example.net" rel="alternate" />
          <entry>
            <id>tag:example.net,2026:2</id>
            <title>Security review published</title>
            <link href="https://example.net/review" rel="alternate" />
            <summary>Independent reviewers documented the findings.</summary>
            <updated>2026-10-08T10:00:00Z</updated>
          </entry>
        </feed>
        """

        let document = try RSSFeedClient.parse(
            data: Data(xml.utf8),
            sourceURL: URL(string: "https://example.net/feed")!
        )

        XCTAssertEqual(document.items.count, 1)
        XCTAssertEqual(document.items[0].link.absoluteString, "https://example.net/review")
        XCTAssertEqual(document.items[0].title, "Security review published")
    }

    func testClassificationKeepsRegulationAndSecurityDistinct() {
        XCTAssertEqual(LiveNewsService.classify("the sec announced a new enforcement action"), .regulation)
        XCTAssertEqual(LiveNewsService.classify("security researchers disclose a wallet exploit"), .security)
        XCTAssertEqual(LiveNewsService.classify("client teams launch a protocol testnet"), .infrastructure)
    }

    func testBuiltInSourcesAreRealHTTPSFeeds() {
        XCTAssertEqual(FeedSource.builtIns.count, 4)
        XCTAssertTrue(FeedSource.builtIns.allSatisfy { $0.feedURL.scheme == "https" })
        XCTAssertTrue(FeedSource.builtIns.allSatisfy { $0.isBuiltIn })
    }
}
