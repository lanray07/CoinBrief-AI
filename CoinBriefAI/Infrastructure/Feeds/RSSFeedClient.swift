import Foundation
#if os(Windows) || os(Linux)
import FoundationXML
#endif
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct RSSFeedItem: Hashable, Sendable {
    let id: String
    let title: String
    let link: URL
    let summary: String
    let publishedAt: Date
}

struct RSSFeedDocument: Hashable, Sendable {
    let title: String
    let websiteURL: URL?
    let items: [RSSFeedItem]
}

enum RSSFeedError: LocalizedError {
    case invalidResponse
    case unsupportedDocument
    case noItems
    case documentTooLarge

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "The source did not return a valid response."
        case .unsupportedDocument: "The URL is not a supported RSS or Atom feed."
        case .noItems: "The feed does not contain any readable entries."
        case .documentTooLarge: "The feed is too large to process safely."
        }
    }
}

enum RSSFeedClient {
    static func fetch(url: URL) async throws -> RSSFeedDocument {
        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.setValue("CoinBriefAI/1.0 (source reader)", forHTTPHeaderField: "User-Agent")
        request.setValue("application/rss+xml, application/atom+xml, application/xml, text/xml", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw RSSFeedError.invalidResponse
        }
        guard data.count <= 5_000_000 else { throw RSSFeedError.documentTooLarge }

        return try parse(data: data, sourceURL: url)
    }

    static func parse(data: Data, sourceURL: URL) throws -> RSSFeedDocument {
        let delegate = RSSParserDelegate(sourceURL: sourceURL)
        let parser = XMLParser(data: data)
        parser.delegate = delegate

        guard parser.parse(), delegate.detectedFeed else {
            throw parser.parserError ?? RSSFeedError.unsupportedDocument
        }

        let items = delegate.items.filter { !$0.title.isEmpty }
        guard !items.isEmpty else { throw RSSFeedError.noItems }

        return RSSFeedDocument(
            title: delegate.feedTitle.isEmpty ? sourceURL.host ?? "RSS Source" : delegate.feedTitle,
            websiteURL: delegate.websiteURL,
            items: items
        )
    }
}

private final class RSSParserDelegate: NSObject, XMLParserDelegate, @unchecked Sendable {
    private let sourceURL: URL
    private var elementStack: [String] = []
    private var textBuffer = ""
    private var currentTitle = ""
    private var currentLink: URL?
    private var currentSummary = ""
    private var currentIdentifier = ""
    private var currentPublishedAt: Date?
    private var insideItem = false

    private(set) var detectedFeed = false
    private(set) var feedTitle = ""
    private(set) var websiteURL: URL?
    private(set) var items: [RSSFeedItem] = []

    init(sourceURL: URL) {
        self.sourceURL = sourceURL
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        let element = elementName.lowercased()
        elementStack.append(element)
        textBuffer = ""

        if element == "rss" || element == "feed" {
            detectedFeed = true
        }

        if element == "item" || element == "entry" {
            insideItem = true
            currentTitle = ""
            currentLink = nil
            currentSummary = ""
            currentIdentifier = ""
            currentPublishedAt = nil
        }

        if element == "link", let href = attributeDict["href"], let url = resolvedURL(href) {
            let relation = attributeDict["rel"]?.lowercased()
            if insideItem, relation == nil || relation == "alternate" {
                currentLink = url
            } else if !insideItem, relation == nil || relation == "alternate" {
                websiteURL = url
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        textBuffer += string
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if let string = String(data: CDATABlock, encoding: .utf8) {
            textBuffer += string
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        let element = elementName.lowercased()
        let value = textBuffer.trimmingCharacters(in: .whitespacesAndNewlines)

        if insideItem {
            switch element {
            case "title": currentTitle = clean(value)
            case "link":
                if currentLink == nil { currentLink = resolvedURL(value) }
            case "description", "summary", "content", "content:encoded":
                if value.count > currentSummary.count { currentSummary = clean(value) }
            case "guid", "id": currentIdentifier = value
            case "pubdate", "published", "updated", "dc:date":
                currentPublishedAt = parseDate(value) ?? currentPublishedAt
            case "item", "entry": finishItem()
            default: break
            }
        } else {
            if element == "title", feedTitle.isEmpty {
                feedTitle = clean(value)
            } else if element == "link", websiteURL == nil {
                websiteURL = resolvedURL(value)
            }
        }

        _ = elementStack.popLast()
        textBuffer = ""
    }

    private func finishItem() {
        defer { insideItem = false }
        guard let link = currentLink else { return }
        let identifier = currentIdentifier.isEmpty ? link.absoluteString : currentIdentifier
        items.append(
            RSSFeedItem(
                id: identifier,
                title: currentTitle,
                link: link,
                summary: currentSummary,
                publishedAt: currentPublishedAt ?? .now
            )
        )
    }

    private func resolvedURL(_ value: String) -> URL? {
        if let absolute = URL(string: value), absolute.scheme != nil { return absolute }
        return URL(string: value, relativeTo: sourceURL)?.absoluteURL
    }

    private func clean(_ value: String) -> String {
        let withoutTags = value.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        let decoded = withoutTags
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
        return decoded
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseDate(_ value: String) -> Date? {
        let internetDateFormatter = ISO8601DateFormatter()
        if let date = internetDateFormatter.date(from: value) { return date }

        let formats = [
            "EEE, dd MMM yyyy HH:mm:ss Z",
            "EEE, d MMM yyyy HH:mm:ss Z",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd HH:mm:ss Z"
        ]

        for format in formats {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format
            if let date = formatter.date(from: value) { return date }
        }
        return nil
    }
}
