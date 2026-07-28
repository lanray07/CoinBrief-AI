# Backend API Contract

Base URL placeholder: `https://api.coinbrief.ai/v1`

All endpoints require TLS. Authenticated endpoints use short-lived bearer tokens issued by the backend. Provider keys stay server-side.

## GET /briefings/current

Query:

- `edition`: `morning`, `evening`, or `breaking`
- `mode`: `quick`, `standard`, or `deep`
- `experience`: `beginner` or `experienced`
- `watchlistOnly`: boolean

Response:

```json
{
  "id": "briefing_2026_07_28_morning",
  "title": "Your 5-Minute Brief",
  "generatedAt": "2026-07-28T07:00:00Z",
  "stories": [
    {
      "id": "story_001",
      "headline": "ETF inflows cool while derivatives activity rises",
      "summary": "Two source-backed sentences only.",
      "category": "market",
      "importance": "high",
      "sentiment": "mixed",
      "verificationStatus": "sourceBacked",
      "assetTags": ["BTC", "ETH"],
      "sourceIds": ["source_001", "source_002"],
      "updatedAt": "2026-07-28T07:02:00Z"
    }
  ]
}
```

## GET /stories/search

Query:

- `q`
- `category`
- `asset`
- `sort`: `recent`, `importance`, `watchlist`, `sourceCount`

Returns story clusters with source metadata and pagination cursors.

## GET /stories/{id}

Returns full cluster context, all source links, changes since previous version, and verification evidence.

## POST /watchlist

Body:

```json
{
  "kind": "coin",
  "symbol": "BTC",
  "name": "Bitcoin",
  "alertSensitivity": "importantOnly"
}
```

## POST /notifications/register

Body includes APNs token, quiet hours, frequency, and explicit reason categories. The backend must persist why a notification was sent.

## POST /audio-briefings

Creates an audio briefing job from already verified story IDs. Response returns transcript, chapters, duration, and a signed audio URL.

## Error Shape

```json
{
  "code": "summary_not_grounded",
  "message": "The summary could not be linked to enough source evidence.",
  "requestId": "req_123"
}
```

