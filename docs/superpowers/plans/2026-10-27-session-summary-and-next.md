# Session Summary + Next Steps

> **Session:** 2026-10-27
> **Branch:** `main` (docs commits local; push only when Luis asks)
> **Read this first when resuming.** Recheck live Play/AdMob state before
> acting — this is a dated snapshot.

---

## Where things stand

- **Production 1.0.1 (12)** is live on Google Play in **EU27 + Switzerland**
  (Submission 9, published 26 October 2026 at 15:55 Console time, 100%
  rollout). Luis treats this as the **first "valid" public version**.
  Source commit `272e07d`; see `RELEASE_CHECKLIST.md` for hash and receipts.
- **AdMob** is Ready / ad serving enabled; Policy centre clean
  (`ADMOB_PENDING.md`).
- Two plans exist for later work:
  - [Play Console recommendations](2026-10-27-play-console-recommendations-plan.md)
    — edge-to-edge, deprecated edge-to-edge APIs, large-screen/orientation,
    R8/AGP. **Next engineering work.**
  - [Country expansion to GB/US/CA/AU/NZ/SG/NO](2026-10-26-country-expansion-high-ecpm-plan.md)
    — **deferred** (see below).

## Recommended order (agreed with Luis on 2026-10-27)

1. **Observe 1.0.1 for 1–2 weeks — change nothing.** Read Play Console
   Android vitals (crashes, ANRs), ratings/reviews and the pre-launch report;
   check AdMob requests, impressions and consent rate look normal. Record
   findings in the release checklist. This is the evidence for "the app is
   mature".
2. **Website metadata (small, site repo).** In `/Users/luis/Niduna/niduna-site`
   update the App page `softwareVersion` 1.0.0 → 1.0.1 and the stale
   "Android update in review" status in `PENDING.md`. Pushing that repo
   deploys the live site (Vercel) — only with Luis's explicit OK.
3. **Play Console recommendations plan, Step 1 first** (baseline screenshots
   on Android 15/API 35 and Android 16/API 36, phone + tablet/foldable,
   gesture + 3-button nav, light/dark). Priority inside that plan:
   - **Large screens / orientation first.** The app targets **SDK 36**, so on
     Android 16 devices ≥600dp the manifest portrait lock is **already
     ignored** — tablet/foldable users likely get landscape today, untested.
   - **Edge-to-edge / insets second** — real overlap risk on Android 15+.
   - **Deprecated-API warning:** likely only cleared by a Flutter upgrade
     (Play scans the bundle code); cheap app-side step is described in the
     plan. Don't promise Play clears it.
   - **R8 / AGP 9 last** — optimisation, not a user-facing bug.
   Any fix needs a new, higher version code → Closed Alpha → Luis's phone
   acceptance → Production only when Luis asks.
4. **Real-device ad QA** (`ADMOB_PENDING.md` follow-up) when preparing that
   next version: consent, Privacy options in Settings, banner, opt-in
   rewarded ad, offline, Remove Ads. Never click own live ads.
5. **Country expansion — later, not forgotten.** Start only when Luis says the
   app is mature. Suggested readiness bar: the large-screen and edge-to-edge
   fixes are published, and 3–4 weeks without significant crashes/ANRs.
   US/UK/AU have many tablet users, so ship large-screen support first.

## Things a new agent tends to get wrong

- **Data Safety ≠ "no data collected".** Honest Fern collects nothing itself,
  but Play counts data sent by bundled SDKs. The live form declares AdMob's
  four categories (approximate location, app interactions, diagnostics,
  device/other IDs) and Advertising ID = Yes. Never change it to "not
  collected".
- **Consent ≠ no data leaving the device.** The UMP message (EEA/UK/CH only)
  lets users refuse at first launch or later via Settings → Data & privacy →
  Privacy options. Refusing switches AdMob to non-personalised/limited ads,
  which still send IP-derived location, device info and ad events. Consent
  changes the *use*, not whether data leaves — so the declaration stays.
- **Outside Europe there is no consent prompt** unless an AdMob US state
  regulations message is set up — required before any US expansion.
- Production submissions, country changes, price applies and site pushes
  each need Luis's explicit, per-action approval.
