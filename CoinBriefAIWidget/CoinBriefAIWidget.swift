import SwiftUI
import WidgetKit

struct CoinBriefWidgetEntry: TimelineEntry {
    let date: Date
    let headline: String
    let summary: String
    let footer: String
    let systemImage: String
    let tint: Color
}

struct CoinBriefWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> CoinBriefWidgetEntry {
        CoinBriefWidgetEntry(
            date: .now,
            headline: "Crypto news without the noise",
            summary: "Source-backed summaries for your daily research.",
            footer: "Demo source-backed",
            systemImage: "newspaper",
            tint: Color(red: 0.07, green: 0.75, blue: 0.91)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CoinBriefWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CoinBriefWidgetEntry>) -> Void) {
        let entry = CoinBriefWidgetEntry(
            date: .now,
            headline: "ETF flows cool as derivatives activity picks up",
            summary: "Demo sources show cautious positioning around macro events.",
            footer: "2 demo sources - research only",
            systemImage: "chart.line.uptrend.xyaxis",
            tint: Color(red: 0.96, green: 0.71, blue: 0.29)
        )

        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(30 * 60))))
    }
}

struct CoinBriefWidgetView: View {
    let entry: CoinBriefWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: entry.systemImage)
                    .foregroundStyle(entry.tint)
                Spacer()
                Text("CoinBrief")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(entry.headline)
                .font(.headline)
                .lineLimit(3)
                .minimumScaleFactor(0.8)

            Text(entry.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            Spacer(minLength: 0)

            Text(entry.footer)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .containerBackground(Color(red: 0.05, green: 0.08, blue: 0.13), for: .widget)
    }
}

struct TopStoryWidget: Widget {
    let kind: String = "TopStoryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CoinBriefWidgetProvider()) { entry in
            CoinBriefWidgetView(entry: entry)
        }
        .configurationDisplayName("Top Story")
        .description("A source-backed top crypto story.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct WatchlistUpdateWidget: Widget {
    let kind: String = "WatchlistUpdateWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CoinBriefWidgetProvider()) { entry in
            CoinBriefWidgetView(entry: CoinBriefWidgetEntry(
                date: entry.date,
                headline: "Watchlist update",
                summary: "BTC and ETH stories have fresh source-backed context.",
                footer: "Watchlist - no recommendations",
                systemImage: "star",
                tint: Color(red: 0.55, green: 0.55, blue: 0.97)
            ))
        }
        .configurationDisplayName("Watchlist Update")
        .description("Source-backed updates from your followed topics.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SecurityAlertWidget: Widget {
    let kind: String = "SecurityAlertWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CoinBriefWidgetProvider()) { entry in
            CoinBriefWidgetView(entry: CoinBriefWidgetEntry(
                date: entry.date,
                headline: "Security alert",
                summary: "Demo security researchers flagged a phishing campaign.",
                footer: "Security context",
                systemImage: "lock.shield",
                tint: Color(red: 0.85, green: 0.37, blue: 0.37)
            ))
        }
        .configurationDisplayName("Security Alert")
        .description("Critical security context from verified sources.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct CoinBriefAIWidgetBundle: WidgetBundle {
    var body: some Widget {
        TopStoryWidget()
        WatchlistUpdateWidget()
        SecurityAlertWidget()
    }
}

