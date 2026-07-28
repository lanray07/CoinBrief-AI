import SwiftUI

extension VerificationStatus {
    var tint: Color {
        switch self {
        case .sourceBacked: CoinBriefTheme.mint
        case .developing: CoinBriefTheme.amber
        case .conflicting: CoinBriefTheme.critical
        case .corrected: CoinBriefTheme.violet
        }
    }
}

extension StorySentiment {
    var tint: Color {
        switch self {
        case .constructive: CoinBriefTheme.mint
        case .neutral: CoinBriefTheme.secondaryText
        case .mixed: CoinBriefTheme.violet
        case .cautious: CoinBriefTheme.amber
        case .risk: CoinBriefTheme.critical
        }
    }

    var systemImage: String {
        switch self {
        case .constructive: "arrow.up.forward"
        case .neutral: "minus"
        case .mixed: "arrow.left.and.right"
        case .cautious: "exclamationmark.circle"
        case .risk: "shield.lefthalf.filled.badge.checkmark"
        }
    }
}

