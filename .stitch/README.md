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

## Current Fiat-Only Convert Screen

Generated on 2026-05-08 after Phase 1 changed to fiat-only.

- Project: `4238726929092293442`
- Design system: `Monochrome Precision`
- Screen title: `Niduna Convert - Full Fiat List`
- Screen ID: `baa4c962fece45ab98a26e3024373726`
- Screenshot:
  `https://lh3.googleusercontent.com/aida/ADBb0uj55DVKd0dPk4Pt-NKvw1DMF2HjdIYRO-W5TGNNYC7hX9-0hhY2YU1NlKWGNmfYKCqMt772WZggu0mMeNik63Jn5x9AKz9TY-oE352XjAghU5b8UCjjC8UmsGaKfXmnHDl_re8w1s-QtGvOiatFHDYg2IWm3iHCi3iNJzHyjkS8jUqKN7Dl46ubl5U8xVpv3yuz42drybSLcusboWhpZNZMDyAtG2nPzf7xcMz3qHELLYScok4PlLwdP30`
- HTML export:
  `https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sX2EzYTZkODJkZjIwNzQyMWJiYjA5NTcwYzJkYTQyM2RjEgsSBxD9oceEigIYAZIBIwoKcHJvamVjdF9pZBIVQhM0MjM4NzI2OTI5MDkyMjkzNDQy&filename=&opi=96797242`

Verified content:

- USD appears as base currency in the amount card.
- Fiat result rows present: EUR, CHF, GBP, JPY, CAD, AUD, CNY, INR, MXN,
  BRL, TRY, KRW, SGD, HKD, NZD.
- No BTC, ETH, RUB, XAU, or XAG in the exported HTML.

Short visual assessment:

- Works: clean premium direction, practical row density, local-only header,
  complete fiat set, separated ad reserve, bottom navigation.
- Watch during Flutter translation: very tall full-list capture; implement as a
  native scrollable list rather than fixed-height content.

## Next Stitch Pass

Use this screen as the current Convert reference unless the user asks for
another visual iteration.

Required Convert output:

- mobile screen
- 16 fiat rows only
- no RUB
- no BTC/ETH
- no backend/account/subscription/transfer features
- bottom banner reserve separated from input and navigation
