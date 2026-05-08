# Stitch Notes

Stitch artifacts in this folder are design references, not product truth.

Product truth lives in:

- `../DEFINITIONS.md`
- `../ROADMAP.md`
- `../PLAN.md`

## Current Scope

Phase 1 is fiat-only.

Do not carry these into new Stitch screens:

- BTC
- ETH
- crypto rows
- CoinGecko/API-key assumptions
- metals
- backend/subscription features
- account or transfer flows

## Existing Artifact

`fidelity/convert-canonical-pro-v2/` was generated before crypto was removed
from Phase 1. Treat it as visual reference only.

Useful parts:

- premium monochrome direction
- density
- local-only/privacy header
- input/list/ad spacing structure

Obsolete parts:

- BTC row
- ETH row
- any crypto-specific rates or symbols

## Current Phase 1 Screen Set

Generated on 2026-05-08 after Phase 1 changed to fiat-only.

- Project: `4238726929092293442`
- Design system: `Monochrome Precision`

Use these as design references for the native Flutter implementation. They are
not product truth; `../DEFINITIONS.md` and `../ROADMAP.md` still decide scope.

| Tab | Screen title | Screen ID | Notes |
|-----|--------------|-----------|-------|
| Convert | `Niduna Convert - Full Fiat List` | `baa4c962fece45ab98a26e3024373726` | Canonical fiat-only conversion surface. |
| Favorites | `Niduna Favorites - Phase 1` | `fe9aeb0fb76b4cf6b0d2e072022d127c` | Corrected brand copy; max-3 local pairs. |
| Charts | `Niduna Charts - Phase 1` | `8ebbace0af0840698e8a11151f29a19b` | Corrected brand copy; fiat-only chart state. |
| Settings | `Niduna Settings - Phase 1` | `0cdd1d447adb4387983172222476b7bb` | Preferences, cache, Remove Ads, privacy/about. |

### Convert Artifacts

- Screenshot: `https://lh3.googleusercontent.com/aida/ADBb0uj55DVKd0dPk4Pt-NKvw1DMF2HjdIYRO-W5TGNNYC7hX9-0hhY2YU1NlKWGNmfYKCqMt772WZggu0mMeNik63Jn5x9AKz9TY-oE352XjAghU5b8UCjjC8UmsGaKfXmnHDl_re8w1s-QtGvOiatFHDYg2IWm3iHCi3iNJzHyjkS8jUqKN7Dl46ubl5U8xVpv3yuz42drybSLcusboWhpZNZMDyAtG2nPzf7xcMz3qHELLYScok4PlLwdP30`
- HTML export: `https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sX2EzYTZkODJkZjIwNzQyMWJiYjA5NTcwYzJkYTQyM2RjEgsSBxD9oceEigIYAZIBIwoKcHJvamVjdF9pZBIVQhM0MjM4NzI2OTI5MDkyMjkzNDQy&filename=&opi=96797242`

### Favorites Artifacts

- Screenshot: `https://lh3.googleusercontent.com/aida/ADBb0ui6PCsbwmbu4T-hDu0t1rqfsnX7Na_20LUA0agZ_FyiKQHypm-Isy0SYvHqTmOnjbwApcuvVH-GOnjy-zj_DTOhHj-Eww0N6OGRDGV6JLjaO9hIoobUgp9QAGJ6R186TfXasAjmyPs37JfcrAIqa4tdYKHI1dMdfBVeIZrwSs2JlXyRSXlZzlmFwi5Js4Zn5Ymt9n2KUMZAb2auw8ZLsxx5v3AR695YHydrklT9i0RxVy1EWPv3ncpmAVo`
- HTML export: `https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sXzdmMmE5NDNmYzRjZTQ4MTBiNzI4YjI1OTkzMWEyMjc4EgsSBxD9oceEigIYAZIBIwoKcHJvamVjdF9pZBIVQhM0MjM4NzI2OTI5MDkyMjkzNDQy&filename=&opi=96797242`

### Charts Artifacts

- Screenshot: `https://lh3.googleusercontent.com/aida/ADBb0uiINtugeJIKisO9Tp9oAvpr2Dd11yiG2n-UnOQ7s-NAWcRvKHKQri7jb_znh4hRE3En1DuaoJv8o52j_HUFvfQz__EfiN77rQ8zbSvyYtebNUsgHBTWdmbrEUoS-w59JkSvStQ-mxWLcbIrZJ5kZ6wGb-t8MAspRr483KHj_2rNuTOzjHn1qTvG-iFMoMREh2V06pblHImgJWRGC5ouFA9hoLcqL77SxPUHpPhLiav4j_PQ7r_2Gvtmn58`
- HTML export: `https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sXzNjYTJkODE5OWI1ZTRhYTRhNzJlYTllMjFhZDI1N2JjEgsSBxD9oceEigIYAZIBIwoKcHJvamVjdF9pZBIVQhM0MjM4NzI2OTI5MDkyMjkzNDQy&filename=&opi=96797242`

### Settings Artifacts

- Screenshot: `https://lh3.googleusercontent.com/aida/ADBb0uhGMGwe1D4HCK71JWT-RvzRQjZFgXnGUOncUWwaX5ww-EF7idpZ6TOlnVjX8TmZWtQwEiQwl-nu1CPVXCuOWZN-WFkwLmEciRto_wo-5gx4yhCeJNOeQ5fh3RXLAYBcU9IrfJVK9FZun-3k0LawbEjhbfLZOxgboz-Km4iR-XhB2GUcQrXNdOmBtAnYwBHoOgKHl9WjdmB6_XxoPT2mpI74bsC1mCVeyCNCh2h2VjmpX2_T5fCyFuhWHMA`
- HTML export: `https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sX2FjNjVkY2JmNmQxMjRkMDZiYjQ2NjU1NTJlNmI1NWFmEgsSBxD9oceEigIYAZIBIwoKcHJvamVjdF9pZBIVQhM0MjM4NzI2OTI5MDkyMjkzNDQy&filename=&opi=96797242`

Verified content:

- USD appears as base currency in the amount card.
- Fiat result rows present: EUR, CHF, GBP, JPY, CAD, AUD, CNY, INR, MXN,
  BRL, TRY, KRW, SGD, HKD, NZD.
- No BTC, ETH, RUB, XAU, or XAG in the exported HTML.

Short visual assessment:

- Works: clean premium direction, practical row density, local-only header,
  complete fiat set, coherent sibling tabs, separated ad reserve, bottom
  navigation.
- Watch during Flutter translation: very tall full-list capture; implement as a
  native scrollable list rather than fixed-height content. Keep Stitch exports
  as hierarchy/token references, not 1:1 HTML/CSS ports.

## Next Flutter Pass

Use the four-screen set as the current design reference unless the user asks for
another visual iteration.

Implementation guardrails:

- Translate to native Flutter widgets.
- Preserve the existing four-tab shell.
- Implement by vertical slices.
- Start with Convert + Frankfurter latest rates + local cache.
- Do not copy Stitch HTML/CSS 1:1.
- Do not add RUB, BTC, ETH, metals, accounts, backend, subscriptions, transfers,
  or cloud sync.
