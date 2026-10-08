import SwiftData
import SwiftUI

@main
struct CoinBriefAIApp: App {
    private let dependencies = AppDependencies.live

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.appDependencies, dependencies)
        }
        .modelContainer(for: [
            SavedStoryRecord.self,
            ReadingHistoryRecord.self,
            UserNoteRecord.self
        ])
    }
}

