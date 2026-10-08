import Foundation
import SwiftData

@Model
final class SavedStoryRecord {
    @Attribute(.unique) var storyID: String
    var headline: String
    var summary: String
    var sourceDomain: String
    var sourceURL: String = ""
    var savedAt: Date
    var tags: [String]
    var note: String
    var isAvailableOffline: Bool

    init(
        storyID: String,
        headline: String,
        summary: String,
        sourceDomain: String,
        sourceURL: String = "",
        savedAt: Date = .now,
        tags: [String] = [],
        note: String = "",
        isAvailableOffline: Bool = false
    ) {
        self.storyID = storyID
        self.headline = headline
        self.summary = summary
        self.sourceDomain = sourceDomain
        self.sourceURL = sourceURL
        self.savedAt = savedAt
        self.tags = tags
        self.note = note
        self.isAvailableOffline = isAvailableOffline
    }
}

@Model
final class ReadingHistoryRecord {
    @Attribute(.unique) var storyID: String
    var headline: String
    var lastReadAt: Date
    var progress: Double

    init(storyID: String, headline: String, lastReadAt: Date = .now, progress: Double = 0) {
        self.storyID = storyID
        self.headline = headline
        self.lastReadAt = lastReadAt
        self.progress = progress
    }
}

@Model
final class UserNoteRecord {
    @Attribute(.unique) var storyID: String
    var note: String
    var updatedAt: Date

    init(storyID: String, note: String, updatedAt: Date = .now) {
        self.storyID = storyID
        self.note = note
        self.updatedAt = updatedAt
    }
}

