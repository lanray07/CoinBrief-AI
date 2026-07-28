import SwiftUI

struct TrustCentreView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Trust Centre")
                    .font(.largeTitle.weight(.bold))

                TrustPanel(
                    title: "Source-backed summaries",
                    systemImage: "checkmark.seal",
                    bodyText: "Every story must carry source links, publisher names, timestamps, and a verification label. Unsupported summaries are rejected before display."
                )

                TrustPanel(
                    title: "Verification labels",
                    systemImage: "tag",
                    bodyText: "Source-backed means evidence is available. Developing means facts may change. Conflicting means credible sources disagree. Corrected means the story changed after publication."
                )

                TrustPanel(
                    title: "AI limitations",
                    systemImage: "brain.head.profile",
                    bodyText: "AI can compress source material, but it can miss nuance. CoinBrief AI should be treated as a research starting point, not a decision engine."
                )

                TrustPanel(
                    title: "What we do not do",
                    systemImage: "nosign",
                    bodyText: "No trading, exchange, custody, staking, lending, price targets, portfolio management, investment advice, or buy/sell/hold recommendations."
                )

                TrustPanel(
                    title: "Privacy posture",
                    systemImage: "hand.raised",
                    bodyText: "The intended launch version avoids tracking and advertising identifiers. App Store privacy answers must be updated to match the final backend and SDK stack."
                )
            }
            .padding(16)
        }
        .background(CoinBriefTheme.background)
        .navigationTitle("Trust")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct TrustPanel: View {
    let title: String
    let systemImage: String
    let bodyText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(CoinBriefTheme.cyan)
            Text(bodyText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .coinCard()
    }
}

#Preview {
    NavigationStack {
        TrustCentreView()
    }
}

