# Backend And AI Pipeline

1. Ingest licensed news APIs, direct publisher feeds, official project blogs, regulator notices, exchange status pages, public filings, and verified social sources where permitted.
2. Normalize article metadata, publisher identity, canonical URL, topic tags, assets, language, and publication timestamps.
3. Reject unsupported content types, duplicate syndications, broken URLs, suspicious scraped pages, and sources without usage rights.
4. Cluster related stories by canonical URL, semantic similarity, time window, and named entities.
5. Rank by source credibility, freshness, watchlist relevance, market-wide importance, and novelty.
6. Extract claims and evidence snippets from sources.
7. Generate summaries only from the extracted evidence bundle.
8. Run groundedness checks that require every material claim to map to one or more source references.
9. Detect uncertainty, conflicts, corrections, and developing-story language.
10. Classify sentiment as contextual editorial tone, never as investment advice.
11. Create `What changed?` deltas when a cluster updates.
12. Store summary, citations, model version, prompts, and reviewer metadata for audit.
13. Deliver cached responses to app, widgets, notifications, and audio jobs.

## Guardrails

- Do not infer prices, future returns, or buy/sell/hold actions.
- Do not paraphrase whole articles into substitute copies.
- Do not summarize paywalled text unless the license permits it.
- Do not show generated content when sources are missing.
- Label demo data and model limitations clearly.

