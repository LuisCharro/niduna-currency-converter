# Final Play Console review — 19–20 October 2026

## Outcome and scope

Read-only review of the authenticated owner Console in Chrome, the public
storefront, Publisher API metadata/catalog and deployed public policy files.
Production is **not published**. No Console answers, countries, prices, listing,
security settings or releases were saved/submitted in this review. Temporary
API read edits were deleted. No new binary, build or automated tests.

Build 10 remains the accepted Closed candidate. Do not interpret Console's
“No issues found” as confirmation that every declaration is accurate.
Resolve the findings below before Production; this audit is not legal clearance.

## Verified live

| Area | Observed result |
| --- | --- |
| Access and tracks | Production access granted; Production empty; Closed Alpha code 10 available to selected testers; Internal code 7 |
| Publishing overview | No unpublished changes at inspection; managed publishing off |
| Policy | No issues found; App content has 10 actioned declarations and none needing attention |
| Distribution | Closed ES/CH; Production has no selected countries |
| Billing | Three active one-time products; CH prices Remove Ads 2, Charts 3, Favorites 1 CHF; owner reports matching checkout and successful purchases/Restore |
| Gallery | All six live phone images match manifest SHA-256/order, including the Charts expand button |
| Listing | en-GB default; title and short description correct; full description correction below |
| Category/contact | Tools; honestfern.com; support@honestfern.com |
| Audience/rating | 13–15, 16–17, 18+; IARC completed, ESRB Everyone / PEGI 3 |
| Ads / Advertising ID | Ads Yes; Advertising ID Yes for analytics, advertising and fraud prevention |
| Other declarations | No health features; no government affiliation; no financial features selected for this rates/calculator app |
| Privacy | Correct app policy URL; app/site privacy pages and app-ads.txt return HTTPS 200 and match local deployed files |
| Protection | Play signing active; automatic protection 1/1; Play Store protection 6/7; Billing 3/4; Integrity API not integrated |

The protection scores are not release requirements. Store listing device checks
are off; no reason was established to enable them or integrate Integrity API
for this launch. No keys or security settings were changed.

## 1. Correct Data safety purposes before submission

Current Data safety declares approximate location, app interactions, diagnostics,
and device/other IDs collected AND shared, non-ephemeral and required. Encryption
in transit is Yes; no app accounts or external login. Existing deletion-request
answer is No: local Clear all data alone does not justify changing that answer.

Device IDs currently claims developer communications and account management,
which do not match this app. The separate Advertising ID form already has the
correct analytics/ads/fraud purposes; do not confuse the two forms.

Abbreviations: A = Analytics; M = Advertising or marketing;
F = Fraud prevention, security and compliance; D = Developer communications;
C = Account management.

| Data | Current collected | Current shared | Proposed collected | Proposed shared |
| --- | --- | --- | --- | --- |
| Approximate location | M,F | A,M,F | A,M,F | A,M,F |
| Diagnostics | A,F | A,F | A,M,F | A,M,F |
| App interactions | A,M,F | A,M,F | A,M,F | A,M,F |
| Device/other IDs | A,D,C | A,D | A,M,F | A,M,F |

Basis: app has google_mobile_ads 8.0.0 / Android GMA 25.1, UMP consent gating,
non-personalized ad requests and no first-party accounts, messaging or analytics.
Google's disclosure guide lists these automatic SDK data groups and the three
purposes globally. Its current example describes SDK 25.5; the exact per-field
matrix above is our mapping to that guidance, not captured network evidence or
a version-specific SDK certification. Reconfirm this mapping before saving.
Non-personalized ads do not mean no SDK data collection.

Sources:
- [AdMob Play data disclosure](https://developers.google.com/admob/android/privacy/play-data-disclosure)
- [Data safety form](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en)
- [Data types and purposes](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en-GB)

## 2. Reviewer access: current No answer needs correction

Console's “Sign-in details” asks whether ANY part is restricted and explicitly
includes payments, one-time products and access tiers. Current answer is No.
This app has paid features, even though it has no login. Google's declaration
reference and review-access guidance therefore require addressing restricted
access; do not leave No simply because no username/password exists.

**Open issue:** establish a legitimate, reliable way for Google reviewers to
access all paid features free of charge before selecting Yes and attesting full
access. We found no official confirmation that review accounts automatically
receive license-test cards for native Play Billing. Luis's license-test account
success does not establish reviewer access. Restore cannot restore purchases
never owned. Rewarded ads are not yet demonstrated to provide reliable full
review access. Do not share personal Google credentials or re-enable a public
developer-mode premium bypass.

A support question draft follows. It is NOT sent and is not ready-to-submit
reviewer instructions. If clarification requires an app change, retain code 10
as the current candidate and use a new version code for the changed binary.

### Unsent support question draft

Subject: Free reviewer access for a no-login app with three Play one-time products

Our app com.honestfern.currency_converter has no app account or login. Core
currency conversion is free. Google Play non-consumable one-time purchases
remove ads or unlock Charts Pro / Favorites Pro. Purchases are restored through
Google Play. We want to answer Sign-in details correctly and give reviewers
free access to every feature without sharing a personal Google account or
shipping a public developer unlock.

What is the supported review-access procedure for this model? Can Google Play
reviewers use sandbox purchases without being added to our license tester
list, and is that documented? If not, what access mechanism and instructions
should we supply for an app with no account system? We will not attest that
free access exists until the accepted mechanism is confirmed.

Sources:
- [Policy declarations, section 5: testing credentials](https://developers.google.com/android-publisher/app-store-review/policy-declarations)
- [Requirements for providing sign-in details](https://support.google.com/googleplay/android-developer/answer/15748846?hl=en)
- [Prepare app for review](https://support.google.com/googleplay/android-developer/answer/9859455?hl=en)
- [Billing test accounts](https://developer.android.com/google/play/billing/test)

## 3. Prepared listing correction; not applied

`play-listing-en-GB-reviewed.json` contains the complete current listing with
only two CONVERT sentences replaced. Current text incorrectly attributes all
fiat data to ECB and implies automatic daily refreshing. Actual app uses the
Frankfurter default blended route; refresh behavior depends on settings/use.

Replacement: “Reference exchange rates and crypto prices are fetched online.
The app shows the source date.” Title, short description and remaining copy
are preserved. This is a draft, not a CLI upload payload. Inspect the whole
pending change batch before saving/submitting; managed publishing is off.

## 4. Production countries: owner decision still pending

No countries are selected. Recommendation for Luis's first public launch:
Spain and Switzerland, matching the existing Closed distribution. This limits
initial support/checkout monitoring; it is an operating choice, not a Google
requirement or a guarantee of legal compliance. Luis asked for advice and has
not yet selected an option. No country configuration was changed.

Adding countries later does not itself require a new binary. A currency
supported by the converter is not a reason to enable that country. Regional
product prices do not enable app distribution.

[Google: distribute releases to specific countries](https://support.google.com/googleplay/android-developer/answer/7550024?hl=en)

## 5. Console technical recommendations

Code 10 has three user-experience recommendations: Android 15 edge-to-edge,
deprecated edge-to-edge APIs/parameters, and large-screen resizability/orientation
restrictions on Android 16. These appeared as recommendations, not reported
policy violations or rejection blockers. No new app changes/tests were made.
Owner phone acceptance does not demonstrate tablet/foldable coverage.

## Remaining sequence

1. Resolve reviewer access and review the proposed Data safety purpose mapping.
2. Apply accurate declarations/listing as an explicitly reviewed submission batch.
3. Confirm and configure Production countries; recheck all pending changes.
4. Preserve the exact accepted build-10 artifact unless a binary fix is necessary.
5. Address the outstanding source/controller adequacy questions in
   `data-licensing-and-disclosure-review-2026-10-19.md`; this Console review did
   not close them. Current web policy already qualifies Android backup/restore.
6. Obtain owner instruction for Production submission/publication. After public
   availability, perform the website's separate S2 Coming Soon/download change.

## Evidence (ignored local files)

`.tmp/play-final-audit-20261019/`: API listing/country/gallery read, product
catalog, HTTPS hashes, each declaration's observed text, release advisories,
and protection state. `app-access.txt` records the explicit payments condition;
`data-ids.txt` / `data-ids-current.png` record the incorrect purpose checkboxes.
Track receipt: `.tmp/play-candidate/20261019-build10/final-console-status.json`.
Gallery comparison: `docs/release-prep/screenshots/play-gallery-manifest.json`.
Do not commit private Console captures or personal developer/tester details.
