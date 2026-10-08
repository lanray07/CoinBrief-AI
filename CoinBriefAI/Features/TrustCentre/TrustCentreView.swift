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
                    title: "Automation limits",
                    systemImage: "brain.head.profile",
                    bodyText: "Automated extraction and classification can miss nuance. CoinBrief is a research starting point, so each report keeps a direct link to the original source."
                )

                TrustPanel(
                    title: "What we do not do",
                    systemImage: "nosign",
                    bodyText: "No trading, exchange, custody, staking, lending, price targets, portfolio management, investment advice, or buy/sell/hold recommendations."
                )

                TrustPanel(
                    title: "Privacy posture",
                    systemImage: "hand.raised",
                    bodyText: "Source preferences and cached reports stay on this device. CoinBrief does not include advertising identifiers or third-party tracking SDKs."
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

