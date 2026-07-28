# Product Architecture

CoinBrief AI uses a native client with a backend-first trust model.

## Client Layers

- `App`: app entry point, dependency injection, tab routing, onboarding gate.
- `DesignSystem`: palette, typography, reusable badges, story cards, empty/loading states.
- `Domain`: value models and service protocols. This layer has no network or UI dependency.
- `Infrastructure`: mock services, StoreKit 2 adapter, notification scheduler, SwiftData records, Keychain storage.
- `Features`: each major screen owns its view model and UI composition.
- `Intents` and `CoinBriefAIWidget`: system integrations that expose small, safe surfaces.

## Runtime Data Flow

1. Views ask view models to load.
2. View models call protocol services from `AppDependencies`.
3. Services return source-backed domain models.
4. SwiftData stores user-owned state: saved stories, reading history, notes, and watchlist records.
5. Production services replace mocks without changing feature views.

## Non-Negotiables

- No AI summary renders without at least one source.
- No client-side API keys for news, AI, auth, sync, or push providers.
- No price-target, trade-signal, custody, brokerage, exchange, or recommendation workflows.
- Every paid capability must work through StoreKit 2 entitlement checks.

