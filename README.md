# CoinBrief AI

CoinBrief AI is a premium native iOS/iPadOS app for concise, source-backed crypto and blockchain news research. It is intentionally informational: it does not offer trading, brokerage, custody, portfolio management, token recommendations, financial advice, price predictions, or transaction execution.

## What is included

- Swift 6 SwiftUI app with five production tabs: Briefing, Discover, Sources, Saved, and Profile.
- Live RSS and Atom ingestion from user-controlled official, public-record, research, and custom sources.
- Evidence records that preserve publisher, publication time, source classification, and the original URL.
- Local source preferences, cached report fallback, SwiftData saved research, StoreKit 2, notifications, and App Intents.
- Privacy manifest, StoreKit configuration, entitlements, onboarding, Trust Centre, App Review notes, app metadata, screenshot plan, and legal drafts.

## Open in Xcode

Open `CoinBriefAI.xcodeproj` in Xcode 16 or newer. The project uses Xcode 16 synchronized source folders so newly added files under `CoinBriefAI`, `CoinBriefAIWidget`, `CoinBriefAITests`, and `CoinBriefAIUITests` are picked up by their targets.

If your local Xcode does not support synchronized groups, install XcodeGen and run:

```sh
xcodegen generate
```

## Bundle IDs

- App: `com.CoinBriefAI.app`
- A widget is not included in the App Store target until it can read the same live evidence cache as the main app.

Before an App Store upload, set the Apple Developer Team ID and confirm the bundle identifiers match App Store Connect.

## Product IDs

- Monthly: `com.coinbriefai.pro.monthly`
- Annual: `com.coinbriefai.pro.annual`

## Source Policy

CoinBrief reads RSS and Atom feeds selected by the user. It stores short feed excerpts for research continuity and always links to the publisher's original page. The built-in library uses feeds published by the Ethereum Foundation, U.S. SEC, U.S. CFTC, and Bitcoin Optech. Custom feeds are a Pro capability.
