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
6. Are normal ad surfaces banner-only, with rewarded ads initiated only by a
   clear user action for the documented temporary unlocks (no interstitials)?

## Repo-specific rule

For this app, the safe default is:

- privacy-first tool
- no first-party analytics or Niduna user profiling
- zero accounts
- no backend collection; disclose Google Mobile Ads SDK collection/sharing
- offline-capable with cached rates
- banner ads on normal surfaces; opt-in rewarded ads only for documented
  temporary chart/favorites unlocks; no interstitials

Any change that weakens those assumptions should be treated as higher-risk.

## Completion

Call out:

- whether the change affects store compliance
- whether new disclosures are required
- whether the app is still within privacy-first positioning
