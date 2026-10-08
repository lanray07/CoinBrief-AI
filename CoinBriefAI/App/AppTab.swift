import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case briefing
    case discover
    case sources
    case saved
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .briefing: "Briefing"
        case .discover: "Discover"
        case .sources: "Sources"
        case .saved: "Saved"
        case .profile: "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .briefing: "newspaper"
        case .discover: "magnifyingglass"
        case .sources: "link"
        case .saved: "bookmark"
        case .profile: "person.crop.circle"
        }
    }
}

