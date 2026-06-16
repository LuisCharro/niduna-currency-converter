# Code-Only Next Steps (no accounts, no backend)

> **Created:** 2026-06-16
> **Branch:** `main`
> **Scope rule:** Only work achievable purely in code on the local emulators —
> **no** account registration (Play Console / AdMob / Apple Developer), **no**
> backend, **no** hosting. Those launch chores are tracked separately in
> [`RELEASE_CHECKLIST.md`](../../../RELEASE_CHECKLIST.md).

---

## Context

Phase 1 is **code-complete and release-ready for Android** (keystore signing
wired, signed AAB built, dark-mode audit, cross-provider chart tests, UI polish
— see `RELEASE_CHECKLIST.md`). The remaining launch blockers are **external**:
host the privacy policy, register Play Console + AdMob, swap in real ad-unit IDs,
rotate the temporary keystore password, upload.

This document captures the worthwhile **code-only** improvements while those
account/hosting items are out of scope. Priority order below. Each item still
needs a brainstorm/spec pass before implementation (except the small edge items).

---

## 1. Pre-launch robustness & accessibility pass — **PRIORITY**

**Goal:** Make the app feel launch-grade in the states real users hit, not just
the happy path on a seeded emulator.

**Why:** This is the single highest-leverage code-only work before a store
launch. Blank screens on a failed fetch, no screen-reader labels, or layouts
that break at large font sizes are exactly what drives 1-star reviews — and none
of it needs accounts or a backend.

**Scope (candidate tasks — confirm during brainstorm):**
- **Error / empty / offline states:** what the Convert, Favorites, and Charts
  tabs show when a rate fetch fails, when there is no cached data on first run,
  and when offline. Clear messaging + retry affordance instead of blank/half
  states.
- **Loading treatment:** consistent skeleton/spinner while rates/charts load
  (audit what currently shows during the first fetch).
- **Accessibility:** semantics labels on icon-only controls (refresh, share,
  drag handle, remove), correct screen-reader reading order, Dynamic Type /
  large-font layout survival, contrast checks in light + dark.
- **UI-redesign Phase 4 "visual density":** still marked *partial* in `PLAN.md` —
  finish the Settings density/spacing cleanup.

**Verification:** emulators we already drive (iOS sim + Android Pixel7_EN);
toggle airplane mode / kill network, enable large text + VoiceOver/TalkBack,
capture before/after.

**Effort:** medium, splittable into independent slices (states, a11y, density).

---

## 2. Home-screen widget families (small + large) — **NEXT**

**Goal:** Offer more widget sizes. Today both platforms ship **medium only**
(3-pair). Add **small** (single most-used pair) and **large** (more pairs, or a
mini sparkline) layouts.

**Why:** Self-contained, code-only, verifiable on the emulators, and a natural
continuation of the widget work just completed (iOS now matches the Android
3-pair design and reads data correctly on the simulator). Visible, satisfying,
low architectural risk.

**Scope (candidate tasks — confirm during brainstorm):**
- **iOS:** add `.systemSmall` (1-pair) and `.systemLarge` to
  `supportedFamilies` in `NidunaWidget.swift`; design the per-size SwiftUI
  layouts (small = symbol circle + value; large = more rows / optional footer).
- **Android:** provide matching layouts and `minWidth/minHeight` /
  `targetCellWidth` sizing so the widget resizes cleanly; reuse the existing
  warm-paper + dark-green-circle styling.
- Keep the shared data contract (`pair_{i}_*` keys) unchanged — sizes are a
  presentation change only.

**Caveat:** iOS widget data works on the **simulator** today via the
build-script entitlement re-sign; physical-device rendering still needs the App
Group provisioned with an Apple Developer team (out of scope here).

**Effort:** small–medium per platform.

---

## 3. Multi-pair chart comparison — **LAST / likely too much for now**

**Goal:** Let the Charts tab overlay/compare more than one pair at once.

**Status:** **Deferred. Do NOT start without a dedicated UI/UX design pass.**

**Why it's last:** Per the user (2026-06-16) and the harmonization notes, this
probably means **reworking the Charts tab UI/UX almost entirely** — pair
selection for N series, color assignment, legend, normalization (different
scales/units, e.g. fiat vs BTC), readability of overlaid lines, range controls,
and tap-to-inspect across series. That is a large redesign, not an incremental
feature. It uses existing chart data (**no backend**), but the surface area and
risk are high.

**Open design questions (to resolve in a future brainstorm before any code):**
- How many series at once, and how does the user pick/remove them?
- How are wildly different scales reconciled (indexed % change vs absolute)?
- Does it live in the existing Charts tab or a new comparison mode?
- Color/legend system, and how it reads in light + dark.

**Recommendation:** Revisit after launch (or after items 1–2). When picked up,
start with `superpowers:brainstorming` → spec → plan, and treat it as a Charts
tab redesign, not a small addition.

---

## Smaller code-only edge items (pick up anytime)

- **Rotate the temporary keystore password** (`android/key.properties` is marked
  TEMP) — local/security hygiene, must happen before publish regardless.
- **Widget golden / integration tests** for the new iOS + Android widget layouts.
- **`_save` / `_persist` dedup** in `favorites_store.dart` (noted in code review).

---

## Out of scope (needs accounts / hosting / backend)

Privacy-policy hosting + in-app link, real AdMob ad-unit IDs, Play Console /
Apple Developer enrollment, AAB/IPA upload, rate alerts and any other backend
features. See `RELEASE_CHECKLIST.md`.
