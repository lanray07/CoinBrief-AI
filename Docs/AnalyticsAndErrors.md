# Analytics And Error Catalog

Analytics should be privacy-preserving and avoid tracking users across apps or websites.

## Events

- `briefing_opened`
- `briefing_refreshed`
- `story_opened`
- `source_link_opened`
- `story_saved`
- `watchlist_item_added`
- `notification_rule_changed`
- `audio_briefing_started`
- `paywall_viewed`
- `purchase_started`
- `purchase_completed`
- `restore_completed`

## Error Codes

- `network_unavailable`
- `summary_not_grounded`
- `source_license_unavailable`
- `story_cluster_stale`
- `entitlement_unavailable`
- `purchase_cancelled`
- `purchase_failed`
- `notification_permission_denied`
- `offline_cache_miss`
- `audio_generation_failed`

Each backend response should include a `requestId` for support debugging.

