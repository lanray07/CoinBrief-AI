import Foundation

enum AssetKind: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case coin
    case network
    case protocolTopic
    case exchange
    case company
    case publicFigure
    case sector
    case regulation

    var id: String { rawValue }

    var label: String {
        switch self {
        case .coin: "Coin"
        case .network: "Network"
        case .protocolTopic: "Protocol"
        case .exchange: "Exchange"
        case .company: "Company"
        case .publicFigure: "Figure"
        case .sector: "Sector"
        case .regulation: "Regulation"
        }
    }
}

struct AssetTag: Identifiable, Codable, Hashable, Sendable {
    var id: String { symbol }
    let symbol: String
    let name: String
    let kind: AssetKind
    let colorHex: String

    static let bitcoin = AssetTag(symbol: "BTC", name: "Bitcoin", kind: .coin, colorHex: "#F2A900")
    static let ethereum = AssetTag(symbol: "ETH", name: "Ethereum", kind: .coin, colorHex: "#8B8DF8")
    static let solana = AssetTag(symbol: "SOL", name: "Solana", kind: .network, colorHex: "#14F195")
    static let defi = AssetTag(symbol: "DeFi", name: "Decentralized Finance", kind: .sector, colorHex: "#25C2A0")
    static let regulation = AssetTag(symbol: "Policy", name: "Regulation", kind: .regulation, colorHex: "#F6B44B")
}

