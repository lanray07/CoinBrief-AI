import SwiftData
import SwiftUI

struct SavedView: View {
    @Query(sort: \SavedStoryRecord.savedAt, order: .reverse) private var savedRecords: [SavedStoryRecord]
    @State private var selectedCollection = "All"

    private var snapshots: [SavedStorySnapshot] {
        let stored = savedRecords.map(SavedStorySnapshot.init(record:))
        return stored.isEmpty ? SavedPreviewData.snapshots : stored
    }

    private var collections: [String] {
        ["All", "Policy", "Security", "DeFi", "Offline"]
    }

    private var filteredSnapshots: [SavedStorySnapshot] {
        guard selectedCollection != "All" else { return snapshots }
        if selectedCollection == "Offline" {
            return snapshots.filter(\.isAvailableOffline)
        }
        return snapshots.filter { $0.tags.contains(selectedCollection) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(
                        title: "Saved Research",
                        subtitle: "Bookmarks, notes, collections, history, and offline reading.",
                        systemImage: "bookmark"
                    )

                    Picker("Collection", selection: $selectedCollection) {
                        ForEach(collections, id: \.self) { collection in
                            Text(collection).tag(collection)
                        }
                    }
                    .pickerStyle(.segmented)

                    if filteredSnapshots.isEmpty {
                        EmptyStateView(
                            title: "Nothing saved here",
                            message: "Save source-backed stories to build a research queue.",
                            systemImage: "tray"
                        )
                    } else {
                        ForEach(filteredSnapshots) { snapshot in
                            SavedStoryRow(snapshot: snapshot)
                        }
                    }
                }
                .padding(16)
            }
            .background(CoinBriefTheme.background)
            .navigationTitle("Saved")
        }
    }
}

private struct SavedStorySnapshot: Identifiable, Hashable {
    let id: String
    let headline: String
    let summary: String
    let sourceDomain: String
    let savedAt: Date
    let tags: [String]
    let note: String
    let isAvailableOffline: Bool

    init(record: SavedStoryRecord) {
        id = record.storyID
        headline = record.headline
        summary = record.summary
        sourceDomain = record.sourceDomain
        savedAt = record.savedAt
        tags = record.tags
        note = record.note
        isAvailableOffline = record.isAvailableOffline
    }

    init(id: String, headline: String, summary: String, sourceDomain: String, savedAt: Date, tags: [String], note: String, isAvailableOffline: Bool) {
        self.id = id
        self.headline = headline
        self.summary = summary
        self.sourceDomain = sourceDomain
        self.savedAt = savedAt
        self.tags = tags
        self.note = note
        self.isAvailableOffline = isAvailableOffline
    }
}

private enum SavedPreviewData {
    static let snapshots = [
        SavedStorySnapshot(
            id: "saved-policy",
            headline: "Stablecoin disclosure consultation puts reserves in focus",
            summary: "Saved demo story with policy tag and offline availability.",
            sourceDomain: "example.org",
            savedAt: .now.addingTimeInterval(-3_600),
            tags: ["Policy", "Offline"],
            note: "Review reserve-disclosure proposal after final source update.",
            isAvailableOffline: true
        ),
        SavedStorySnapshot(
            id: "saved-security",
            headline: "Security researchers flag multi-chain wallet-drainer campaign",
            summary: "Saved demo story with security context and source checks.",
            sourceDomain: "example.security",
            savedAt: .now.addingTimeInterval(-9_000),
            tags: ["Security"],
            note: "Useful for Trust Centre security explainer.",
            isAvailableOffline: false
        )
    ]
}

private struct SavedStoryRow: View {
    let snapshot: SavedStorySnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(snapshot.headline)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                if snapshot.isAvailableOffline {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundStyle(CoinBriefTheme.mint)
                        .accessibilityLabel("Available offline")
                }
            }

            Text(snapshot.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if !snapshot.note.isEmpty {
                Label(snapshot.note, systemImage: "note.text")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack {
                ForEach(snapshot.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(CoinBriefTheme.violet.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                }
                Spacer()
                ShareLink(item: "CoinBrief AI saved summary: \(snapshot.headline)\n\(snapshot.summary)\nSource: \(snapshot.sourceDomain)") {
                    Image(systemName: "square.and.arrow.up")
                        .accessibilityLabel("Export saved summary")
                }
            }
        }
        .padding(16)
        .coinCard()
    }
}

#Preview {
    SavedView()
}

