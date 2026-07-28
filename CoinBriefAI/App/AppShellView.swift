import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        AppShellView()
            .sheet(isPresented: onboardingBinding) {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
                .interactiveDismissDisabled()
            }
    }

    private var onboardingBinding: Binding<Bool> {
        Binding(
            get: { !hasCompletedOnboarding },
            set: { isPresented in
                if !isPresented {
                    hasCompletedOnboarding = true
                }
            }
        )
    }
}

struct AppShellView: View {
    @State private var selectedTab: AppTab = .briefing

    var body: some View {
        TabView(selection: $selectedTab) {
            BriefingView()
                .tabItem { Label(AppTab.briefing.title, systemImage: AppTab.briefing.systemImage) }
                .tag(AppTab.briefing)

            DiscoverView()
                .tabItem { Label(AppTab.discover.title, systemImage: AppTab.discover.systemImage) }
                .tag(AppTab.discover)

            WatchlistView()
                .tabItem { Label(AppTab.watchlist.title, systemImage: AppTab.watchlist.systemImage) }
                .tag(AppTab.watchlist)

            SavedView()
                .tabItem { Label(AppTab.saved.title, systemImage: AppTab.saved.systemImage) }
                .tag(AppTab.saved)

            ProfileView()
                .tabItem { Label(AppTab.profile.title, systemImage: AppTab.profile.systemImage) }
                .tag(AppTab.profile)
        }
        .tint(CoinBriefTheme.cyan)
    }
}

#Preview {
    RootView()
        .environment(\.appDependencies, .preview)
}

