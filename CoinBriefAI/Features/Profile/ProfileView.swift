import Combine
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var entitlement: SubscriptionEntitlement = .free
    @Published var products: [SubscriptionProduct] = []

    private var subscriptionService: (any SubscriptionServicing)?

    func configure(subscriptionService: any SubscriptionServicing) {
        if self.subscriptionService == nil {
            self.subscriptionService = subscriptionService
        }
    }

    func load() async {
        guard let subscriptionService else { return }
        entitlement = await subscriptionService.currentEntitlement()
        products = (try? await subscriptionService.products()) ?? []
    }
}

struct ProfileView: View {
    @Environment(\.appDependencies) private var dependencies
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ProfileHeader(entitlement: viewModel.entitlement)

                    SubscriptionSummary(entitlement: viewModel.entitlement)

                    VStack(spacing: 10) {
                        SettingsLinkRow(title: "CoinBrief AI Pro", subtitle: "Manage subscription and restore purchases.", systemImage: "sparkles", destination: PaywallView())
                        SettingsLinkRow(title: "Trust Centre", subtitle: "Source policy, verification labels, and AI limits.", systemImage: "checkmark.seal", destination: TrustCentreView())
                        SettingsLinkRow(title: "Notifications", subtitle: "Quiet hours, reasons, and frequency caps.", systemImage: "bell", destination: NotificationSettingsView())
                        SettingsLinkRow(title: "Legal and Safety", subtitle: "Research-only terms and disclaimer.", systemImage: "doc.text", destination: LegalDisclosureView())
                    }

                    AudioBriefingPreview()

                    AccountPrivacyPanel()
                }
                .padding(16)
            }
            .background(CoinBriefTheme.background)
            .navigationTitle("Profile")
            .task {
                viewModel.configure(subscriptionService: dependencies.subscriptionService)
                await viewModel.load()
            }
        }
    }
}

private struct ProfileHeader: View {
    let entitlement: SubscriptionEntitlement

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(CoinBriefTheme.ink)
                Text("CB")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(CoinBriefTheme.cyan)
            }
            .frame(width: 58, height: 58)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text("CoinBrief AI")
                    .font(.title2.weight(.bold))
                Text("\(entitlement.tier.label) plan")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

private struct SubscriptionSummary: View {
    let entitlement: SubscriptionEntitlement

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(entitlement.isActive ? "Pro active" : "Free tier", systemImage: entitlement.isActive ? "checkmark.circle.fill" : "circle")
                    .font(.headline)
                    .foregroundStyle(entitlement.isActive ? CoinBriefTheme.mint : CoinBriefTheme.secondaryText)
                Spacer()
                if let renewalDate = entitlement.renewalDate {
                    Text(renewalDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(entitlement.isActive ? "Unlimited summaries, deeper modes, audio, offline access, custom alerts, and premium widgets are available." : "Free includes limited summaries, basic search, 5 watchlist items, limited bookmarks, and Quick Scan.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .coinCard()
    }
}

private struct SettingsLinkRow<Destination: View>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundStyle(CoinBriefTheme.cyan)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .coinCard()
        }
        .buttonStyle(.plain)
    }
}

private struct AudioBriefingPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Audio Briefing", subtitle: "Transcript-first audio with chapters and sources.", systemImage: "headphones")

            HStack {
                Label("Morning recap", systemImage: "play.circle.fill")
                    .font(.headline)
                Spacer()
                Text("3:45")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text("Background playback, lock-screen controls, transcript, chapters, and offline storage are planned for the production audio service. Voices must be original and must not imitate real people.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .coinCard()
    }
}

private struct AccountPrivacyPanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Account And Privacy", subtitle: "User control points for launch readiness.", systemImage: "person.badge.shield.checkmark")

            Label("Export or delete saved data", systemImage: "square.and.arrow.down")
            Label("Manage watchlist personalization", systemImage: "slider.horizontal.3")
            Label("No tracking identifiers in the intended launch scope", systemImage: "hand.raised")
        }
        .font(.subheadline)
        .padding(16)
        .coinCard()
    }
}

struct LegalDisclosureView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Legal And Safety")
                    .font(.largeTitle.weight(.bold))

                Text("CoinBrief AI provides news, education, and research only. It is not financial, investment, legal, tax, accounting, trading, brokerage, custody, exchange, lending, or staking advice.")
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Cryptoassets are volatile and risky. Review original sources and consult qualified professionals before making financial decisions.")
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                Link("Standard Apple EULA", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    .font(.headline)
            }
            .padding(16)
        }
        .background(CoinBriefTheme.background)
        .navigationTitle("Legal")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView()
        .environment(\.appDependencies, .preview)
}

