# Data licensing and public disclosures — 2026-10-19 recheck

## Decision summary

Commercial use has positive published support: Frankfurter explicitly permits
its blended API commercially and caching; exchange-api publishes CC0. No
reviewed term forbids an ad-funded converter merely because it has ads or IAP.
This is evidence for the chosen model, not a complete legal clearance of every
upstream dataset, SDK, jurisdiction or the final store declarations.

Simplify the product copy. Preserve required privacy/advertising disclosures
and any applicable source attribution in an accessible second layer. More
technical prose does not establish legal compliance.

Scope: current app main `671c2d1`, uploaded code-8 source `e5df688`, website
release `a43d45a`; source review and official documents on this date. No new
binary, production release, privacy-policy deployment or Console declaration
was made for this review. Runtime collection was not measured with a network
capture, and live Data safety/AdMob vendor selections were not re-audited.

## 1. Actual data route and licensing evidence

| Item | Current evidence | Consequence |
| --- | --- | --- |
| Fiat | `features/convert/data/frankfurter_latest_rates_client.dart` and `core/rates/clients/frankfurter_client.dart` call `/v2/rates`; no provider filter | Default blended data; not an ECB-only feed |
| Crypto | `provider_config.dart` selects fawazahmed0 for release latest/history; factory constructs the CDN clients | No active CoinPaprika/CoinGecko release route in this configuration |
| Release guard | `app_dependencies.dart` invokes `ProviderConfig.validateReleaseMode()` | Non-safe build profile is rejected in release mode; the label `release_safe` is a configuration guard, not a legal certification |
| Conversion | Rates fetched by currency/date; arithmetic is on device | User's entered conversion amount is not sent in the examined rate requests |
| Cache | Latest and chart caches persist locally | Fits Frankfurter's published caching permission; CC0 permits reuse to the extent of the affirmer's rights |

Client paths in this section are relative to `lib/src/`; `provider_config.dart`
and the crypto clients are under `core/rates/`. `app_dependencies.dart` is at
`lib/src/app_dependencies.dart`.

### Frankfurter

- [Current FAQ](https://frankfurter.dev/#faq): commercial use and local caching
  of blended rates are expressly supported.
- [License and terms](https://frankfurter.dev/license/): current software is
  MIT; rates are third-party data with underlying provider terms. The old
  internal blanket description “Unlicense / public domain / no attribution”
  does not establish the current data rights.
- [Software MIT license](https://github.com/lineofflight/frankfurter/blob/main/LICENSE).
- Blended rates are calculated values and are not an official institution's
  own published rate. Keep an indicative-rate qualification. Do not describe
  all 34 fiat currencies as ECB-only or guarantee suitability for accounting.
- If switching to an individual provider/ECB route, review its own reuse and
  attribution conditions before changing the app. Current commercial FAQ is
  positive evidence for the actual blended route; it is not a waiver of every
  institution's rights or terms.

### exchange-api / fawazahmed0

- [Project](https://github.com/fawazahmed0/exchange-api) and
  [CC0 dedication](https://github.com/fawazahmed0/exchange-api/blob/main/LICENSE).
- [CC0 explanation](https://creativecommons.org/publicdomain/zero/1.0/) permits
  commercial copying/modification/distribution without attribution under the
  rights waived. Its scope does not erase another party's rights.
- [Upstream generation code](https://github.com/fawazahmed0/exchange-api/blob/main/currscript.js)
  obtains source URLs from environment variables or an unversioned `links.ini`.
  Crypto retrieval uses the `cryptoLink` source. This review could not verify
  the identity/redistribution rights of that upstream source from the public
  code and license. This is a provenance uncertainty, not evidence of an
  infringement or a ban on advertising.
- Before calling the entire data supply chain legally cleared, resolve that
  point through authoritative provider confirmation or qualified legal review;
  a provider change is a separate product decision. Do not infer an upstream
  provider from payload shape or a code comment and then present it as fact.

## 2. What users need, and where

The current implementation already follows part of this separation: provider
profile/flow/matrix cards are in the developer sandbox, not the release data
page. The public marketing page does not list the rate providers. Release help
has a short Frankfurter attribution and a generic crypto-source line. Avoid
redesigning the whole UI based on an assumption that debug tables ship to users.
The useful editorial targets are repetition, technical range-limit wording and
the overbroad privacy summary.

| Surface | Keep | Remove or shorten |
| --- | --- | --- |
| Convert/Charts | Data date; cached/stale state; daily/indicative nature | Repeated publication mechanics, provider-chain vocabulary |
| App data help | Short update/offline explanation; sources link; privacy link | Repeated fiat/crypto/cache paragraphs; “no-key providers” |
| Marketing/Play description | Features, supported scope, offline after loading, ads/IAP, concise accuracy caveat | API version, no-key/no-quota claims, CDN URLs, internal build profiles |
| Sources/credits | Provider names/links and applicable notices | Endpoint samples and developer troubleshooting |
| Privacy policy + UMP | Controller/contact; actual data and recipients; purpose, controls, retention and relevant transfers; consent choices | Source refresh schedules and conversion algorithms unrelated to privacy |
| Internal docs | Complete endpoints, dependencies, licenses, hashes, research links and uncertainties | Nothing merely to make public UI shorter |

A layered presentation must retain any prominent in-app disclosure required for
unexpected sensitive collection. UMP/consent cannot be replaced by a remote
privacy-policy link. A short Sources page does not resolve a missing license.

## 3. Concrete corrections before a public readiness claim

1. **App summary overstates local-only behavior.** `dataPrivacyLine` currently
   ends “Your data stays on this device.” Limit that to preferences, favorites
   and cached rates, and acknowledge external rate/ad services. The website's
   more qualified “no first-party analytics” distinction is preferable to
   “no tracking” or “no data collected” for the ad-supported app.
2. **Policy's advertising paragraph is too generic.** Name categories actually
   handled by Google Mobile Ads (network/IP-derived approximate location,
   identifiers, ad interactions, diagnostics as applicable). Describe choices
   and link provider information. NPA requests do not mean zero SDK data.
   Existing source has UMP gating and NPA requests; this is not an end-to-end
   verification of consent behavior or the installed SDK's exact traffic.
3. **Controller identity is indirect.** The general policy says the developer's
   name appears on store listings. Put the confirmed legal controller identity
   and working contact directly in the policies; do not guess the legal name,
   invent an entity, or publish an unapproved residential address.
4. **Transfers/retention need specific verified facts.** Existing policies give
   local deletion controls but leave third-party/website log retention and
   relevant overseas disclosures underdescribed. Establish actual hosting
   location, retention, recipients and transfer mechanisms; do not invent a
   universal “30 days” or “all data stays in Switzerland.”
5. **Distinguish SDK and app data in Data safety.** No GPS permission does not
   exclude IP-derived approximate location. Review the actual Console answers
   against the installed SDK/configuration before final submission.
6. **Correct overconfident internal provider claims.** Keep provenance limits
   visible so future sessions do not reapprove from an old green checklist.

Regulatory/policy anchors:
- [FDPIC duty to inform](https://www.edoeb.admin.ch/en/duty-to-provide-information):
  clear, accessible, proportionate information about controller, purposes,
  recipients and relevant overseas handling.
- [Google Play User Data policy](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en):
  SDKs count; policy/declarations must describe real handling and deletion.
- [Google Mobile Ads disclosure guide](https://developers.google.com/admob/android/privacy/play-data-disclosure):
  identify relevant SDK categories; its current version guide is not a network
  capture of our installed version.
- [Google EU user-consent policy](https://www.google.com/about/company/user-consent-policy/):
  applies to EEA/UK/Switzerland and requires appropriate disclosure/consent.
- [jsDelivr privacy](https://www.jsdelivr.com/terms/privacy-policy), inspected in
  a rendered browser because the text fetch showed a loading placeholder:
  CDN request metadata may be processed for service/security/statistics and
  non-aggregated information has a stated purpose-dependent retention policy.
  Do not assert that every rate provider keeps identical logs.

## 4. Competitor comparison — presentation only

[JRuston's product page](https://www.jrustonapps.com/apps/my-currency-converter)
and [App Store description](https://apps.apple.com/us/app/my-currency-converter-rates/id549019596)
focus on utility rather than identifying a rate supplier. Its Apple privacy
label separately declares advertising/tracking-related handling.
[Currency's App Store listing](https://apps.apple.com/ch/app/currency/id284220417?l=fr-FR)
also foregrounds conversion/offline features and has a separate privacy label.
These are developer declarations, not proof of equivalent licenses or laws.

The supplied JRuston app-specific privacy URL could not be retrieved; its
base policy loaded but describes paid iOS apps and is not a verified substitute
for that URL. Currency's HTTP/HTTPS website/privacy URLs could not be loaded.
No conclusion about absent disclosure was drawn from those failures.

## 5. Proposed concise copy (for review; not applied to runtime/public pages)

Daily-rate help:

> Indicative rates, updated daily. They are not live quotes. Your bank or
> payment provider may use a different rate and charge fees.

App data summary:

> Your preferences, favorites and saved rates are stored on your device.
> The app connects to rate services for updates and to Google for advertising.
> Read our privacy policy for details and your choices.

Sources row:

> Rate sources: Frankfurter and exchange-api (fawazahmed0).

Marketing short version:

> Convert 45 currencies, explore charts and keep favorites. Use saved rates
> offline. No account required. Optional one-time purchases unlock more features.

Retain the ad-supported/free-vs-paid explanation nearby. Keep source names in
accessible credits/privacy rather than repeating API details in marketing.
Translate approved copy consistently across all five app languages. Since
code 8 has already been uploaded, a changed binary needs the next unused code.

## How to avoid repeating the full audit without cause

Recheck when changing a provider/endpoint, SDK, personal-data flow, store
territory, consent implementation or the applicable terms. For copy-only
simplification, use this surface map and preserve the substantive notices.
Record source URLs, review date, artifact/source revision and open questions;
do not silently replace an unresolved item with “clean for publication.”

## Implementation preview after Luis's approval

The five app locales now qualify local data and external rate/ad requests,
shorten daily-update help, name sources without license assertions, and remove
API-key jargon from the crypto range limit. Main's copy differs from the
uploaded code-8 artifact; the review APK is local/test-ad only. Versioning for
Play follows the next unused code at release preparation.

Website drafts shorten the hero/chart/FAQ text, preserve accessible sources,
expand relevant AdMob/purchase handling and explain routine web-log retention
from read-only server evidence. Controller identity confirmation, hosting and
transfer specifics, actual Console declarations, and upstream crypto rights
remain separate unfinished audit items. The copy update does not resolve them.

### Brand-first strategy clarified by Luis

Luis reaffirmed the existing Pegolandia-style public-brand decision documented
in the portfolio master plan: Honest Fern on the website/app, real identity in
platform verification and required store information. This copy task preserves
that model. The controller-disclosure finding concerns applicable policy
requirements, not adding a personal name/address throughout marketing or
renaming the brand. The adequacy of the existing policy identification is
still a targeted legal question; the competitor's presentation is not proof
that a required disclosure can be omitted. Do not repeat the legal-name intake
as an ordinary branding prerequisite.

## Concise layered help — second approved editorial pass

Luis approved the shorter presentation and asked for another official-source
check without contacting providers. No messages were sent.

### Implementation and scope

- Local source is now `1.0.0+10`; code 9 remains the Play-distributed binary.
  The short Data & privacy page keeps cadence/offline and qualified external
  services wording, and links to an in-app Sources page, the policy and UMP
  privacy options when required. Direct policy/UMP controls in Settings remain.
- Source credits remain accessible offline in the app (Frankfurter and
  exchange-api by fawazahmed0); their project links open externally. No rates
  provider, SDK, permission, request payload or consent gate was changed.
- Chart history limits and mixed-chart weekend behavior moved to chart help,
  opened by tapping the Checked/date button in the chart header. Daily-rate
  accuracy/bank-fee qualification remains in the existing Convert info sheet.
- Five languages were updated. Website policies remove redundant summaries,
  duplicate controls and hypothetical future products. Source/recipient links,
  ad categories/purposes/choices, purchase handling, local deletion limits,
  retention/overseas information, controller/contact and rights are retained.
- Brand-first identification remains as previously directed. The earlier
  controller/transfer adequacy questions are not solved by shortening copy.
- Local test-ad preview APKs are for review, not Play artifacts. Preparing code
  10 does not upload it, promote to Production or deploy the website.

### Official-source check repeated on 2026-10-19

1. [Frankfurter FAQ](https://frankfurter.dev/#faq) expressly permits commercial
   use of blended rates and encourages local daily caching. The actual app
   route is the default `/v2/rates` without a provider filter. Advertising is
   an ordinary commercial use inference; no ad-specific prohibition was found.
2. [Frankfurter terms](https://frankfurter.dev/license/) separate MIT software
   from third-party data and say provider terms apply. Blended figures are
   Frankfurter's calculations, not an official bank's own rate. We found no
   explicit blanket requirement to display Frankfurter attribution on the
   normal converter screen; this does not prove no downstream notice applies.
3. [ECB copyright conditions](https://www.ecb.europa.eu/services/using-our-site/disclaimer/html/index.en.html)
   permit free use of information obtained directly from its site subject to
   accurate reproduction/source credit; sold documents and modified information
   have additional conditions. Do not describe these terms as unrestricted or
   equate our blended route to an ECB-only feed. Retain source links rather than
   deleting credits based on a competitor's interface.
4. [exchange-api CC0](https://github.com/fawazahmed0/exchange-api/blob/main/LICENSE)
   covers commercial/advertising uses of rights the affirmer can waive, but
   explicitly does not clear others' rights. The current public generator still
   reads `cryptoLink` from env or non-public `links.ini`:
   [currscript.js](https://github.com/fawazahmed0/exchange-api/blob/main/currscript.js).
   Upstream crypto identity and redistribution authorization remain unverified.

If Luis contacts exchange-api, the useful questions are: what source supplies
crypto observations, may those observations be cached and redistributed in an
Android app with ads and one-time IAP, and what source notices/attribution are
required? Ask Frankfurter only for any remaining blended downstream-credit
clarification; its commercial/caching FAQ already answers the basic usage point.
Do not send requests without Luis explicitly authorizing the recipient/message.
