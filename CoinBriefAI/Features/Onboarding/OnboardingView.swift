import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var experienceLevel: ExperienceLevel = .experienced
    @State private var summaryMode: SummaryMode = .standard
    @State private var selectedCategories: Set<StoryCategory> = [.market, .regulation, .security]
    @State private var broadenMyView = true
    @State private var audioBriefings = true

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

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Experience")
                            .font(.headline)
                        Picker("Experience", selection: $experienceLevel) {
                            ForEach(ExperienceLevel.allCases) { level in
                                Text(level.label).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Default Summary")
                            .font(.headline)
                        Picker("Summary mode", selection: $summaryMode) {
                            ForEach(SummaryMode.allCases) { mode in
                                Text(mode.label).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Topics")
                            .font(.headline)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 8)], spacing: 8) {
                            ForEach(StoryCategory.allCases) { category in
                                SelectableChip(
                                    title: category.label,
                                    systemImage: category.systemImage,
                                    isSelected: selectedCategories.contains(category)
                                ) {
                                    toggle(category)
                                }
                            }
                        }
                    }

                    VStack(spacing: 10) {
                        Toggle(isOn: $broadenMyView) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Broaden My View")
                                    .font(.subheadline.weight(.semibold))
                                Text("Mix in credible stories outside your usual topics.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Toggle(isOn: $audioBriefings) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Audio briefings")
                                    .font(.subheadline.weight(.semibold))
                                Text("Prepare transcript-first daily audio with sources.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(16)
                    .coinCard()

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

    private func toggle(_ category: StoryCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}

private struct SelectableChip: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .frame(width: 18)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(isSelected ? CoinBriefTheme.cyan.opacity(0.16) : CoinBriefTheme.surface, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? CoinBriefTheme.cyan : CoinBriefTheme.stroke))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(isSelected ? "selected" : "not selected")")
    }
}

#Preview {
    OnboardingView {}
}

