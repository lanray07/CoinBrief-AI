import SwiftUI

struct AppDependencies: @unchecked Sendable {
    var newsService: any NewsService
    var watchlistService: any WatchlistService
    var subscriptionService: any SubscriptionServicing
    var notificationService: any NotificationScheduling
    var audioBriefingService: any AudioBriefingServicing
    var secureTokenStore: any SecureTokenStoring

    static let live = AppDependencies(
        newsService: MockNewsService(),
        watchlistService: MockWatchlistService(),
        subscriptionService: StoreKitSubscriptionService(),
        notificationService: LocalNotificationScheduler(),
        audioBriefingService: MockAudioBriefingService(),
        secureTokenStore: KeychainTokenStore(service: "com.CoinBriefAI.app")
    )

    static let preview = AppDependencies(
        newsService: MockNewsService(),
        watchlistService: MockWatchlistService(),
        subscriptionService: MockSubscriptionService(),
        notificationService: LocalNotificationScheduler(),
        audioBriefingService: MockAudioBriefingService(),
        secureTokenStore: KeychainTokenStore(service: "com.CoinBriefAI.app")
    )
}

private struct AppDependenciesKey: EnvironmentKey {
    static let defaultValue = AppDependencies.live
}

extension EnvironmentValues {
    var appDependencies: AppDependencies {
        get { self[AppDependenciesKey.self] }
        set { self[AppDependenciesKey.self] = newValue }
    }
}
