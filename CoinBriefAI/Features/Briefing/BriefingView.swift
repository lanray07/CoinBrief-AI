import Combine
import SwiftUI

@MainActor
final class BriefingViewModel: ObservableObject {
    @Published var state: LoadableState<Briefing> = .idle
    @Published var selectedMode: SummaryMode = .standard
    @Published var edition: BriefingEdition = .morning
    @Published var entitlement: SubscriptionEntitlement = .free

    private var newsService: (any NewsService)?
    private var subscriptionService: (any SubscriptionServicing)?

    var availableModes: [SummaryMode] {
        entitlement.isActive ? SummaryMode.allCases : [.quickScan, .standard]
    }

    func configure(newsService: any NewsService, subscriptionService: any SubscriptionServicing) {
        if self.newsService == nil {
            self.newsService = newsService
        }
        if self.subscriptionService == nil {
            self.subscriptionService = subscriptionService
        }
    }

    func load(force: Bool = false) async {
        if !force, case .loaded = state {
            return
        }

        guard let newsService else { return }

        state = .loading

        do {
            if let subscriptionService {
                entitlement = await subscriptionService.currentEntitlement()
            }
            if selectedMode == .deepDive, !entitlement.isActive {
                selectedMode = .standard
            }
            var preferences = UserPreferences.standard
            preferences.summaryMode = selectedMode
            state = .loaded(try await newsService.fetchBriefing(preferences: preferences, edition: edition))
        } catch {
            state = .failed("Briefing could not be refreshed. Check your connection or try again in a moment.")
        }
    }
}

struct BriefingView: View {
    @Environment(\.appDependencies) private var dependencies
    @StateObject private var viewModel = BriefingViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    BriefingHeaderView(
                        selectedMode: $viewModel.selectedMode,
                        edition: $viewModel.edition,
                        availableModes: viewModel.availableModes,
                        onRefresh: { Task { await viewModel.load(force: true) } }
                    )

                    content
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
            .background(CoinBriefTheme.background)
            .navigationTitle("Briefing")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: BriefStory.self) { story in
                StoryDetailView(story: story)
            }
            .task {
                viewModel.configure(
                    newsService: dependencies.newsService,
                    subscriptionService: dependencies.subscriptionService
                )
                await viewModel.load()
            }
            .onChange(of: viewModel.selectedMode) { _, _ in
                Task { await viewModel.load(force: true) }
            }
            .onChange(of: viewModel.edition) { _, _ in
                Task { await viewModel.load(force: true) }
            }
            .refreshable {
                await viewModel.load(force: true)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingSkeletonView()
        case .failed(let message):
            EmptyStateView(title: "Briefing unavailable", message: message, systemImage: "wifi.exclamationmark")
        case .loaded(let briefing):
            BriefingContentView(briefing: briefing)
        }
    }
}

private struct BriefingHeaderView: View {
    @Binding var selectedMode: SummaryMode
    @Binding var edition: BriefingEdition
    let availableModes: [SummaryMode]
    let onRefresh: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your 5-Minute Brief")
                        .font(.largeTitle.weight(.bold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(Date.now.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                        .font(.headline)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.bordered)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityLabel("Refresh briefing")
            }

            Picker("Edition", selection: $edition) {
                ForEach(BriefingEdition.allCases) { edition in
                    Text(edition.label).tag(edition)
                }
            }
            .pickerStyle(.segmented)

            Picker("Summary mode", selection: $selectedMode) {
                ForEach(availableModes) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

private struct BriefingContentView: View {
    let briefing: Briefing

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label(briefing.edition.label, systemImage: "sunrise")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CoinBriefTheme.cyan)

                    Spacer()

                    Text("\(briefing.readTimeMinutes) min read")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Text(briefing.marketPulse)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(CoinBriefTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 8))

            ForEach(briefing.sections) { section in
                if !section.stories.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: section.title, subtitle: section.subtitle, systemImage: section.systemImage)

                        ForEach(section.stories) { story in
                            NavigationLink(value: story) {
                                StoryCardView(story: story)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            Text("Informational research only. CoinBrief AI does not provide financial advice, trading signals, price targets, brokerage, custody, or exchange services.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
        }
    }
}

#if DEBUG
#Preview {
    BriefingView()
        .environment(\.appDependencies, .preview)
}
#endif

