import Foundation

struct StorySearchFilter: Hashable, Sendable {
    var category: StoryCategory?
    var assetSymbol: String?
    var sort: StorySort

    static let `default` = StorySearchFilter(category: nil, assetSymbol: nil, sort: .recent)
}

enum StorySort: String, CaseIterable, Identifiable, Hashable, Sendable {
    case recent
    case importance
    case watchlist
    case sourceCount

    var id: String { rawValue }

    var label: String {
        switch self {
        case .recent: "Recent"
        case .importance: "Importance"
        case .watchlist: "Watchlist"
        case .sourceCount: "Sources"
        }
    }
}

protocol NewsService: Sendable {
    func fetchBriefing(preferences: UserPreferences, edition: BriefingEdition) async throws -> Briefing
    func searchStories(query: String, filter: StorySearchFilter) async throws -> [BriefStory]
    func story(id: String) async throws -> BriefStory
}

protocol WatchlistService: Sendable {
    func watchlist() async throws -> [WatchlistItem]
    func add(_ item: WatchlistItem) async throws
    func update(_ item: WatchlistItem) async throws
    func remove(id: UUID) async throws
}

protocol SubscriptionServicing: Sendable {
    func products() async throws -> [SubscriptionProduct]
    func currentEntitlement() async -> SubscriptionEntitlement
    func purchase(productID: String) async throws -> SubscriptionEntitlement
    func restorePurchases() async throws -> SubscriptionEntitlement
}

protocol NotificationScheduling: Sendable {
    func requestAuthorization() async throws -> Bool
    func rules() async -> [NotificationRule]
    func update(rule: NotificationRule) async throws
    func scheduleDigest(rule: NotificationRule) async throws
}

protocol AudioBriefingServicing: Sendable {
    func makeBriefing(from stories: [BriefStory], preferences: UserPreferences) async throws -> AudioBriefing
}

protocol SecureTokenStoring: Sendable {
    func save(token: String, account: String) throws
    func token(account: String) throws -> String?
    func delete(account: String) throws
}
