import Foundation

struct MockAudioBriefingService: AudioBriefingServicing {
    func makeBriefing(from stories: [BriefStory], preferences: UserPreferences) async throws -> AudioBriefing {
        try await Task.sleep(nanoseconds: 200_000_000)

        let chapters = stories.prefix(4).enumerated().map { index, story in
            AudioChapter(
                id: UUID(),
                title: story.headline,
                startSeconds: index * 75,
                storyID: story.id
            )
        }

        let transcript = stories.prefix(4)
            .map { "\($0.headline). \($0.summary)" }
            .joined(separator: "\n\n")

        return AudioBriefing(
            id: UUID(),
            title: "Personalised Daily Briefing",
            durationSeconds: max(180, chapters.count * 75),
            transcript: transcript,
            chapters: chapters,
            sourceStoryIDs: stories.map(\.id),
            createdAt: .now
        )
    }
}

