---
name: product-scope-check
description: Use before broad feature work, navigation changes, or major UI expansion in this repo. Keeps work aligned with Phase 1 MVP scope, the tab roles, and the current preference for consolidation over uncontrolled feature growth.
---

# Product Scope Check

Start with:

- `$HOME/SKILLS/mobile/mobile-architecture-boundaries.SKILL.md`

Use this local wrapper for repo-specific product scope and tab-role constraints.

## Trigger

Use it when the request involves:

- a new tab
- a major change to Convert, Favorites, Charts, or Settings
- work that may overload a screen
- feature ideas inspired by other apps or repos
- anything that adds backend, accounts, or tracking

## Repo-specific scope rules

- This is Phase 1 MVP: free + banner ads + one-time Remove Ads
- No backend in Phase 1
- No accounts / no tracking / no analytics
- `Convert` stays conversion-oriented (multi-currency list)
- `Favorites` stays quick-access oriented (saved pairs)
- `Charts` stays visualization-oriented (historical rates)
- `Settings` stays configuration-oriented (IAP, preferences)

## Repo-specific decision check

Before implementing, ask:

- Does this belong in an existing tab instead of adding a new surface?
- Does it make a current screen too long or dense?
- Should an older section be merged, collapsed, or removed first?
- Is this still inside Phase 1 MVP scope?
- Does it require backend, accounts, or tracking? → defer to Phase 2/3

If a change fails those checks, prefer a smaller consolidation pass instead.

## Output expectations

When relevant, state the scope decision briefly:

- why the change fits
- or what was collapsed, merged, or deferred to keep the product coherent
