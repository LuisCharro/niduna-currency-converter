# Country expansion to high-eCPM markets — plan (2026-10-26)

**Goal:** extend Production distribution from the current 28 countries
(EU27 + Switzerland) to the seven non-EU markets that actually pay for ads:
**GB, US, CA, AU, NZ, SG, NO**. No new AAB, no new version code, no rebuild.

**Target date:** deferred — not before ~2026-11-26, and only once Luis
considers the app mature (his timing: "in 1 month when the app is stable").
1.0.1 (12) was published on 26 October 2026 (Submission 9); maturity, not the
publication receipt, is now the gate. If a new binary (for example the Play
Console recommendations work) is in review at that time, review the whole
pending Play batch before submitting a country change alongside it.

**Evidence:**

- Current Production country set: the 28 ISO codes in
  `docs/release-prep/production-release-plan.json` → `proposedCountries` /
  `selectedCountries` (AT BE BG HR CY CZ DK EE FI FR DE GR HU **IE** IT LV LT
  LU MT NL PL PT RO SK SI ES SE + CH). Release 11, published 2026-10-22.
- `docs/release-prep/eu-distribution-review-2026-10-20.md`: UK, Norway,
  Iceland, Liechtenstein and Rest of World were **explicitly unchecked**; EU27
  + CH was chosen because Google's country-distribution notice and the EU
  geo-blocking regulation make EU-wide access the safe default.
- Pricing state: `stores/google-play/pricing/README.md`. Two applied
  policies — `launch-policy.proposed.json` (EUR/CHF/USD, applied 2026-10-19)
  and `eu6-policy.proposed.json` (6 non-euro EU markets, applied 2026-10-20).
  Three one-time products × 174 regions = 522 price rows; the last run
  changed 18 rows and kept 504.
- Current price ladder: Remove ads **CHF 2.00 / EUR 1.99 / USD 1.99**;
  Charts Pro **CHF 3.00 / EUR 2.99 / USD 2.99**; Favorites Pro
  **CHF 1.00 / EUR 0.99 / USD 0.99**.
- Tooling surface: `stores/google-play/scripts/pricing.py` exposes
  `catalog` (authenticated read), `plan` (offline comparison) and `apply`
  (write, with a fresh-catalog guard and a receipt dir).
  `stores/google-play/scripts/google_play.py` exposes only
  `status | verify-access | plan-closed | upload-closed` — **there is no
  Production country command** (see D1).
- Listing: only `docs/release-prep/play-listing-en-GB-reviewed.json` exists.
  No en-US listing is recorded.

---

## A. Scope correction — read before executing

1. **IE is already live.** Ireland is one of the 27 EU member states and is
   already in the 28-country set. The real expansion is **7 countries**
   (GB, US, CA, AU, NZ, SG, NO), not 8. Do not submit a redundant IE row.
2. **US already has USD prices.** The `launch-policy.proposed.json` policy
   already sets USD 1.99 / 2.99 / 0.99 for the US region, because the US was
   priced in anticipation of distribution. US therefore needs **no pricing
   work at all** — only country targeting. It is also the highest-eCPM
   market on the list, which makes it the cheapest and most valuable single
   addition.
3. **Six new currency tiers are needed** for the other six markets:
   GBP (GB), CAD (CA), AUD (AU), NZD (NZ), SGD (SG), NOK (NO).
4. **The app itself is already correct for these markets.** Honest Fern
   collects no data itself (no account, no server, no first-party
   analytics); the AdMob SDK's collection is already declared (see B4). The
   currencies come from
   the same public providers. Nothing in the binary is EU-specific.
   **No new AAB and no version code bump.** The app is already translated
   where it matters: the listing is en-GB, which covers GB, IE, NZ and SG.
   The only listing gap is **en-US** for US/CA/AU.

---

## B. The actual work (four items, in order)

### B1. Country targeting on the Production track — Console UI

The only path today. In Play Console → the app → **Production** → the
existing release → **Manage countries / Manage country availability** → add
GB, US, CA, AU, NZ, SG, NO. Record the selected ISO codes.

- Country availability is a **Production track setting** (Countries /
  regions), not a new binary. Whether the Console presents it as a separate
  change or a new release entry is unverified — record what it shows.
- Country changes **go through Play review**. With managed publishing off,
  approval may publish automatically — verify, do not assume.
- Expected review time for a country-only change is much shorter than a
  binary review, but **do not treat that as a promise**; budget one working
  day and verify the Publishing overview.
- Watch the known trap from the tooling-friction plan: the track summary
  displays the new state immediately while **Publishing overview still says
  "not yet submitted"**. Use the Publishing overview as the source of truth.

### B2. IAP prices for the six new currencies

Copy the `eu6-policy.proposed.json` pattern into a new policy file,
e.g. `stores/google-play/pricing/global7-policy.proposed.json`, with
`regionOverrides` for GB/CA/AU/NZ/SG/NO and the same ladder as the USD
policy, rounded to each currency's natural step:

| One-time product | GBP | CAD | AUD | NZD | SGD | NOK |
|---|---:|---:|---:|---:|---:|---:|
| Remove ads | 1.99 | 2.49 | 2.99 | 2.49 | 2.29 | 19.99 |
| Charts Pro | 2.99 | 3.49 | 4.49 | 3.99 | 3.49 | 29.99 |
| Favorites Pro | 0.99 | 1.29 | 1.99 | 1.29 | 1.29 | 9.99 |

These are **starting proposals, not approved prices**. Run the tooling to
get the real current values first, then adjust:

```
python3 stores/google-play/scripts/pricing.py catalog --output <new-catalog.json>
python3 stores/google-play/scripts/pricing.py plan --catalog <new-catalog.json> \
    --policy stores/google-play/pricing/global7-policy.proposed.json \
    --output <new-plan.json> --csv-output <new-plan.csv>
```

Review the CSV row by row, then apply with `--confirm-package
com.honestfern.currency_converter` and a fresh receipt dir. The `apply`
command refuses an existing output path — use new receipt paths, never
overwrite. Prices in Play are **ex-VAT with local tax added at checkout**;
the CSV comparison does not validate Google's price range, tax or currency
precision, so **review the final checkout in one market per currency** after
propagation.

### B3. Store listing language coverage

- The listing is **en-GB only**. GB, IE, NZ and SG are served correctly by
  en-GB. US, CA and AU will also be served en-GB (English), which works but
  is not ideal.
- Optional, low effort, meaningful for US conversion: add an **en-US
  listing** (same title and short description, US spelling, no en-GB-only
  phrasing). Reuse `play-listing-en-GB-reviewed.json` as the template and
  mirror the structure of `play-store-listing.md`.
- Not required for launch. Do it in the same window if the Console copy
  flow is fast, otherwise leave it for the next release.

### B4. Per-market compliance re-check (light)

Honest Fern collects no data itself, but Play's Data Safety form counts
data sent off-device by bundled SDKs. The live form (RELEASE_CHECKLIST.md,
2026-09-10 checkpoint) therefore declares the four AdMob SDK categories —
approximate location, app interactions, diagnostics, device/other IDs — and
Advertising ID **Yes**. That declaration is market-independent; recheck it
only if the SDK or ad formats change. Confirm, do not re-architect:

- **US**: privacy policy link — the site privacy page already serves it;
  confirm it names the app and the publisher. **Also set up AdMob's US
  state regulations message** (Privacy & messaging) before US goes live:
  the current "Honest Fern Europe Consent" message covers EEA/UK/CH only.
  See `ADMOB_PENDING.md` follow-up.
- **UK**: UK GDPR + DPA — covered by the existing EU posture; the UK is
  post-Brexit, so the policy page should not claim "EU only".
- **CA (PIPEDA)**, **AU (Privacy Act)**, **SG (PDPA)**, **NO (GDPR)**:
  no first-party collection and no account; confirm the privacy page's
  AdMob disclosure is not worded as EU-only. NO is EEA, so confirm the
  European consent message targets it.
- **Ads**: the listing must keep the "Contains ads" disclosure. AdMob
  serves in all seven markets. Confirm the app is **not** marked as
  "Designed for children" — the current target audience is 13+, which is
  already saved in Console.

---

## C. Verification — what proves it worked

1. **Before submitting:** fresh `pricing.py catalog` read; confirm the 7
   countries appear with the intended price overrides and that no other
   region's price changed.
2. **After submission:** read the Production track body back and confirm
   `countryCodes` contains 28 + 7 = **35** ISO codes, and that the
   previously selected 28 are all still present (a country edit that
   *replaces* rather than *adds* is the classic failure).
3. **Publishing overview** must show the change as submitted, then as
   live. Do not trust the track summary alone.
4. **Live listing spot-check:** open the Play listing from a US IP and
   from a GB IP, confirm the app is installable and the "Install" button
   is live in both.
5. **Price spot-check:** a real checkout in each new currency needs a
   Google payments profile in that country, so it is not practical. Verify
   per-region prices in the fresh catalog read and Console instead, and
   test the purchase flow itself with a license tester in a market you can
   reach.
6. **Console Pricing → One-time products:** confirm the products are
   ACTIVE in each new region (a price override on an inactive product does
   nothing).

---

## D. Known gaps and follow-ups

1. **D1 — There is no scripted Production-country command.**
   `google_play.py` only knows `status | verify-access | plan-closed |
   upload-closed`. The 28-country expansion was done by hand in the Console
   and recorded in `production-release-plan.json` as a *planning record, not
   an executable payload*. Adding a `plan-production` / `upload-production`
   pair (mirroring the closed path) would make this repeatable for every
   future app and market. That is a **tooling task, not a prerequisite** —
   the expansion can be done in the Console today.
2. **D2 — `production-release-plan.json` is a historical record.** It
   describes release 11 with 28 countries. After this expansion, either
   write a new dated record (e.g.
   `docs/release-prep/production-release-plan-2026-11-xx-global7.json`) or
   update it, but do not silently edit the release-11 record.
3. **D3 — Release state is duplicated** across `AGENTS.md`,
   `RELEASE_CHECKLIST.md` (1300+ lines), the publishing runbook and
   `AGENTS.local.md`. Step 8 of the release-tooling-friction plan proposes a
   single `RELEASE_STATE.md`. The country change touches three of those
   files by hand — this is a good moment to start that consolidation.
4. **D4 — Price propagation delay.** The 2026-10-20 run noted the checkout
   may lag. Verify each market after propagation, not immediately after
   the apply receipt.

---

## Suggested batches

- **Batch 1 (no-risk, no approval):** D1/D2 prep — write the new pricing
  policy draft, run `pricing.py catalog` + `plan` into fresh paths, and
  produce the reviewed CSV for inspection. **Nothing is written to Play.**
- **Batch 2 (pricing):** B2 review of the CSV, then `apply` with Luis's
  explicit approval naming the package and the receipt dir. Prices go
  **before** countries: overrides for regions not yet distributed are
  invisible, whereas opening countries first would briefly show Google's
  auto-converted prices.
- **Batch 3 (compliance):** B4 — AdMob US state regulations message and
  privacy-page check, before US goes live.
- **Batch 4 (Console, country targeting):** B1 country selection +
  submit, with Luis's explicit approval. Verify 35 codes afterwards.
- **Batch 5 (polish):** B3 en-US listing, D3 doc consolidation.

Verification per batch: fresh authenticated read of the track body and the
pricing catalog; `./scripts/check.sh` is not affected (no Dart change) but
should stay green.

## Status (updated 2026-10-27)

- Plan written and reviewed. **No Play state changed, no pricing applied, no
  release submitted.**
- **Deferred:** 1.0.1 (12) is published (26 October); Luis will start this
  only once the app is mature. Recheck every live fact above before
  executing — prices, countries and Console flows may have changed.
- Awaiting from Luis: approval of the six currency price ladders in B2
  before any `pricing.py apply` runs.
