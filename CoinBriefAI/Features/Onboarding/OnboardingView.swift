import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CoinBrief AI")
                            .font(.largeTitle.weight(.bold))
                        Text("Source-backed crypto news for calm daily research.")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    OnboardingPrinciple(
                        title: "Live, chosen sources",
                        detail: "Start with official protocol and public-record feeds, then manage the library yourself.",
                        systemImage: "dot.radiowaves.left.and.right"
                    )
                    OnboardingPrinciple(
                        title: "Evidence stays attached",
                        detail: "Every brief keeps the publisher, publication time, original link, and source classification.",
                        systemImage: "checkmark.seal"
                    )
                    OnboardingPrinciple(
                        title: "Research, not signals",
                        detail: "Automatic categories help organise reports without predicting prices or recommending trades.",
                        systemImage: "doc.text.magnifyingglass"
                    )

                    Text("CoinBrief AI is informational only and does not provide financial advice, trading signals, price targets, brokerage, custody, exchange, lending, or staking services.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    PrimaryActionButton(title: "Start Briefing", systemImage: "newspaper", action: onComplete)
                }
                .padding(16)
            }
            .background(CoinBriefTheme.background)
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

}

private struct OnboardingPrinciple: View {
    let title: String
    let detail: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(CoinBriefTheme.cyan)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .coinCard()
    }
}

#Preview {
    OnboardingView {}
}

