#!/usr/bin/env python3
"""Resolve the Apple Developer Team ID from App Store Connect bundle ID metadata."""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
import urllib.parse
import urllib.request

import jwt


def normalize_private_key(raw: str) -> str:
    key = raw.strip().replace("\\n", "\n")
    if "BEGIN PRIVATE KEY" not in key:
        raise ValueError("APP_STORE_CONNECT_API_PRIVATE_KEY does not look like a .p8 private key")
    return key


def make_token(key_id: str, issuer_id: str, private_key: str) -> str:
    now = int(time.time())
    payload = {
        "iss": issuer_id,
        "iat": now,
        "exp": now + 15 * 60,
        "aud": "appstoreconnect-v1",
    }
    headers = {
        "alg": "ES256",
        "kid": key_id,
        "typ": "JWT",
    }
    return jwt.encode(payload, private_key, algorithm="ES256", headers=headers)


def fetch_bundle_id(token: str, bundle_id: str) -> dict:
    query = urllib.parse.urlencode(
        {
            "filter[identifier]": bundle_id,
            "fields[bundleIds]": "identifier,seedId,name,platform",
            "limit": "1",
        }
    )
    request = urllib.request.Request(
        f"https://api.appstoreconnect.apple.com/v1/bundleIds?{query}",
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/json",
        },
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.loads(response.read().decode("utf-8"))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--bundle-id", required=True)
    args = parser.parse_args()

    key_id = os.environ["APP_STORE_CONNECT_API_KEY_ID"]
    issuer_id = os.environ["APP_STORE_CONNECT_API_ISSUER_ID"]
    private_key = normalize_private_key(os.environ["APP_STORE_CONNECT_API_PRIVATE_KEY"])

    token = make_token(key_id, issuer_id, private_key)
    payload = fetch_bundle_id(token, args.bundle_id)
    data = payload.get("data", [])
    if not data:
        print(f"No App Store Connect bundle ID found for {args.bundle_id}", file=sys.stderr)
        return 1

    seed_id = data[0].get("attributes", {}).get("seedId")
    if not seed_id:
        print(f"Bundle ID {args.bundle_id} did not include a seedId/team ID", file=sys.stderr)
        return 1

    print(seed_id)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
