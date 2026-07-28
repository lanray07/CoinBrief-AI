import Foundation

actor MockSubscriptionService: SubscriptionServicing {
    private var entitlement: SubscriptionEntitlement = .free

    func products() async throws -> [SubscriptionProduct] {
        [
            SubscriptionProduct(id: "com.coinbriefai.pro.monthly", displayName: "Pro Monthly", displayPrice: "GBP 4.99", period: "Monthly", isFamilyShareable: true),
            SubscriptionProduct(id: "com.coinbriefai.pro.annual", displayName: "Pro Annual", displayPrice: "GBP 39.99", period: "Annual", isFamilyShareable: true)
        ]
    }

    func currentEntitlement() async -> SubscriptionEntitlement {
        entitlement
    }

    func purchase(productID: String) async throws -> SubscriptionEntitlement {
        entitlement = .pro(renewalDate: Calendar.current.date(byAdding: .month, value: productID.contains("annual") ? 12 : 1, to: .now))
        return entitlement
    }

    func restorePurchases() async throws -> SubscriptionEntitlement {
        entitlement
    }
}

