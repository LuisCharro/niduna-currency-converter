# AdMob handoff — 2026-10-26

## Current answer

No blocking AdMob setup was found for serving ads in the current Android app.
The 26 October assessment was read-only. On 27 October the app-specific ad
content rating was changed as recorded below. Recheck the live account before
acting on this dated snapshot.

## Verified today

- [x] The [app overview](https://admob.google.com/v2/apps/2391849252/overview)
  shows **Ready** and recent requests, impressions and estimated earnings.
  The Apps list says **Ad serving enabled** for
  `com.honestfern.currency_converter`.
- [x] The existing Banner and Rewarded ad units are active. Their IDs match the
  production build's recorded configuration. No new ad unit is needed.
- [x] The [European regulations message](https://admob.google.com/v2/privacymessaging/gdpr)
  “Honest Fern Europe Consent” is **Published** for this app. The app source
  requests UMP consent and gates ad requests on `canRequestAds`.
- [x] AdMob's [app-ads.txt page](https://admob.google.com/v2/apps/appadstxt)
  says **Ready / file found and verified**, with 100% of recent queries
  authorised. The public file contains the expected publisher ID.
- [x] [Policy centre](https://admob.google.com/v2/policycenter/issues) says
  **No current issues**.

The overview's **Add rewarded interstitial** suggestion is an optional ad
format, not a setup requirement. Its automatic appearance would change the
current opt-in rewarded-ad experience; do not add it just to complete the
dashboard. Firebase linking for Ads ARPU reporting is also optional.

## Consent vs Data Safety (clarified 2026-10-27)

Users in EEA/UK/CH can refuse consent at first launch or later via Settings →
Data & privacy → Privacy options. Refusal switches AdMob to non-personalised /
limited ads, which still send IP-derived location, device info and ad events.
Consent changes how Google may *use* the data, not whether it leaves the
device, so Play Data Safety keeps declaring the AdMob SDK categories. Never
answer "no data collected". Outside Europe there is no prompt unless a US
state regulations message is configured.

## Follow-up, only when relevant

- [x] **Ad content rating:** on 2026-10-27, with Luis's approval, set the
  Currency Converter app-specific maximum to **General Audiences (G)** in
  AdMob. The app no longer matches the account-wide **Mature Audiences**
  setting; AdMob displayed PG, T and MA as blocked. Before saving, AdMob
  estimated a 49% impression and 56% revenue reduction for AdMob Network ads,
  based on the past 30 days, not a forecast. Recheck actual performance over
  time. This setting alone does not establish full policy compliance. See
  [Google's content rating requirements](https://support.google.com/googleplay/android-developer/answer/9859655?hl=en).
- [ ] **Focused real-device ad QA:** when next reviewing monetisation, check
  the Play-installed build on a real Android: European consent and Privacy
  options, banner after consent, an intentionally requested rewarded ad,
  no-ad/offline behavior, and Remove Ads entitlement. The code and automated
  tests cover these paths, but this session did not repeat that full device
  matrix after AdMob approval. Do not click your own live ads to test them.
- [ ] **Payments/identity when AdMob prompts:** on 2026-10-27, AdMob Home's
  “Steps to get paid” said identity verification becomes available after the
  earnings minimum is reached; **Verify identity** was disabled. The page did
  not state that minimum, and it is unknown whether the earlier Play developer
  identity verification will be reused. After identity verification, AdMob says
  it will mail an address PIN. Google's published CHF thresholds list address
  verification at the equivalent of US$10, payment-method selection at CHF 10,
  and payment at CHF 100; its general table lists a $0 identity threshold, so
  do not assume that figure overrides this account's displayed status. See
  [Google's payment thresholds](https://support.google.com/adsense/answer/1709871?hl=en-GB).
  Payout-method and tax status were not verified in this check. Earlier release
  records say the AdMob payment profile was completed on 2026-09-10. Revisit
  when AdMob enables the action or displays a request; verify the live details
  before entering identity, tax or bank information.
- [ ] **After a material SDK, audience, country or ad-format change:** revisit
  UMP messaging, Play Data Safety, the privacy copy and Policy centre. If the
  app expands to US states or iOS, review those regions' messaging and the
  iOS IDFA flow separately.

Google Play Production 1.0.1 (12) was published on 26 October at 15:55
(Console time), as verified on 27 October. Its release is separate from
AdMob's Ready status; see `RELEASE_CHECKLIST.md` and Play Console Submission 9.
