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

## Next Stitch Pass

Regenerate or edit `Convert` against the Phase 1 Screen Matrix in
`../ROADMAP.md`.

Required Convert output:

- mobile screen
- 16 fiat rows only
- no RUB
- no BTC/ETH
- no backend/account/subscription/transfer features
- bottom banner reserve separated from input and navigation
