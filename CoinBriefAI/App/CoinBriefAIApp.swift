import SwiftData
import SwiftUI

@main
struct CoinBriefAIApp: App {
    private let dependencies = AppDependencies.preview

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.appDependencies, dependencies)
        }
        .modelContainer(for: [
            SavedStoryRecord.self,
            WatchlistRecord.self,
            ReadingHistoryRecord.self,
            UserNoteRecord.self
        ])
    }
}

