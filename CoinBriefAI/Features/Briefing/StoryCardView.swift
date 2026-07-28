import SwiftUI

struct StoryCardView: View {
    let story: BriefStory

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Label(story.category.label, systemImage: story.category.systemImage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CoinBriefTheme.cyan)
                    .lineLimit(1)

                Spacer(minLength: 8)

                ImportancePill(importance: story.importance)
            }

            Text(story.headline)
                .font(.headline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(story.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(story.assetTags) { asset in
                        AssetPill(asset: asset)
                    }
                }
            }
            .scrollClipDisabled()

            HStack(spacing: 8) {
                StatusBadge(status: story.verificationStatus)
                SentimentBadge(sentiment: story.sentiment)
            }

            Divider()

            HStack(spacing: 12) {
                Label("\(story.sourceCount) source\(story.sourceCount == 1 ? "" : "s")", systemImage: "link")
                Label("\(story.readingMinutes) min", systemImage: "clock")
                Spacer()
                if story.isWatchlistMatch {
                    Image(systemName: "star.fill")
                        .foregroundStyle(CoinBriefTheme.amber)
                        .accessibilityLabel("Matches your watchlist")
                }
                if let url = story.primaryURL {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                            .accessibilityLabel("Share story source")
                    }
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .coinCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(story.headline). \(story.summary). \(story.verificationStatus.label). \(story.sourceCount) sources.")
    }
}

#Preview {
    StoryCardView(story: MockNewsService.demoStories[0])
        .padding()
        .background(CoinBriefTheme.background)
}

