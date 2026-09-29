# UX review + pre-closed-test polish plan — 2026-09-29

**Goal:** one bounded UI/UX round before uploading the build that starts the
Closed test. No new features, no data/cache/provider changes, no monetization
logic changes.

**Evidence:** `.devtools/capture_android_ux_tour.sh` (new) ran
`integration_test/ux_review_tour_test.dart` (new) as a fresh free user with
`release_safe` / `APP_DEV_MODE=false` on:

| AVD | Screen | Notes |
|---|---|---|
| `Small_Screen_API_36` | 720×1280 @320 (360×640 dp) | smallest target |
| `exp_night_36` | 1080×2340 @440, **font_scale 2.0** | accessibility / large text |
| `Pixel7_EN` | 1080×2400 @420 | store screenshot device |

Screens: `.tmp/screens/android/ux-tour/<avd>/<light|dark>/` (16 each).
Note: the AdMob banner is a platform view and is not captured, so the "AD"
shelf looks empty in these screenshots only.

---

## A. Bugs (fix first — small, objective)

1. **Large-text overflows (font scale 2.0)** — 5 RenderFlex overflows:
   - `shared/widgets/floating_pill_nav_item.dart:49` — nav labels clip
     ("Conv", "Favor", "Setti") + overflow stripe on every tab.
   - `features/convert/widgets/swipe_action_widgets.dart:153` — swipe action labels.
   - `features/settings/widgets/base_currency_picker.dart:35` — title row
     overflows by 107 px.
   - `features/favorites/widgets/favorites_limit_note.dart:59,81`.
   - `features/charts/widgets/chart_touch_overlay.dart:56`.
   Also: Convert rows clip their second line ("1 USD = …" cut in half),
   converted values shrink to unreadable size, Favorites pair title
   collapses to "U…".
2. **Settings section headers misaligned** — "Data" and "About" are centered,
   "Conversion"/"Premium" left. `settings_data_section.dart` and
   `settings_about_section.dart` Columns lack
   `crossAxisAlignment: CrossAxisAlignment.start`.
3. **Conversion Lens quick amounts formatting** — left column shows
   `1.000`, `10.00`, `50.00`, `100`, `1,000` (mixed decimals/separators).
4. **Store/listing claims that are not true in the app:**
   - "Dark mode — follows your system setting": it is a manual switch
     defaulting to Off (`AppPreferences.isDarkMode ?? false`).
   - "the in-app Settings screen links to our contact page": About only has Version.

## B. UX improvements (high value, low risk)

5. **Feedback / contact entry in Settings → About** — "Send feedback"
   (mailto or site contact page). Needed for Closed testers.
6. **Rename "Privacy" → "Privacy policy"** so it is distinct from
   "Data & privacy".
7. **Dark mode: add "Follow system"** (System / Light / Dark), default System.
   Matches the listing and Android expectations.
8. **Currency pickers: show the useful ones first** — all groups are
   collapsed on open. Add a "Selected"/"Popular" section at the top
   (base + visible + common: USD EUR GBP JPY CHF…); expand the group
   containing the current selection.
9. **Unify pickers** — Settings "Default base currency" uses a different
   flat-list picker (different title style, search placeholder
   "Search code or n…", different rows) from the grouped Convert/Charts pickers.
10. **Picker titles** — "Select base currency" / "Select quote currency"
    wrap to 2 lines in the large serif on small phones. Shorter title or
    smaller style.
11. **Discoverability of row actions** — the Conversion Lens only opens by
    a 0.8 s hold, and swipe actions are hidden. Add a one-time hint (like
    Favorites' swipe hint) or make a normal tap open the lens.
12. **Small screen density (Convert)** — on 360×640 with ads only ~2.3 rate
    rows are visible. Options: compact amount card on short screens
    (smaller number, status line inline), tighter row height.
13. **Charts header** — "Charts" + "USD / EUR" are two stacked big serif
    headlines; the range selector sits in a white box that doesn't match
    the canvas (light mode). Drop one headline level; make the selector
    background transparent/canvas.
14. **Swipe action label "Saved"** — ambiguous; use "Favorite"/"Unfavorite".
15. **JPY/KRW-style currencies show `.00`** (`¥15,733.00`) — zero-decimal
    currencies should render without decimals.
16. **Crypto rows have no trend badge** while fiat rows do — either show it
    or align the layout so rows don't look inconsistent.

## C. Store content

17. **Re-capture store screenshots** after A/B — current set shows the old
    header/status wording.
18. **BTC chart screenshot** shows `USD / BTC` with −18 % in red while
    Bitcoin went up. Capture `BTC / USD` instead.
19. **Captioned screenshots** — add short headline captions over a brand
    background ("Convert 45 currencies", "Charts up to 2 years",
    "Your pairs, one tap", "No account. No tracking."). Plain app screens
    under-sell in the store.
20. **Listing text** — fix the two false claims (A4) or implement B5/B7 so
    they become true; recount features after changes.

## D. Housekeeping

21. `CLAUDE.md` says version stays `0.x.x`, but `pubspec.yaml` is
    `1.0.0+6` and Play already has 1.0.0 builds — update the doc rule.

---

## Suggested batches

- **Batch 1 (bugs):** 1, 2, 3, 6, 14, 15 — then re-run the tour on all 3 AVDs.
- **Batch 2 (UX):** 5, 7, 8, 9, 10, 13 (+ 11, 12 if time).
- **Batch 3 (store):** 17–20, then version bump + Play candidate.

Verification per batch: `./scripts/check.sh`, then
`./.devtools/capture_android_ux_tour.sh` and compare against this review.
