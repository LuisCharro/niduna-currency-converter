---
name: small-screen-ui-review
description: Use when changing Flutter UI in this repo, especially new cards, charts, tabs, controls, or long screens. Keeps the app readable on the small Android emulator by preferring summary-first layouts, grouped controls, and collapsible secondary sections.
---

# Small Screen UI Review

Start with:

- `$HOME/SKILLS/mobile/mobile-ui-review.SKILL.md`

Use this local wrapper for repo-specific compact-screen rules and current product patterns.

## Trigger

Use it when changing:

- `home_screen.dart` or tab structure
- currency list layout
- charts
- cards (amount card, result card, pair card)
- bottom sheets
- settings screen
- any long list of currencies or options

## Repo-specific rules

- Design for the small Android emulator first.
- Show the primary action or summary before secondary detail.
- For currency list rows, prefer compact single-line over multi-line.
- Treat `Wrap` as suspicious unless it is guaranteed to stay visually compact on a small phone.
- Do not keep large section titles and intro paragraphs by default if the active tab already gives enough context.
- Prefer short labels and direct controls over explanatory copy.
- For 4+ currency options or longer labels, prefer a scrollable pill bar over forcing equal-width segments.
- Avoid repeating context the user already has from the app bar or active tab.
- Avoid card-inside-card layering unless the inner container creates a real interaction boundary.
- If a block is not a main action path, prefer collapse, segmentation, or a shorter summary with drill-down.
- Avoid stacking many peer cards when one workspace can hold the same content.
- Preserve current visual language and existing component patterns.
- For top-of-screen summary cards, treat vertical height as a hard budget.
- Prefer short status lines over explanatory paragraphs when the visual hierarchy already carries the meaning.

## Repo-specific review checklist

Before keeping a new block expanded by default, ask:

- Is this a primary action?
- Is this the main summary for the tab?
- Does this create avoidable scrolling on a compact phone?
- Is this summary now taller than it is informative?

Before keeping intro copy, ask:

- Does this text say something the active tab title does not already say?
- Would the screen still be understandable if the copy was removed?

## Completion

After the code change, verify on the running emulator when possible and call out any compact-screen tradeoff explicitly.
