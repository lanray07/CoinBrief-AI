import SwiftData
import SwiftUI

struct StoryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isSaved = false

    let story: BriefStory

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        StatusBadge(status: story.verificationStatus)
                        ImportancePill(importance: story.importance)
                    }

                    Text(story.headline)
                        .font(.largeTitle.weight(.bold))
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 10) {
                        Label(story.category.label, systemImage: story.category.systemImage)
                        Label("\(story.readingMinutes) min", systemImage: "clock")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                StoryDetailSection(title: "Brief", systemImage: "text.alignleft") {
                    Text(story.summary)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }

                StoryDetailSection(title: "Understand", systemImage: "lightbulb") {
                    Text(story.context)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if !story.updates.isEmpty {
                    StoryDetailSection(title: "What changed?", systemImage: "arrow.triangle.2.circlepath") {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(story.updates) { update in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(update.changedAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                    Text(update.summary)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }

                StoryDetailSection(title: "Verify", systemImage: "checkmark.seal") {
                    VStack(alignment: .leading, spacing: 12) {
                        if story.sources.isEmpty {
                            EmptyStateView(
                                title: "Sources required",
                                message: "CoinBrief does not display a brief without a verifiable source link.",
                                systemImage: "link.badge.plus"
                            )
                        } else {
                            ForEach(story.sources) { source in
                                SourceRow(source: source)
                            }
                        }
                    }
                }

                StoryDetailSection(title: "Research guardrail", systemImage: "shield") {
                    Text("This story is for information and education only. It is not a recommendation to buy, sell, hold, or trade any asset.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                StoryDetailSection(title: "Evidence record", systemImage: "doc.text.magnifyingglass") {
                    VStack(alignment: .leading, spacing: 10) {
                        EvidenceMetric(label: "Publisher", value: story.sources.first?.publisher ?? "Unavailable")
                        EvidenceMetric(label: "Published", value: story.publishedAt.formatted(date: .abbreviated, time: .shortened))
                        EvidenceMetric(label: "Classification", value: story.category.label)
                        EvidenceMetric(label: "Verification", value: story.verificationStatus.label)
                    }
                }
            }
            .padding(16)
        }
        .background(CoinBriefTheme.background)
        .navigationTitle("Story")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: toggleSaved) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                }
                .accessibilityLabel(isSaved ? "Remove from saved research" : "Save for research")

                if let url = story.primaryURL {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Share primary source")
                }
            }
        }
        .task {
            isSaved = existingRecord() != nil
        }
    }

    private func toggleSaved() {
        if let record = existingRecord() {
            modelContext.delete(record)
            isSaved = false
        } else {
            let record = SavedStoryRecord(
                storyID: story.id,
                headline: story.headline,
                summary: story.summary,
                sourceDomain: story.sources.first?.domain ?? "Source",
                sourceURL: story.primaryURL?.absoluteString ?? "",
                tags: [story.category.label],
                isAvailableOffline: true
            )
            modelContext.insert(record)
            isSaved = true
        }
        try? modelContext.save()
    }

    private func existingRecord() -> SavedStoryRecord? {
        let storyID = story.id
        var descriptor = FetchDescriptor<SavedStoryRecord>(
            predicate: #Predicate { $0.storyID == storyID }
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }
}

private struct EvidenceMetric: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}

private struct StoryDetailSection<Content: View>: View {
    let title: String
    let systemImage: String
    private let content: Content

    init(title: String, systemImage: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: title, subtitle: "", systemImage: systemImage)
            content
        }
        .padding(16)
        .coinCard()
    }
}

private struct SourceRow: View {
    let source: SourceAttribution

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(source.publisher)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(source.license.label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CoinBriefTheme.violet)
            }

            Text(source.title)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            Text(source.excerpt)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Link(destination: source.url) {
                Label(source.domain, systemImage: "arrow.up.right")
                    .font(.caption.weight(.semibold))
            }
        }
        .padding(12)
        .background(CoinBriefTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        StoryDetailView(story: MockNewsService.demoStories[0])
    }
}
#endif
