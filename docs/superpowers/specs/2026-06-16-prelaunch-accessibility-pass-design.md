# Pre-launch Accessibility Pass (+ light robustness verify) — Design

> **Status:** Design approved 2026-06-16. Ready for implementation plan.
> **Branch:** `main` (user authorized working on main).
> **Backlog item:** #1 from `docs/superpowers/plans/2026-06-16-code-only-next-steps.md`.

---

## Goal

Bring the app to a launch-grade **accessibility** bar (screen reader, Dynamic
Type, contrast) and **verify** the already-built error / empty / offline states
render correctly. Code-only, no accounts, no backend, low risk, no new features.

## Why

The robustness layer is already in good shape: a full status model
(`ConvertStatus { loading, refreshing, fresh, cached, stale, noCache }`), shimmer
skeletons (`RateRowSkeleton`), a localized empty/no-cache panel
(`DesignedStatePanel`), and per-tab empty/error states for Charts and Favorites.
The measurable gap is **accessibility**: only ~5 `Semantics` widgets exist
app-wide, Dynamic Type handling is partial, and contrast hasn't been audited in
both themes. These are exactly the things that hurt store ratings and platform
review, and they need no accounts or backend.

## Non-goals

- Deep robustness rebuild (distinct network-error vs no-cache, offline banner,
  retry/timeout) — the basics already exist; only verify them.
- Settings "Phase 4 visual density" cleanup — tracked separately.
- Any new features, backend, or account/hosting work.
- Modifying `AppColors.dark` — it is fixed; only use existing tokens.

---

## The Accessibility Bar (acceptance criteria)

1. **Labels & roles:** every interactive / icon-only control exposes a
   meaningful, **localized** semantic label and the correct role (button,
   toggle). No unlabeled `IconButton`/tap target.
2. **Reading order:** VoiceOver/TalkBack traverse each screen top-to-bottom in a
   logical order; grouped rows read as a unit where that aids comprehension
   (e.g. a currency row reads "Euro, 1 US dollar is 0.86 euro" rather than four
   disjoint fragments — exact grouping decided per row during implementation).
3. **Dynamic Type bar:** layouts survive the **largest standard** text size plus
   **one accessibility size** with no clipping or overlap — achieved via
   scrolling, wrapping, or `minimumScaleFactor`, not by chasing the absolute max
   (AX5). Verified on both platforms.
4. **Contrast (~AA):** text and meaningful icons meet roughly WCAG AA in **light
   and dark**, using existing `AppColors` tokens. Any fix swaps to an existing
   token or adjusts opacity — never edits `AppColors.dark`.
5. **Decorative elements hidden:** images that merely duplicate adjacent text
   (e.g. a flag next to the currency code) are excluded from the AT tree.

---

## Coverage Inventory

Interactive controls + meaningful images to label/verify:

- **Convert:** refresh, share, more/settings, base-currency selector, amount
  field, each currency row (open + favorite star), add-currencies, freshness
  `(i)` info, swipe actions (pin/swap/hide/remove).
- **Favorites:** open pair, remove (×), drag handle (already localized via
  `reorderFavoriteTooltip`), add, watch-ad / buy-pro.
- **Charts:** pair selector/pill, range buttons (1W…2Y), chart summary
  (high/low/change should be announced as text), watch-ad / buy-pro.
- **Settings:** every row, toggle, IAP button, external link, version row.
- **Sheets/dialogs:** currency picker, amount input, conversion lens, info
  sheets (`DailyRatesInfoSheet`), IAP players.

A label that already exists (`removeFavoriteTooltip`, `reorderFavoriteTooltip`)
is reused; new labels become new ARB keys.

---

## Approach (slices)

1. **Shared infra + shared widgets.** Add a small, consistent way to attach
   localized semantic labels (a helper/extension or just disciplined
   `Semantics(label: l10n(context)...)`). Fix the shared widgets first
   (`shared/widgets/*`, the bottom nav, shared buttons) since they propagate to
   every screen. Add new `l10n` keys to **all five** ARB files
   (`app_en/de/es/it/fr.arb`) and regenerate (`flutter gen-l10n`).
2. **Per-area labels + reading order:** Convert → Favorites → Charts → Settings
   → sheets/dialogs. One commit per area to keep diffs reviewable.
3. **Dynamic Type survival:** audit each screen at the bar from criterion 3; fix
   clipping/overflow with scroll/wrap/`minimumScaleFactor`.
4. **Contrast:** light + dark audit; fix with existing tokens / opacity.
5. **Light robustness verification:** drive both emulators with network off and
   with no cache (fresh install) to confirm Convert/Favorites/Charts render
   their loading/empty/offline states. **Delete the orphaned `InlineEmptyPanel`**
   (`lib/src/shared/widgets/inline_empty_panel.dart`) — it has no references and
   every tab already has its own panel (Convert → `DesignedStatePanel`, Favorites
   → `FavoritesEmptyState`, Charts → `ChartsEmptyState`/`ChartsErrorState`), so it
   is dead code. (If verification surfaces a tab that is actually missing a panel,
   add one using the existing pattern instead.)

---

## Verification

- **Widget tests** asserting key controls expose semantic labels
  (`find.bySemanticsLabel(...)` / `SemanticsFlag.isButton`) — durable and matches
  the project preference to verify flows with tests, not coordinate taps.
- **Manual screen-reader spot-checks**: VoiceOver (iOS sim) and TalkBack (Android
  emulator) on the primary flows; capture large-font screenshots via the
  `.devtools` scripts.
- `./scripts/check.sh` green (analyze + full suite) before each commit.

---

## Constraints & risks

- **File-size caps** per `AGENTS.md` (screen ≤ 80, widget ≤ 60, etc.) — adding
  `Semantics` wrappers can grow files; extract where a file would exceed its cap.
- **Localization churn:** new labels touch 5 ARB files + regenerate; keep keys
  minimal and reuse existing ones.
- **Theme rule:** never modify `AppColors.dark`; contrast fixes use existing
  tokens only.
- **Emulator-only screen-reader testing** is manual; the durable safety net is
  the widget tests asserting labels exist.

## Out of scope

Deep robustness rebuild, Settings visual density, widget families, multi-pair
charts, backend, accounts/hosting.
