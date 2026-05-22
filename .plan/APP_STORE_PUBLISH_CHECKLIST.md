# Apple App Store Publishing Checklist

> Pre-submission checklist for Niduna Currency Converter on iOS.
> Updated: 2026-05-22
>
> **Current app version:** `0.1.0+1` (pre-MVP, must stay `0.x.x`)
> **Branch:** `turbo/ui-redesign`
> **Target:** Apple App Store (Google Play done separately)

---

## Status Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Done / Ready |
| 🔶 | Partially done / Needs review |
| ❌ | Not started / Blocking |
| ⏸️ | Deferred to post-MVP |
| 🔄 | In progress |

---

## 1. Apple Developer Program & Account Setup

| # | Task | Status | Notes |
|---|------|--------|-------|
| 1.1 | Apple Developer Program enrolled | ❌ | **$99/year** — [developer.apple.com/programs](https://developer.apple.com/programs/) |
| 1.2 | Apple ID with two-factor authentication enabled | ❌ | Required for all developer accounts |
| 1.3 | App Store Connect access confirmed | ❌ | Created automatically after program enrollment |
| 1.4 | Agreements signed in App Store Connect | ❌ | Paid Applications Agreement + iAd (if showing ads) |

**Cost note:** Unlike Google Play ($25 one-time), Apple charges **$99/year**. The program must remain active to keep apps on the store.

---

## 2. Code Signing & Certificates (BLOCKER)

| # | Task | Status | Current State |
|---|------|--------|---------------|
| 2.1 | Development certificate created | 🔶 | Xcode can auto-manage; verify in Keychain Access |
| 2.2 | Distribution certificate created | ❌ | **Required for App Store builds** (Apple Distribution type) |
| 2.3 | App ID registered in Apple Developer portal | 🔶 | Bundle ID `com.niduna.currencyConverter` must be registered as Explicit App ID |
| 2.4 | Provisioning profile created (App Store) | ❌ | Linked to distribution certificate + App ID |
| 2.5 | Code signing style set correctly | ✅ | Project uses `CODE_SIGN_STYLE = Automatic` — good for Xcode Cloud / GitHub Actions |
| 2.6 | Entitlements file configured (if needed) | 🔶 | Check if any capabilities require entitlements (Push Notifications, etc.) |

**Quick reference:**

```bash
# Verify signing setup
security find-identity -v -p codesigning

# List provisioning profiles
ls ~/Library/MobileDevice/Provisioning\ Profiles/
```

---

## 3. iOS Project Configuration

| # | Task | Status | Current State |
|---|------|--------|---------------|
| 3.1 | `CFBundleDisplayName` branded | ❌ | Currently `"Currency Converter"` — generic. Should be `"Niduna"` or `"Niduna Convert"` |
| 3.2 | `CFBundleName` branded | ❌ | Currently `"currency_converter"` — generic |
| 3.3 | Bundle Identifier correct | ✅ | `com.niduna.currencyConverter` — set and consistent |
| 3.4 | Deployment target meets Apple's current minimum | 🔶 | **Currently `IPHONEOS_DEPLOYMENT_TARGET = 13.0`** (iOS 13 / 2019 — very old). **Apple requires apps to target the currently shipping iOS version minus ~2 years.** As of 2026, this likely means iOS 16+ or 17+ minimum. Verify in App Store Connect > App Information what the current required minimum is before submitting. Update in Xcode or `ios/Podfile`. |
| 3.5 | Targeted device families appropriate | ✅ | iPhone + iPad (`"1,2"`) — good |
| 3.6 | Swift version current | ✅ | Swift 5.0 — managed by Flutter toolchain |
| 3.7 | Bitcode disabled (correct for modern Xcode) | ✅ | Default since Xcode 14+ |
| 3.8 | No deprecated API usage | 🔶 | Run static analyzer before final build |

---

## 4. Rate Data Provider Licensing (BLOCKER)

Same as Play Store — **shared blocker**.

| # | Task | Status | Notes |
|---|------|--------|-------|
| 4.1 | CoinPaprika replaced for production builds | ❌ | **Per `PROVIDER_LIMITS.md`: CoinPaprika ToS forbids commercial/App Store distribution** |
| 4.2 | Production provider selected and integrated | ❌ | Recommendation: fawazahmed0 (CC0 license) or similar free-for-commercial API |
| 4.3 | `release_safe` provider profile uses licensed source | ❌ | Current `release_safe` must not use CoinPaprika |
| 4.4 | Rate data attribution displayed if required by provider | ❌ | Check chosen provider's attribution requirements |
| 4.5 | Fallback behavior when rate API unavailable | ✅ | Cached rates + offline capability exists |

---

## 5. Privacy & Data Security (BLOCKER)

Apple's **Privacy Nutritional Label** is mandatory and shown prominently on the App Store page.

| # | Task | Status | Notes |
|---|------|--------|-------|
| 5.1 | Privacy policy page published (public URL) | ❌ | **Required.** Can be same URL as Play Store (GitHub Pages, etc.) |
| 5.2 | Privacy policy linked in-app (Settings screen) | ❌ | Add link/button in Settings |
| 5.3 | App Store Connect Privacy questionnaire completed | ❌ | Declares what data your app collects. Must match actual behavior exactly. |
| 5.4 | Custom `PrivacyInfo.xcprivacy` for app's own data practices | 🔶 | **Partial:** CocoaPods auto-includes `PrivacyInfo.xcprivacy` from `shared_preferences_foundation` + `package_info_plus` (covering their data practices). Should create app-level `PrivacyInfo.xcprivacy` if our own code collects any data beyond what pods declare. For Phase 1 (no analytics, no ads), pod manifests may suffice but custom one is safer. |
| 5.5 | Usage description for each permission | N/A | App currently requests zero permissions (no camera, location, photos, etc.) — clean |
| 5.6 | GDPR / CCPA compliance language in policy | ❌ | Include even if minimal data |

**Expected App Store Privacy answers (to verify):**
- Data used to track you? → **No**
- Data linked to you? → **No** (no accounts, no sign-in)
- Data NOT linked to you? → **App functionality** (currency codes selected, favorites stored locally)
- Financial info? → **No** (display only, no transactions)
- Location? → **No**
- Contact info? → **No**
- Health & fitness? → **No**
- Searches / browsing history? → **No**
- User content? → **No**
- Identifiers? → **No** (no analytics, no ad IDs)
- Diagnostics? → **Optional** (crash logs if Crashlytics added later)

**Key rules from Apple's Guidelines (verified 2026-05-22):**
- **Guideline 1.5**: Support URL must include easy way to contact you (required field in App Store Connect)
- **Guideline 1.6**: Apps must implement appropriate security measures for user information
- **Guideline 2.1(a)**: Submissions must be final versions — no placeholder text, empty websites, or temporary content
- **Guideline 2.3**: Metadata (screenshots, description, previews) must accurately reflect app's core experience
- **Guideline 2.3.3**: Screenshots must show the **app in use**, not just title art, login page, or splash screen
- **Guideline 2.3.7**: App names limited to **30 characters**; no trademarked terms or popular app names in keywords
- **Guideline 2.3.10**: No names/icons/imagery of other mobile platforms or alternative marketplaces in metadata
- **Guideline 2.4.1**: iPhone apps should run on iPad whenever possible (our app targets both `1,2` — good)
- **Guideline 2.5.1**: Apps may only use **public APIs** and must run on currently shipping OS
- **Guideline 2.5.2**: Apps must be self-contained; may not download/install code outside app bundle
- **Guideline 2.5.5**: Apps must work on **IPv6-only networks** (most HTTP libraries handle this transparently)
- **Guideline 2.5.18**: Display ads limited to main app binary (not extensions/widgets/notifications)
- **Guideline 3.1.1**: All digital goods/unlocks must use **In-App Purchase (StoreKit)** — no external payment links for iOS
- **Guideline 5.1.1(v)**: Apps that collect data must provide privacy policy URL accessible from app and App Store listing
- **Guideline 5.1.2**: You are responsible for third-party SDKs' data practices too
- Discrepancy between declared privacy and actual behavior = **rejection or removal**

**Apple's official pre-submission checklist** (from App Store Connect > "Get your app ready for submission"):
- [ ] Test your app thoroughly for crashes and bugs
- [ ] Ensure all app info and metadata is complete and accurate
- [ ] Update contact information so App Review can reach you
- [ ] Provide full access to App Review (demo account if needed; our app has none — state this)
- [ ] Enable backend services and make them live during review
- [ ] Include detailed explanations of non-obvious features in Review Notes
- [ ] Check that screenshots show the app **in use**, not splash/login/title art only
- [ ] Verify app follows Human Interface Guidelines
- [ ] Complete Privacy questionnaire accurately
- [ ] Complete Age Rating questionnaire honestly

---

## 6. Content Rating (Age Rating)

| # | Task | Status | Notes |
|---|------|--------|-------|
| 6.1 | Age rating questionnaire completed | ❌ | In App Store Connect > App Information > Rating |
| 6.2 | Expected rating: **4+** (Everyone) | 🔄 | Currency converter with no violence, no UGC, no gambling, no ads (yet) = Everyone 4+ |

---

## 7. Store Listing Assets (iOS Specific)

Apple has stricter screenshot requirements than Play Store.

| # | Task | Status | Specs |
|---|------|--------|-------|
| 7.1 | App icon (1024x1024 PNG) | 🔶 | Deployed to AppIcon.appiconset (16 sizes). **Must have NO alpha channel** — App Store will reject icons with transparency. Verify with `sips -g all` that icon has no alpha component. |
| 7.2 | iPhone screenshots (min 2, max 10) | ❌ | **6.7" display (1334x750)** or **6.5" display (1284x2778)**. JPEG/PNG. **Must show app in use** per Guideline 2.3.3 |
| 7.3 | iPad screenshots (if supporting iPad) | ❌ | **12.9" display (2048x2732)** if iPad support claimed |
| 7.4 | App preview video (optional) | ❌ | .M4V/.MP4, 15-30 seconds. Shows app interaction |
| 7.5 | Subtitle (max 30 chars) | ❌ | Shown under app name in search results |
| 7.6 | Promotional text (170 chars max) | ❌ | Editable anytime without review |
| 7.7 | Description (4000 chars max) | ❌ | Feature list, privacy notes, what makes Niduna different |
| 7.8 | Keywords (100 chars max) | ❌ | Comma-separated search terms. No trade names, no "free", no unrelated terms |
| 7.9 | Support URL | ❌ | **Required.** Web page where users can get help |
| 7.10 | Marketing URL (optional) | ❌ | Your website / landing page |
| 7.11 | Privacy Policy URL | ❌ | **Required.** Same as Play Store or separate |
| 7.12 | Category (Primary + Secondary) | ❌ | Primary: likely **Finance** > **Finance Tools**. Secondary: **Productivity** or **Utilities** |

**Screenshot plan (minimum 2):**
1. Convert tab — amount entry, currency picker, result display (showing real interaction)
2. Charts tab — historical chart with range selector (showing real interaction)

**Key difference from Play Store:** Apple reviewers **will reject** screenshots that show only the splash screen, login page, or title art. Every screenshot must demonstrate actual app functionality.

---

## 8. App Metadata

| # | Task | Status | Notes |
|---|------|--------|-------|
| 8.1 | App name (max 30 chars) | ❌ | Must be unique in App Store. Ideas: "Niduna Currency", "Niduna Convert" |
| 8.2 | Subtitle (max 30 chars) | ❌ | Example: "Offline-ready exchange rates" |
| 8.3 | Keywords (max 100 chars, comma-separated) | ❌ | Example: "currency,converter,exchange,rates,offline,forex,money" |
| 8.4 | Full description (4000 char max) | ❌ | Feature list, privacy-first positioning, what makes it different |
| 8.5 | What's New text drafted | ❌ | Required for every update. First submit: describe initial feature set |
| 8.6 | Copyright notice | ❌ | Format: `© 2026 Luis Charro` (or your legal entity) |
| 8.7 | Default language set (English) | ❌ | Add localizations later |
| 8.8 | Contact info in App Store Connect | ❌ | Name, email, phone (visible to users) |

---

## 9. Monetization Integration (Deferred)

These are NOT blockers for an initial free release without ads/IAP.

| # | Task | Status | Priority |
|---|------|--------|----------|
| 9.1 | AdMob SDK integrated (`google_mobile_ads`) | ⏸️ | Post-MVP |
| 9.2 | Banner ad units configured in AdMob console | ⏸️ | Post-MVP |
| 9.3 | SKAdNetwork identifiers added to Info.plist | ⏸️ | Post-MVP (required when showing ads on iOS) |
| 9.4 | Remove Ads IAP (StoreKit 2 / `in_app_purchase`) | ⏸️ | Post-MVP |
| 9.5 | IAP products configured in App Store Connect | ⏸️ | Post-MVP |
| 9.6 | App Review notes explaining IAP flow | ⏸️ | Post-MVP (required per Guideline 2.1(b)) |

**Important Apple-specific rule (Guideline 3.1.1):**
All digital content unlocks must use **In-App Purchase (StoreKit)**. You cannot link to external payment sites for premium features on iOS. This applies when you add "Remove Ads" later.

---

## 10. Quality & Testing

| # | Task | Status | Notes |
|---|------|--------|-------|
| 10.1 | Release build compiles cleanly (`flutter build ios --release`) | 🔶 | Works; needs code signing cert (see #2) |
| 10.2 | `./scripts/check.sh` passes (analyzer + tests) | ✅ | 122 tests pass, 0 issues |
| 10.3 | Tested on iPhone simulator (small + medium) | ✅ | Verified on both sizes |
| 10.4 | Tested on physical device (if available) | 🔶 | Recommended before submission — simulator ≠ device |
| 10.5 | Text scaling tested (1.3x+) | ✅ | Widget tests cover this |
| 10.6 | Dark mode tested | 🔶 | Theme exists; manual visual pass recommended |
| 10.7 | Offline behavior tested | 🔶 | Cached rates work; test full offline flow end-to-end |
| 10.8 | No crash-on-start | ✅ | Splash screen working on both platforms |
| 10.9 | IPv6 network compatibility verified | 🔶 | Most Flutter HTTP clients handle this; test on IPv6-only network |
| 10.10 | Accessibility basics (VoiceOver, Dynamic Type) | 🔶 | Run Accessibility Inspector (Xcode > Open Developer Tool > Accessibility Inspector) |
| 10.11 | Background/foreground lifecycle tested | 🔶 | Ensure app resumes cleanly after switching away |
| 10.12 | Low-memory warning handling | 🔶 | App should not crash under memory pressure |

---

## 11. Version Management

| # | Task | Status | Notes |
|---|------|--------|-------|
| 11.1 | `pubspec.yaml` version follows semver | ✅ | `0.1.0+1` — pre-MVP format correct |
| 11.2 | Build number increments on each release | ✅ | Auto-managed by Flutter from pubspec |
| 11.3 | Version matches across Play Store (when dual-publishing) | ✅ | Shared source of truth |
| 11.4 | Changelog / What's New drafted | ❌ | Required for every App Store update |

---

## 12. Security Checklist

| # | Task | Status | Notes |
|---|------|--------|-------|
| 12.1 | No hardcoded secrets in codebase | ✅ | `.env.local` gitignored, keys external |
| 12.2 | Debug flags disabled in release builds | ✅ | `APP_DEV_MODE=false` in release scripts |
| 12.3 | Dev-only provider not accessible in release | ✅ | `PROVIDER_PROFILE=release_safe` default |
| 12.4 | No log statements leaking sensitive data | 🔶 | Review `print()` / `debugPrint()` calls before final build |
| 12.5 | Network security (ATS) configured | ✅ | Default ATS blocks non-HTTPS; our APIs use HTTPS |
| 12.6 | No private / undocumented APIs used | ✅ | Flutter framework only, no native platform channels calling private APIs |
| 12.7 | App Transport Security not overridden | ✅ | No `NSAllowsArbitraryLoads` in Info.plist — good |

---

## 13. App Review Submission Process

This section covers the actual submission workflow once all blockers are resolved.

| # | Task | Status | Notes |
|---|------|--------|-------|
| 13.1 | Create app record in App Store Connect | ❌ | Platform: iOS, Primary Language: English |
| 13.2 | Fill all required metadata (name, category, rating, privacy) | ❌ | See sections 6, 7, 8 |
| 13.3 | Upload build via Xcode Archive or `xcodebuild` | ❌ | `flutter build ipa --release` then upload via Transporter or xcrun altool |
| 13.4 | Select build for review (Production track) | ❌ | Or use TestFlight first for internal testing |
| 13.5 | App Review notes written | ❌ | Explain: demo account (if any), how to test features, IAP test instructions |
| 13.6 | Demo account provided (if applicable) | N/A | No login required for this app — state this clearly in review notes |
| 13.7 | Exemption request filed (if needed) | N/A | Only if using encrypted storage, NFC, etc. |
| 13.8 | Submit for review | ❌ | Average review time: **24-48 hours**. Can be longer for first submission. |
| 13.9 | Respond to review feedback (if rejected) | ❌ | Common rejections: crashes, broken links, missing privacy policy, misleading metadata |

**Common rejection reasons to avoid:**
- Crashes on launch or during use (test thoroughly!)
- Broken links (support URL, privacy policy URL must resolve)
- Placeholder text or empty web pages
- Metadata doesn't match app functionality (don't overclaim)
- Missing or inaccurate privacy disclosures
- Using non-public APIs
- App is just a wrapper for a website (must have native functionality)

---

## 14. Post-Launch (Not needed for initial submission)

| # | Task | Status | Notes |
|---|------|--------|-------|
| 14.1 | Crash reporting (Crashlytics / Sentry) | ⏸️ | Post-MVP |
| 14.2 | Analytics (privacy-compliant or none) | ⏸️ | Per AGENTS.md: no tracking in Phase 1 |
| 14.3 | App Store Optimization (ASO) | ⏸️ | Keyword research, ratings strategy |
| 14.4 | Respond to App Store reviews | ⏸️ | Builds trust and ranking |
| 14.5 | Update cadence established | ⏸️ | Plan for rate data updates, bug fixes |
| 14.6 | TestFlight beta testing for major updates | ⏸️ | Recommended before each release |

---

## Blocker Summary (Must Fix Before Submission)

These items **must** be resolved before the app can be submitted to the App Store:

| # | Blocker | Effort |
|---|---------|--------|
| **1.1** | Apple Developer Program enrolled ($99/year) | External (~1 day for approval) |
| **2.2-2.4** | Distribution certificate + App ID + Provisioning profile | ~1 hour |
| **3.1-3.2** | Branded CFBundleDisplayName + CFBundleName | ~5 min |
| **3.4** | Deployment target updated (13.0 → 15.0+) | ~5 min |
| **4** | Replace CoinPaprika with licensed provider for `release_safe` | ~2-4 hours (shared with Play Store) |
| **5.1-5.4** | Privacy policy URL + in-app link + Privacy questionnaire + PrivacyInfo.xcprivacy manifest | ~1-2 hours |
| **6** | Age rating questionnaire | ~15 min |
| **7** | Store listing assets (screenshots, descriptions, keywords) | ~2-3 hours |
| **8** | App metadata (name, subtitle, keywords, description, URLs) | ~45 min |

**Estimated total effort for unblocked submission: ~1-2 days**

**Note:** Items **4** (provider replacement) and **5.1** (privacy policy) are shared blockers with Play Store — fix them once, benefit both stores.

---

## Deferred Items (Can Ship Without)

Items marked ⏸️ can be shipped in a future update:
- AdMob / ads integration (+ SKAdNetwork identifiers)
- Remove Ads IAP (StoreKit 2)
- Analytics / crash reporting
- iPad-specific screenshots (if not claiming iPad support initially)
- App preview video
- Translations beyond English
- TestFlight external testing setup

---

## Key Differences vs Google Play Store

| Aspect | Apple App Store | Google Play Store |
|--------|------------------|-------------------|
| **Cost** | $99/year | $25 one-time |
| **Review time** | 24-48 hrs (human review) | Hours to 1 day (automated + human) |
| **Build format** | IPA (from Xcode Archive) | AAB (Android App Bundle) |
| **Screenshots** | Must show **app in use** (Guideline 2.3.3) | More flexible |
| **Payment rules** | All digital goods via **StoreKit IAP** only | Google Play Billing (more flexible) |
| **Privacy label** | **Privacy Nutritional Label** (mandatory, visible) | Data Safety section (mandatory) |
| **Privacy manifest** | `PrivacyInfo.xcprivacy` file required in bundle | No equivalent |
| **Beta testing** | **TestFlight** (required for betas) | Internal / Closed / Open tracks |
| **Deployment target** | Must target recent iOS (within ~2 years) | Must target recent Android API level |
| **IPv6** | **Mandatory** (Guideline 2.5.5) | Recommended but not strictly enforced |
| **Public APIs** | **Only public APIs allowed** (Guideline 2.5.1) | Less strict enforcement |
| **Account required** | Yes ($99/yr) | Yes ($25 one-time) |
| **Developer verification** | Identity verification required | D&B check or government ID (2026+) |

---

## Related Skills & Docs

| Resource | Path | Purpose |
|----------|------|---------|
| Store release check (repo-local) | `.agent/skills/store-release-check/SKILL.md` | Privacy-first compliance gates |
| Store release check (shared) | `.agent-local/skills/release/store-release-check.SKILL.md` | 8-question release gate |
| Mobile release QA | `.agent-local/skills/release/mobile-release-qa.SKILL.md` | Pre-ship sanity pass |
| Store metadata review | `.agent-local/skills/release/store-metadata-review.SKILL.md` | Listing quality check |
| Privacy surface check | `.agent-local/skills/release/privacy-surface-check.SKILL.md` | Privacy disclosure audit |
| Store UI readiness | `.agent-local/skills/mobile/references/store-ui-readiness-checklist.md` | Touch targets, text scale |
| Small-screen UI review | `.agent/skills/small-screen-ui-review/SKILL.md` | Compact layout checks |
| Provider limits | `PROVIDER_LIMITS.md` | API licensing requirements |
| Build scripts | `scripts/build_apk.sh`, `scripts/build_appbundle.sh` | Release build commands |
| Firebase distribution | `scripts/firebase_app_distribution.sh` | Tester distribution workflow |
| Play Store checklist | `.plan/PLAY_STORE_PUBLISH_CHECKLIST.md` | Parallel Android checklist |
