import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

enum CoinBriefTheme {
    static let cyan = Color(hex: "#12BFE8")
    static let violet = Color(hex: "#8B8DF8")
    static let amber = Color(hex: "#F6B44B")
    static let critical = Color(hex: "#D95F5F")
    static let mint = Color(hex: "#25C2A0")
    static let ink = Color(hex: "#17202C")
    static let secondaryText = Color(hex: "#667085")

    static let background = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
        ? UIColor(hex: "#08111F")
        : UIColor(hex: "#FFFDF7")
    })

    static let surface = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
        ? UIColor(hex: "#111B2A")
        : UIColor(hex: "#FFFFFF")
    })

    static let elevatedSurface = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
        ? UIColor(hex: "#172335")
        : UIColor(hex: "#F5F7FA")
    })

    static let stroke = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
        ? UIColor(hex: "#2A3A51")
        : UIColor(hex: "#E3E8EF")
    })

    static let softWarning = Color(hex: "#FFF4DA")

    static func storyTint(for importance: ImportanceLevel) -> Color {
        switch importance {
        case .routine: secondaryText
        case .notable: cyan
        case .high: amber
        case .critical: critical
        }
    }
}

extension Color {
    init(hex: String) {
        let normalized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: normalized).scanHexInt64(&value)

        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        switch normalized.count {
        case 3:
            red = Double((value >> 8) & 0xF) / 15
            green = Double((value >> 4) & 0xF) / 15
            blue = Double(value & 0xF) / 15
            alpha = 1
        case 6:
            red = Double((value >> 16) & 0xFF) / 255
            green = Double((value >> 8) & 0xFF) / 255
            blue = Double(value & 0xFF) / 255
            alpha = 1
        case 8:
            red = Double((value >> 24) & 0xFF) / 255
            green = Double((value >> 16) & 0xFF) / 255
            blue = Double((value >> 8) & 0xFF) / 255
            alpha = Double(value & 0xFF) / 255
        default:
            red = 0
            green = 0
            blue = 0
            alpha = 1
        }

        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}

#if canImport(UIKit)
extension UIColor {
    convenience init(hex: String) {
        let normalized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: normalized).scanHexInt64(&value)

        let red = CGFloat((value >> 16) & 0xFF) / 255
        let green = CGFloat((value >> 8) & 0xFF) / 255
        let blue = CGFloat(value & 0xFF) / 255

        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
#endif

