# Play data deletion: decision and plan

Date: 2026-10-27. Status: decision taken with Luis. Website policy wording and
the email runbook (`niduna-site/docs/privacy-requests.md`) are in niduna-site
`85c39ee`, **deployed to the VPS on 2026-10-27** (another session verified
`/currency-converter/privacy/` and `/privacy/` match local files by SHA-256).
No Play Console change.

Remaining:

- [x] Deploy niduna-site and verify the live policies.
- [ ] Read-only Play Console check (below).
- [ ] Optional in-app line, only with the next app release.

## Decision (Luis, 2026-10-27)

**Keep the Play Data safety deletion answer as No.** We never claim a deletion
we cannot perform. The store keeps showing "Data can't be deleted"; that is the
accurate label for this app.

Reasoning:

- Honest Fern holds no user data: no backend, no accounts, no analytics. The
  only data Play counts as collected comes from the bundled AdMob SDK
  (approximate location, app interactions, diagnostics, device/other IDs).
- While data is declared as collected, the store always shows one of two lines:
  "Data can't be deleted" (No) or "You can request that data be deleted" (Yes).
  There is no option without a line, and it is the same in every country.
- A Yes needs a real way to delete on request. We have no way to delete a
  specific user's AdMob data: Google's AdMob deletion API covers specified
  first-party identifiers and explicitly not AdID, and partner forwarding
  depends on each buyer. A Yes would therefore overstate what we can do.
- What a user *can* do: clear local data (in-app "Clear saved data", Android
  app-data controls, uninstall), reset/delete the Android advertising ID, use the
  in-app Privacy options (consent), buy Remove Ads, and use Google's own
  controls for data Google holds.

Evidence level: based on Google's public documentation; no specific
confirmation has been requested from Google support. The answer stays No. If
moving to Yes is ever considered, first verify that there is a request
mechanism we can actually offer and stand behind.

Do not revisit to Yes unless something changes (a backend storing user data,
or Google providing a publisher-side deletion path that covers this app's data).

## What actually happens when someone emails a deletion request

There is nothing on Honest Fern's side to delete beyond the email thread itself.
The full runbook and reply template live in the site repo, because the
mailbox serves the whole portfolio: `niduna-site/docs/privacy-requests.md`.

## Changes

### Website (niduna-site) — done and deployed 2026-10-27

The deletion contradiction lives in
`currency-converter/privacy/index.html` ("Contact and rights" promises requests
to "delete" without saying what is possible). Keep the email contact — users
must be able to reach the controller — but describe honestly what a request
can achieve:

1. "Storage and your controls": add resetting/deleting the Android advertising
   ID and Google's controls for data Google holds.
2. "Contact and rights": say that Honest Fern stores no app data on servers, so
   a request is answered with how to delete local data and use Google's
   controls; we cannot delete data held by Google or ad partners; we delete our
   email correspondence on request.
3. Check the general policy (`privacy/index.html`, line ~122) still reads
   correctly next to the app policy (it covers the website and email; likely no
   change).
4. Update the page's "last updated" date. Deploy via the VPS script after
   Luis approves the push.

### App — none required

The in-app Data & privacy copy is already accurate (data stays on device,
Google serves ads, Clear saved data scope). **Optional**, only with the next
planned release (see linked plan below): one line on the Data & privacy page
pointing to the advertising-ID reset and the privacy policy. It must go into
all ARB locales. Not worth a release on its own.

### Play Console — no change expected, one read-only check

Nothing needs changing in Console: the deletion answer stays No, and the
privacy-policy URL (`https://honestfern.com/currency-converter/privacy/`) does
not change. Do one read-only check (no edits, nothing sent for review):

1. App content → Data safety: deletion question = **No**; the four AdMob data
   types and Advertising ID = Yes are unchanged; no pending unsent changes.
2. App content → Privacy policy: URL is the app-specific one above.
3. Public store listing → Data safety: shows "Data can't be deleted" and
   matches the Console answers.

Any mismatch: record it here and ask Luis before editing anything.

## Relation to other plans

- [Play Console recommendations](2026-10-27-play-console-recommendations-plan.md)
  is the next app release (in ~2 weeks, after observing 1.0.1). The optional
  in-app line above rides along with it; nothing here blocks or changes that
  plan.
- [Country expansion](2026-10-26-country-expansion-high-ecpm-plan.md): before
  US expansion, recheck this decision against US state privacy laws (right to
  delete) together with the required US state regulations consent message.

## Sources

- [Google Play Data safety guidance](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en-EN)
- [Google Play account deletion guidance](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en) (not applicable: no accounts)
- [Google Mobile Ads SDK data disclosure](https://developers.google.com/admob/android/privacy/play-data-disclosure?hl=en)
- [AdMob first-party data deletion](https://support.google.com/admob/answer/16687986?hl=en-GB)
- [App privacy policy](https://honestfern.com/currency-converter/privacy/)
- Prior Console review: `docs/release-prep/play-console-final-review-2026-10-20.md`.
