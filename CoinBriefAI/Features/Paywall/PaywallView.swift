import Combine
import SwiftUI

@MainActor
final class PaywallViewModel: ObservableObject {
    @Published var products: [SubscriptionProduct] = []
    @Published var entitlement: SubscriptionEntitlement = .free
    @Published var statusMessage: String?
    @Published var isWorking = false

    private var subscriptionService: (any SubscriptionServicing)?

    func configure(subscriptionService: any SubscriptionServicing) {
        if self.subscriptionService == nil {
            self.subscriptionService = subscriptionService
        }
    }

    func load() async {
        guard let subscriptionService else { return }

        do {
            products = try await subscriptionService.products()
            entitlement = await subscriptionService.currentEntitlement()
        } catch {
            statusMessage = "Products are unavailable. StoreKit must be configured in App Store Connect."
        }
    }

    func purchase(_ productID: String) async {
        guard let subscriptionService else { return }
        isWorking = true
        defer { isWorking = false }

        do {
            entitlement = try await subscriptionService.purchase(productID: productID)
            statusMessage = "Pro is active."
        } catch SubscriptionError.purchaseCancelled {
            statusMessage = "Purchase cancelled."
        } catch {
            statusMessage = "Purchase could not be completed."
        }
    }

    func restore() async {
        guard let subscriptionService else { return }
        isWorking = true
        defer { isWorking = false }

        do {
            entitlement = try await subscriptionService.restorePurchases()
            statusMessage = entitlement.isActive ? "Purchases restored." : "No active Pro subscription found."
        } catch {
            statusMessage = "Restore failed."
        }
    }
}

struct PaywallView: View {
    @Environment(\.appDependencies) private var dependencies
    @StateObject private var viewModel = PaywallViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("CoinBrief AI Pro")
                        .font(.largeTitle.weight(.bold))
                    Text("More source-backed research depth without ads, fake timers, or preselected purchases.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(ProCapability.allCases) { capability in
                        Label(capability.label, systemImage: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(CoinBriefTheme.mint)
                    }
                }
                .padding(16)
                .coinCard()

                VStack(spacing: 12) {
                    ForEach(viewModel.products) { product in
                        Button {
                            Task { await viewModel.purchase(product.id) }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(product.displayName)
                                        .font(.headline)
                                    Text(product.period)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(product.displayPrice)
                                    .font(.headline)
                            }
                            .padding(16)
                            .background(CoinBriefTheme.surface, in: RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(CoinBriefTheme.stroke))
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.isWorking)
                    }

                    Button {
                        Task { await viewModel.restore() }
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                if let statusMessage = viewModel.statusMessage {
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text("Payment is charged to your Apple account. Subscriptions renew automatically unless cancelled at least 24 hours before renewal. Manage or cancel in Apple account settings.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
        }
        .background(CoinBriefTheme.background)
        .navigationTitle("Pro")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.configure(subscriptionService: dependencies.subscriptionService)
            await viewModel.load()
        }
    }
}

#Preview {
    NavigationStack {
        PaywallView()
            .environment(\.appDependencies, .preview)
    }
}

