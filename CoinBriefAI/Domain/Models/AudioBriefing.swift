import Foundation

struct AudioBriefing: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let title: String
    let durationSeconds: Int
    let transcript: String
    let chapters: [AudioChapter]
    let sourceStoryIDs: [String]
    let createdAt: Date
}

struct AudioChapter: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let title: String
    let startSeconds: Int
    let storyID: String
}

