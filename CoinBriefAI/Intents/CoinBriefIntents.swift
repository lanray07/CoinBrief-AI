import AppIntents

enum BriefingEditionIntentOption: String, AppEnum {
    case morning
    case evening
    case breaking

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Briefing Edition")

    static let caseDisplayRepresentations: [BriefingEditionIntentOption: DisplayRepresentation] = [
        .morning: "Morning",
        .evening: "Evening",
        .breaking: "Breaking"
    ]
}

struct OpenBriefingIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Briefing"
    static let description = IntentDescription("Open a source-backed CoinBrief AI briefing.")
    static let openAppWhenRun = true

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

struct OpenSourcesIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Sources"
    static let description = IntentDescription("Open the evidence source library.")
    static let openAppWhenRun = true

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
            intent: OpenSourcesIntent(),
            phrases: [
                "Open \(.applicationName) sources",
                "Show my \(.applicationName) source library"
            ],
            shortTitle: "Sources",
            systemImageName: "link"
        )
    }
}
