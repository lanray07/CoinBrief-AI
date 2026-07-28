import Combine
import SwiftUI

@MainActor
final class WatchlistViewModel: ObservableObject {
    @Published var state: LoadableState<[WatchlistItem]> = .idle
    @Published var selectedKind: AssetKind?

    private var watchlistService: (any WatchlistService)?

    var items: [WatchlistItem] {
        guard let loadedItems = state.value else { return [] }
        guard let selectedKind else { return loadedItems }
        return loadedItems.filter { $0.kind == selectedKind }
    }

    func configure(watchlistService: any WatchlistService) {
        if self.watchlistService == nil {
            self.watchlistService = watchlistService
        }
    }

    func load() async {
        guard let watchlistService else { return }
        state = .loading

        do {
            state = .loaded(try await watchlistService.watchlist())
        } catch {
            state = .failed("Your watchlist could not be loaded.")
        }
    }

    func addDemoTopic() async {
        guard let watchlistService else { return }

        let item = WatchlistItem(
            id: UUID(),
            title: "Solana",
            symbol: "SOL",
            kind: .network,
            alertSensitivity: .importantOnly,
            isNotificationsEnabled: true,
            addedAt: .now,
            matchedStoryCount: 0,
            latestNarrative: "Network activity and app growth"
        )

        do {
            try await watchlistService.add(item)
            await load()
        } catch {
            state = .failed("Could not add topic.")
        }
    }

    func toggleNotifications(for item: WatchlistItem) async {
        var updated = item
        updated.isNotificationsEnabled.toggle()
        await update(updated)
    }

    func setSensitivity(_ sensitivity: AlertSensitivity, for item: WatchlistItem) async {
        var updated = item
        updated.alertSensitivity = sensitivity
        await update(updated)
    }

    private func update(_ item: WatchlistItem) async {
        guard let watchlistService else { return }

        do {
            try await watchlistService.update(item)
            await load()
        } catch {
            state = .failed("Could not update watchlist settings.")
        }
    }
}

struct WatchlistView: View {
    @Environment(\.appDependencies) private var dependencies
    @StateObject private var viewModel = WatchlistViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Follow assets and narratives without recommendations.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        WatchlistKindBar(selectedKind: $viewModel.selectedKind)
                    }

                    content
                }
                .padding(16)
            }
            .background(CoinBriefTheme.background)
            .navigationTitle("Watchlist")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.addDemoTopic() }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add watchlist topic")
                }
            }
            .task {
                viewModel.configure(watchlistService: dependencies.watchlistService)
                await viewModel.load()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingSkeletonView()
        case .failed(let message):
            EmptyStateView(title: "Watchlist unavailable", message: message, systemImage: "star.slash")
        case .loaded:
            if viewModel.items.isEmpty {
                EmptyStateView(
                    title: "No matching topics",
                    message: "Follow coins, networks, sectors, companies, exchanges, figures, and regulatory topics.",
                    systemImage: "star"
                )
            } else {
                ForEach(viewModel.items) { item in
                    WatchlistRow(
                        item: item,
                        onToggleNotifications: { Task { await viewModel.toggleNotifications(for: item) } },
                        onSensitivity: { sensitivity in Task { await viewModel.setSensitivity(sensitivity, for: item) } }
                    )
                }
            }
        }
    }
}

private struct WatchlistKindBar: View {
    @Binding var selectedKind: AssetKind?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                kindButton(title: "All", isSelected: selectedKind == nil) {
                    selectedKind = nil
                }

                ForEach(AssetKind.allCases) { kind in
                    kindButton(title: kind.label, isSelected: selectedKind == kind) {
                        selectedKind = kind
                    }
                }
            }
            .padding(.vertical, 2)
        }
        .scrollClipDisabled()
    }

    private func kindButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(isSelected ? CoinBriefTheme.violet.opacity(0.16) : CoinBriefTheme.surface, in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? CoinBriefTheme.violet : CoinBriefTheme.stroke))
        }
        .buttonStyle(.plain)
    }
}

private struct WatchlistRow: View {
    let item: WatchlistItem
    let onToggleNotifications: () -> Void
    let onSensitivity: (AlertSensitivity) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.headline)
                    Text("\(item.symbol) - \(item.kind.label)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(item.matchedStoryCount)")
                    .font(.headline)
                    .foregroundStyle(CoinBriefTheme.cyan)
                    .accessibilityLabel("\(item.matchedStoryCount) matched stories")
            }

            Text(item.latestNarrative)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Button(action: onToggleNotifications) {
                    Label(item.isNotificationsEnabled ? "Alerts on" : "Alerts off", systemImage: item.isNotificationsEnabled ? "bell.fill" : "bell.slash")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Menu {
                    ForEach(AlertSensitivity.allCases) { sensitivity in
                        Button(sensitivity.label) {
                            onSensitivity(sensitivity)
                        }
                    }
                } label: {
                    Label(item.alertSensitivity.label, systemImage: "slider.horizontal.3")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Spacer()
            }
        }
        .padding(16)
        .coinCard()
    }
}

#Preview {
    WatchlistView()
        .environment(\.appDependencies, .preview)
}

