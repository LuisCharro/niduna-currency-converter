---
name: store-release-check
description: Use when a task touches app-store compliance, privacy, sensitive data, permissions, ads, analytics, or release preparation for Apple App Store or Google Play.
---

# Store Release Check

Start with:

- `$HOME/SKILLS/release/store-release-check.SKILL.md`

Use this local wrapper for the repo's privacy constraints and local release docs.

## Trigger

Use it when changing:

- privacy behavior
- ads (AdMob integration)
- permissions
- data handling (cache, storage)
- release metadata or policy-facing docs
- Remove Ads IAP implementation

## Repo-specific checks

1. Does the change collect, transmit, share, or expose user data?
2. Does the change require a new platform permission?
3. Would App Store privacy details or Play Data safety need to change?
4. Would a public privacy policy or in-app privacy text need to change?
5. Does the app metadata or UI overclaim accuracy of rates?
6. Are ads implemented as banner-only in Phase 1 (no interstitials)?

## Repo-specific rule

For this app, the safe default is:

- privacy-first tool
- zero tracking
- zero accounts
- zero data collection
- offline-capable with cached rates
- banner ads only (Phase 1)

Any change that weakens those assumptions should be treated as higher-risk.

## Completion

Call out:

- whether the change affects store compliance
- whether new disclosures are required
- whether the app is still within privacy-first positioning
