import SwiftUI

struct StatusBadge: View {
    let status: VerificationStatus

    var body: some View {
        Label(status.label, systemImage: status.systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(status.tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(status.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            .accessibilityLabel("Verification status: \(status.label)")
    }
}

struct AssetPill: View {
    let asset: AssetTag

    var body: some View {
        Text(asset.symbol)
            .font(.caption.weight(.bold))
            .foregroundStyle(Color(hex: asset.colorHex))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color(hex: asset.colorHex).opacity(0.14), in: RoundedRectangle(cornerRadius: 8))
            .accessibilityLabel("\(asset.name), \(asset.kind.label)")
    }
}

struct ImportancePill: View {
    let importance: ImportanceLevel

    var body: some View {
        Label(importance.label, systemImage: importance == .critical ? "exclamationmark.triangle.fill" : "circle.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(CoinBriefTheme.storyTint(for: importance))
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(CoinBriefTheme.storyTint(for: importance).opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct SentimentBadge: View {
    let sentiment: StorySentiment

    var body: some View {
        Label(sentiment.label, systemImage: sentiment.systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(sentiment.tint)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(sentiment.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            .accessibilityLabel("Sentiment: \(sentiment.label)")
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(CoinBriefTheme.cyan)
                .frame(width: 22)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(CoinBriefTheme.violet)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(CoinBriefTheme.surface, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(CoinBriefTheme.stroke)
        )
    }
}

struct LoadingSkeletonView: View {
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 10) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(CoinBriefTheme.stroke)
                        .frame(width: 140, height: 14)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(CoinBriefTheme.stroke)
                        .frame(height: 22)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(CoinBriefTheme.stroke)
                        .frame(height: 14)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(CoinBriefTheme.surface, in: RoundedRectangle(cornerRadius: 8))
                .redacted(reason: .placeholder)
                .accessibilityLabel("Loading briefing story")
            }
        }
    }
}

struct PrimaryActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .tint(CoinBriefTheme.cyan)
    }
}

extension View {
    func coinCard() -> some View {
        self
            .background(CoinBriefTheme.surface, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(CoinBriefTheme.stroke)
            )
    }
}

