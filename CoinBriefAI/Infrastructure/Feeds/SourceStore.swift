import Foundation

actor SourceStore: SourceLibraryServicing {
    static let shared = SourceStore()

    private let storageURL: URL
    private var cachedSources: [FeedSource]?

    init(storageURL: URL? = nil) {
        if let storageURL {
            self.storageURL = storageURL
        } else {
            let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                .appendingPathComponent("CoinBriefAI", isDirectory: true)
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            self.storageURL = directory.appendingPathComponent("sources.json")
        }
    }

    func sources() async -> [FeedSource] {
        if let cachedSources { return cachedSources }
        guard let data = try? Data(contentsOf: storageURL),
              let stored = try? JSONDecoder().decode([FeedSource].self, from: data) else {
            cachedSources = FeedSource.builtIns
            return FeedSource.builtIns
        }

        let merged = mergeBuiltIns(into: stored)
        cachedSources = merged
        return merged
    }

    func add(feedURL: URL) async throws -> FeedSource {
        guard feedURL.scheme == "https" else {
            throw SourceLibraryError.invalidURL
        }

        var current = await sources()
        guard !current.contains(where: { $0.feedURL.absoluteString.caseInsensitiveCompare(feedURL.absoluteString) == .orderedSame }) else {
            throw SourceLibraryError.duplicate
        }

        let document = try await RSSFeedClient.fetch(url: feedURL)
        let source = FeedSource(
            title: String(document.title.prefix(80)),
            feedURL: feedURL,
            websiteURL: document.websiteURL,
            kind: .custom,
            isBuiltIn: false
        )
        current.append(source)
        try persist(current)
        return source
    }

    func setEnabled(_ isEnabled: Bool, id: String) async throws {
        var current = await sources()
        guard let index = current.firstIndex(where: { $0.id == id }) else {
            throw SourceLibraryError.notFound
        }
        current[index].isEnabled = isEnabled
        try persist(current)
    }

    func remove(id: String) async throws {
        var current = await sources()
        guard let source = current.first(where: { $0.id == id }) else {
            throw SourceLibraryError.notFound
        }
        guard !source.isBuiltIn else { throw SourceLibraryError.builtInSource }
        current.removeAll { $0.id == id }
        try persist(current)
    }

    private func mergeBuiltIns(into stored: [FeedSource]) -> [FeedSource] {
        var merged = stored
        for builtIn in FeedSource.builtIns where !merged.contains(where: { $0.id == builtIn.id }) {
            merged.append(builtIn)
        }
        return merged
    }

    private func persist(_ sources: [FeedSource]) throws {
        let data = try JSONEncoder().encode(sources)
        try data.write(to: storageURL, options: .atomic)
        cachedSources = sources
    }
}

enum SourceLibraryError: LocalizedError {
    case invalidURL
    case duplicate
    case notFound
    case builtInSource

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Enter a complete HTTPS feed URL."
        case .duplicate: "That source is already in your library."
        case .notFound: "The source could not be found."
        case .builtInSource: "Built-in sources can be disabled but not removed."
        }
    }
}
