import AppIntents

enum BriefingEditionIntentOption: String, AppEnum {
    case morning
    case evening
    case breaking

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Briefing Edition")

    static var caseDisplayRepresentations: [BriefingEditionIntentOption: DisplayRepresentation] = [
        .morning: "Morning",
        .evening: "Evening",
        .breaking: "Breaking"
    ]
}

struct OpenBriefingIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Briefing"
    static var description = IntentDescription("Open a source-backed CoinBrief AI briefing.")
    static var openAppWhenRun = true

    @Parameter(title: "Edition")
    var edition: BriefingEditionIntentOption

    init() {
        edition = .morning
    }

    init(edition: BriefingEditionIntentOption) {
        self.edition = edition
    }

    func perform() async throws -> some IntentResult {
        .result()
    }
}

struct OpenWatchlistIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Watchlist"
    static var description = IntentDescription("Open followed crypto assets, protocols, sectors, and regulatory topics.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}

struct StartAudioBriefingIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Audio Briefing"
    static var description = IntentDescription("Open the transcript-first daily audio briefing.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}

struct CoinBriefShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenBriefingIntent(),
            phrases: [
                "Open \(.applicationName) briefing",
                "Show my \(.applicationName) brief"
            ],
            shortTitle: "Briefing",
            systemImageName: "newspaper"
        )

        AppShortcut(
            intent: OpenWatchlistIntent(),
            phrases: [
                "Open \(.applicationName) watchlist",
                "Show my \(.applicationName) watchlist"
            ],
            shortTitle: "Watchlist",
            systemImageName: "star"
        )

        AppShortcut(
            intent: StartAudioBriefingIntent(),
            phrases: [
                "Start \(.applicationName) audio",
                "Play my \(.applicationName) briefing"
            ],
            shortTitle: "Audio",
            systemImageName: "headphones"
        )
    }
}

