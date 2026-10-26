# AdMob handoff — 2026-10-26

## Current answer

No blocking AdMob setup was found for serving ads in the current Android app.
This is a read-only assessment; no AdMob setting was changed. Recheck the live
account before acting on this dated snapshot.

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

## Follow-up, only when relevant

- [ ] **Focused real-device ad QA:** when next reviewing monetisation, check
  the Play-installed build on a real Android: European consent and Privacy
  options, banner after consent, an intentionally requested rewarded ad,
  no-ad/offline behavior, and Remove Ads entitlement. The code and automated
  tests cover these paths, but this session did not repeat that full device
  matrix after AdMob approval. Do not click your own live ads to test them.
- [ ] **Payments/identity when AdMob prompts:** the Payments → Verification
  page says personal-information verification *may* be required once earnings
  reach its threshold. It did not display a current verification request. The
  Payments information pane remained loading today, so payout-method and tax
  status were **not verified** in this check. Earlier release records say the
  AdMob payment profile was completed on 2026-09-10; revisit the live pane
  when earnings grow or AdMob shows an action-required notice. Do not enter
  identity, tax or bank details on the basis of this note alone.
- [ ] **After a material SDK, audience, country or ad-format change:** revisit
  UMP messaging, Play Data Safety, the privacy copy and Policy centre. If the
  app expands to US states or iOS, review those regions' messaging and the
  iOS IDFA flow separately.

Google Play's pending Production 1.0.1 review is separate from AdMob's Ready
status; track it in `RELEASE_CHECKLIST.md` and Play Console Submission 9.
