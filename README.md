# CoinBrief AI

CoinBrief AI is a premium native iOS/iPadOS app for concise, source-backed crypto and blockchain news research. It is intentionally informational: it does not offer trading, brokerage, custody, portfolio management, token recommendations, financial advice, price predictions, or transaction execution.

## What is included

- Swift 6 SwiftUI app shell with five production tabs: Briefing, Discover, Watchlist, Saved, and Profile.
- MVVM/Clean Architecture split across domain models, service protocols, mock infrastructure, SwiftData persistence, StoreKit 2, notifications, App Intents, and WidgetKit source.
- Clearly labelled demo data with source attribution and verification states.
- Privacy manifest, StoreKit configuration, entitlements, onboarding, Trust Centre, App Review notes, app metadata, screenshot plan, and legal drafts.

## Open in Xcode

Open `CoinBriefAI.xcodeproj` in Xcode 16 or newer. The project uses Xcode 16 synchronized source folders so newly added files under `CoinBriefAI`, `CoinBriefAIWidget`, `CoinBriefAITests`, and `CoinBriefAIUITests` are picked up by their targets.

If your local Xcode does not support synchronized groups, install XcodeGen and run:

```sh
xcodegen generate
```

## Bundle IDs

- App: `com.CoinBriefAI.app`
- Widget extension: `com.CoinBriefAI.app.widget`
- Shared app group: not enabled in the first App Store upload because the current widget uses static demo content. Add `group.com.coinbriefai.shared` when shared app/widget storage is implemented and the App Group capability is enabled in Apple Developer.

Before an App Store upload, set the Apple Developer Team ID and confirm the bundle identifiers match App Store Connect.

## Product IDs

- Monthly: `com.coinbriefai.pro.monthly`
- Annual: `com.coinbriefai.pro.annual`

## Launch Cautions

Before submitting, replace demo news with licensed/contracted sources, complete App Store Connect privacy answers from actual SDK behavior, configure StoreKit products in App Store Connect, and have legal review the privacy policy, terms, source licenses, and financial-disclaimer language.
