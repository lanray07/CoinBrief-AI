import Foundation
import StoreKit

enum SubscriptionError: Error {
    case productUnavailable
    case purchasePending
    case purchaseCancelled
    case failedVerification
}

final class StoreKitSubscriptionService: SubscriptionServicing {
    private let productIDs = [
        "com.coinbriefai.pro.monthly",
        "com.coinbriefai.pro.annual"
    ]

    func products() async throws -> [SubscriptionProduct] {
        let products = try await Product.products(for: productIDs)
        return products.map { product in
            SubscriptionProduct(
                id: product.id,
                displayName: product.displayName,
                displayPrice: product.displayPrice,
                period: product.subscription?.subscriptionPeriod.unit.displayName ?? "Subscription",
                isFamilyShareable: product.isFamilyShareable
            )
        }
    }

    func currentEntitlement() async -> SubscriptionEntitlement {
        for await result in Transaction.currentEntitlements {
            guard case let .verified(transaction) = result else { continue }
            guard productIDs.contains(transaction.productID) else { continue }
            return .pro(renewalDate: transaction.expirationDate)
        }
        return .free
    }

    func purchase(productID: String) async throws -> SubscriptionEntitlement {
        guard let product = try await Product.products(for: [productID]).first else {
            throw SubscriptionError.productUnavailable
        }

        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try verified(verification)
            await transaction.finish()
            return .pro(renewalDate: transaction.expirationDate)
        case .pending:
            throw SubscriptionError.purchasePending
        case .userCancelled:
            throw SubscriptionError.purchaseCancelled
        @unknown default:
            throw SubscriptionError.productUnavailable
        }
    }

    func restorePurchases() async throws -> SubscriptionEntitlement {
        try await AppStore.sync()
        return await currentEntitlement()
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw SubscriptionError.failedVerification
        }
    }
}

private extension Product.SubscriptionPeriod.Unit {
    var displayName: String {
        switch self {
        case .day: "Daily"
        case .week: "Weekly"
        case .month: "Monthly"
        case .year: "Annual"
        @unknown default: "Subscription"
        }
    }
}

