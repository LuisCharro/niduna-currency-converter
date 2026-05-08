# Currency Converter

A privacy-first Flutter currency converter for the Niduna portfolio.

## Status

**Phase 1 — MVP** (planning)

## Features (Planned)

- 16 fiat currencies + BTC/ETH prices
- Multi-currency conversion view
- Historical charts (up to 2 years)
- Favorites (saved currency pairs)
- Offline mode with cached rates
- Dark mode
- Banner ads + Remove Ads IAP (1.99 CHF)

## Key Docs

- `DEFINITIONS.md` — product definition, competitive study, API strategy, pricing
- `PLAN.md` — development plan, navigation structure, TODO list
- `AGENTS.md` — agent instructions, skills, verification rules

## Getting Started

```bash
flutter pub get
flutter run
```

## Verification

```bash
./scripts/check.sh
```

## Smoke Test (iOS)

```bash
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/run_ios_minimal_smoke.sh
```
