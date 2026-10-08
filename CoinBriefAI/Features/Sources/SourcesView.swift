import Combine
import SwiftUI

@MainActor
final class SourcesViewModel: ObservableObject {
    @Published var sources: [FeedSource] = []
    @Published var errorMessage: String?
    @Published var isWorking = false
    @Published var entitlement: SubscriptionEntitlement = .free

    private var sourceLibrary: (any SourceLibraryServicing)?
    private var subscriptionService: (any SubscriptionServicing)?

    func configure(sourceLibrary: any SourceLibraryServicing, subscriptionService: any SubscriptionServicing) {
        if self.sourceLibrary == nil {
            self.sourceLibrary = sourceLibrary
        }
        if self.subscriptionService == nil {
            self.subscriptionService = subscriptionService
        }
    }

    func load() async {
        guard let sourceLibrary else { return }
        sources = await sourceLibrary.sources()
        if let subscriptionService {
            entitlement = await subscriptionService.currentEntitlement()
        }
    }

    func add(urlText: String) async -> Bool {
        guard let sourceLibrary,
              let url = URL(string: urlText.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            errorMessage = SourceLibraryError.invalidURL.localizedDescription
            return false
        }

        isWorking = true
        defer { isWorking = false }
        do {
            _ = try await sourceLibrary.add(feedURL: url)
            errorMessage = nil
            await load()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func setEnabled(_ isEnabled: Bool, source: FeedSource) async {
        guard let sourceLibrary else { return }
        do {
            try await sourceLibrary.setEnabled(isEnabled, id: source.id)
            errorMessage = nil
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func remove(_ source: FeedSource) async {
        guard let sourceLibrary else { return }
        do {
            try await sourceLibrary.remove(id: source.id)
            errorMessage = nil
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct SourcesView: View {
    @Environment(\.appDependencies) private var dependencies
    @StateObject private var viewModel = SourcesViewModel()
    @State private var presentedSheet: SourcesSheet?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    SourceLibraryHeader(
                        enabledCount: viewModel.sources.filter(\.isEnabled).count,
                        totalCount: viewModel.sources.count
                    )

                    if let errorMessage = viewModel.errorMessage {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                    }

                    ForEach(viewModel.sources) { source in
                        SourceLibraryRow(
                            source: source,
                            onEnabledChanged: { isEnabled in
                                Task { await viewModel.setEnabled(isEnabled, source: source) }
                            },
                            onRemove: source.isBuiltIn ? nil : {
                                Task { await viewModel.remove(source) }
                            }
                        )
                    }
                }
                .padding(16)
            }
            .background(CoinBriefTheme.background)
            .navigationTitle("Sources")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        presentedSheet = viewModel.entitlement.isActive ? .addSource : .paywall
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add RSS source")
                }
            }
            .sheet(item: $presentedSheet, onDismiss: {
                Task { await viewModel.load() }
            }) { sheet in
                switch sheet {
                case .addSource:
                    AddSourceView(isWorking: viewModel.isWorking) { urlText in
                        await viewModel.add(urlText: urlText)
                    }
                case .paywall:
                    NavigationStack { PaywallView() }
                }
            }
            .task {
                viewModel.configure(
                    sourceLibrary: dependencies.sourceLibrary,
                    subscriptionService: dependencies.subscriptionService
                )
                await viewModel.load()
            }
            .refreshable {
                await viewModel.load()
            }
        }
    }
}

private enum SourcesSheet: String, Identifiable {
    case addSource
    case paywall

    var id: String { rawValue }
}

private struct SourceLibraryHeader: View {
    let enabledCount: Int
    let totalCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Evidence sources")
                .font(.title2.weight(.bold))
            Text("\(enabledCount) of \(totalCount) sources enabled")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Briefings are assembled from the feeds you control. Every item keeps its publisher, timestamp, and original URL.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 4)
    }
}

private struct SourceLibraryRow: View {
    let source: FeedSource
    let onEnabledChanged: (Bool) -> Void
    let onRemove: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: source.kind.systemImage)
                    .foregroundStyle(CoinBriefTheme.cyan)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(source.title)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(source.kind.label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CoinBriefTheme.violet)
                }

                Spacer()

                Toggle("Enabled", isOn: Binding(
                    get: { source.isEnabled },
                    set: onEnabledChanged
                ))
                .labelsHidden()
            }

            Text(source.feedURL.host ?? source.feedURL.absoluteString)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            HStack(spacing: 14) {
                if let websiteURL = source.websiteURL {
                    Link(destination: websiteURL) {
                        Label("Website", systemImage: "safari")
                    }
                }
                Link(destination: source.feedURL) {
                    Label("Feed", systemImage: "dot.radiowaves.left.and.right")
                }
                Spacer()
                if let onRemove {
                    Button(role: .destructive, action: onRemove) {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Remove \(source.title)")
                }
            }
            .font(.caption.weight(.semibold))
        }
        .padding(16)
        .coinCard()
    }
}

private struct AddSourceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var urlText = ""

    let isWorking: Bool
    let onAdd: (String) async -> Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("RSS or Atom URL") {
                    TextField("https://example.com/feed.xml", text: $urlText)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("Add Source")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            if await onAdd(urlText) { dismiss() }
                        }
                    }
                    .disabled(urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isWorking)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    SourcesView()
        .environment(\.appDependencies, .preview)
}
#endif
