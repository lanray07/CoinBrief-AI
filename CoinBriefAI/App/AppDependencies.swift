import SwiftUI

struct AppDependencies: @unchecked Sendable {
    var newsService: any NewsService
    var sourceLibrary: any SourceLibraryServicing
    var subscriptionService: any SubscriptionServicing
    var notificationService: any NotificationScheduling
    var secureTokenStore: any SecureTokenStoring

    static let live = AppDependencies(
        newsService: LiveNewsService(),
        sourceLibrary: SourceStore.shared,
        subscriptionService: StoreKitSubscriptionService(),
        notificationService: LocalNotificationScheduler(),
        secureTokenStore: KeychainTokenStore(service: "com.CoinBriefAI.app")
    )

    #if DEBUG
    static let preview = AppDependencies(
        newsService: MockNewsService(),
        sourceLibrary: SourceStore.shared,
        subscriptionService: MockSubscriptionService(),
        notificationService: LocalNotificationScheduler(),
        secureTokenStore: KeychainTokenStore(service: "com.CoinBriefAI.app")
    )
    #endif
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
