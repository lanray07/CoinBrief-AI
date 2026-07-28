import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case briefing
    case discover
    case watchlist
    case saved
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .briefing: "Briefing"
        case .discover: "Discover"
        case .watchlist: "Watchlist"
        case .saved: "Saved"
        case .profile: "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .briefing: "newspaper"
        case .discover: "magnifyingglass"
        case .watchlist: "star"
        case .saved: "bookmark"
        case .profile: "person.crop.circle"
        }
    }
}

