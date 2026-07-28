import Combine
import SwiftUI

@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published var query = ""
    @Published var selectedCategory: StoryCategory?
    @Published var sort: StorySort = .recent
    @Published var results: [BriefStory] = []
    @Published var recentSearches: [String] = ["BTC", "stablecoin", "security"]
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var newsService: (any NewsService)?

    var searchKey: String {
        "\(query)|\(selectedCategory?.rawValue ?? "all")|\(sort.rawValue)"
    }

    func configure(newsService: any NewsService) {
        if self.newsService == nil {
            self.newsService = newsService
        }
    }

    func search() async {
        guard let newsService else { return }
        isLoading = true
        errorMessage = nil

        do {
            let filter = StorySearchFilter(category: selectedCategory, assetSymbol: nil, sort: sort)
            results = try await newsService.searchStories(query: query, filter: filter)
        } catch {
            errorMessage = "Search is unavailable right now."
        }

        isLoading = false
    }

    func commitRecentSearch() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        recentSearches.removeAll { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
        recentSearches.insert(trimmed, at: 0)
        recentSearches = Array(recentSearches.prefix(6))
    }

    func useRecentSearch(_ search: String) {
        query = search
    }
}

struct DiscoverView: View {
    @Environment(\.appDependencies) private var dependencies
    @StateObject private var viewModel = DiscoverViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    DiscoverFilterBar(
                        selectedCategory: $viewModel.selectedCategory,
                        sort: $viewModel.sort
                    )

                    if viewModel.query.isEmpty {
                        RecentSearchesView(searches: viewModel.recentSearches, onSelect: viewModel.useRecentSearch)
                    }

                    if viewModel.isLoading && viewModel.results.isEmpty {
                        LoadingSkeletonView()
                    } else if let errorMessage = viewModel.errorMessage {
                        EmptyStateView(title: "Search unavailable", message: errorMessage, systemImage: "magnifyingglass")
                    } else if viewModel.results.isEmpty {
                        EmptyStateView(
                            title: "No stories found",
                            message: "Try a broader term, another category, or a followed asset.",
                            systemImage: "doc.text.magnifyingglass"
                        )
                    } else {
                        ForEach(viewModel.results) { story in
                            NavigationLink(value: story) {
                                StoryCardView(story: story)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
            }
            .background(CoinBriefTheme.background)
            .navigationTitle("Discover")
            .searchable(text: $viewModel.query, prompt: "Search assets, topics, sources")
            .onSubmit(of: .search) {
                viewModel.commitRecentSearch()
            }
            .navigationDestination(for: BriefStory.self) { story in
                StoryDetailView(story: story)
            }
            .task(id: viewModel.searchKey) {
                viewModel.configure(newsService: dependencies.newsService)
                try? await Task.sleep(nanoseconds: 220_000_000)
                await viewModel.search()
            }
        }
    }
}

private struct DiscoverFilterBar: View {
    @Binding var selectedCategory: StoryCategory?
    @Binding var sort: StorySort

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    categoryButton(title: "All", systemImage: "square.grid.2x2", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }

                    ForEach(StoryCategory.allCases) { category in
                        categoryButton(title: category.label, systemImage: category.systemImage, isSelected: selectedCategory == category) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .scrollClipDisabled()

            Picker("Sort", selection: $sort) {
                ForEach(StorySort.allCases) { sort in
                    Text(sort.label).tag(sort)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private func categoryButton(title: String, systemImage: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(isSelected ? CoinBriefTheme.cyan.opacity(0.16) : CoinBriefTheme.surface, in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? CoinBriefTheme.cyan : CoinBriefTheme.stroke)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct RecentSearchesView: View {
    let searches: [String]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Recent Searches", subtitle: "Quickly return to active research threads.", systemImage: "clock.arrow.circlepath")

            FlowLayout(items: searches) { search in
                Button {
                    onSelect(search)
                } label: {
                    Label(search, systemImage: "magnifyingglass")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(CoinBriefTheme.surface, in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(CoinBriefTheme.stroke))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    DiscoverView()
        .environment(\.appDependencies, .preview)
}

