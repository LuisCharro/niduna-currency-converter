# P4 — Real AdMob SDK Integration Plan

> **Status:** Deep reviewed, issues fixed, ready to implement
> **Prerequisite:** AdMob account + app registration (manual step)
> **Source:** Google official docs (quick-start, banner, rewarded) + current codebase audit
> **Review:** 2026-05-25 — first review found 9 issues; second deep review found 8 more (see Section 9)

---

## 1. Current State Audit

### What exists today

| File | Role | Lines | Notes |
|------|------|-------|-------|
| `lib/src/features/convert/widgets/ad_banner_placeholder.dart` | Visual placeholder widget | 49 | Static gray box with "Sponsored placement" text |
| `lib/src/features/convert/widgets/ad_support_shelf.dart` | Wraps placeholder in branded container | 26 | Used by Convert tab, Charts tab |
| `lib/src/core/monetization/rewarded_ad_service.dart` | Abstract interface | 1 method: `showRewardedAd({rewardType})` | Ready to implement |
| `lib/src/core/monetization/rewarded_ad_service_stub.dart` | Stub implementation | 22 | Simulates 3-phase flow (500ms load → 3s play → 500ms complete) |
| `lib/src/core/monetization/monetization_controller.dart` | Entitlement gate | 306 | Has `adsEnabled`, `canOfferRewardedChartUnlock`, `canOfferRewardedFavoritesBoost` getters |
| `lib/src/app.dart` | Wiring point | 239 | Line 132: `final adService = RewardedAdServiceStub();` — **swap target** |
| `lib/main.dart` | Entry point | 7 | No SDK init yet — **add MobileAds.instance.initialize()** |
| `android/app/src/main/AndroidManifest.xml` | Platform config | 45 | **No AdMob meta-data tag** |
| `pubspec.yaml` | Dependencies | 121 | **No google_mobile_ads package** |

### Where ads appear (4 surfaces)

```
Surface 1: Convert tab bottom
  ConvertScreen → [list content] → AdSupportShelf → AdBannerPlaceholder

Surface 2: Charts tab bottom
  ChartsScreen → [chart content] → AdSupportShelf → AdBannerPlaceholder

Surface 3: Chart currency picker sheet bottom
  ChartCurrencyPickerSheet → [picker list] → AdBannerPlaceholder (direct, no shelf)

Surface 4: Favorites tab bottom
  FavoritesScreen → [favorites content] → AdSupportShelf → AdBannerPlaceholder
```

### Entitlement logic that gates ads

```dart
// monetization_controller.dart:43-44
bool get adsEnabled =>
    !_hasActiveSubscription && !_hasRemoveAdsLifetime;

// monetization_controller.dart:51-54
bool get canOfferRewardedChartUnlock =>
    !_hasActiveSubscription &&
    !_hasRemoveAdsLifetime &&
    !_hasChartsProLifetime;

// monetization_controller.dart:56-59
bool get canOfferRewardedFavoritesBoost =>
    !_hasActiveSubscription &&
    !_hasRemoveAdsLifetime &&
    !_hasFavoritesProLifetime;
```

---

## 2. Prerequisites (Manual — You Do This)

### 2a. Create AdMob Account

1. Go to https://admob.google.com
2. Sign in with Google account
3. Accept terms

### 2b. Register the App

1. Click "Add app" → "Add your app manually"
2. Platform: **Android**
3. Package name: `com.niduna.currency_converter`
3. App name: `Niduna Currency Converter` (or your choice)
4. Note down the **App ID**: format `ca-app-pub-XXXXXXXX~YYYYYYYYYY`

### 2c. Create Ad Units

Create these in the AdMob dashboard under the registered app:

| # | Format | Name | Purpose | Test ID (dev only) |
|---|--------|------|---------|-------------------|
| 1 | Banner | `app_banner` | Bottom of Convert, Charts, Picker | Android: `ca-app-pub-3940256099942544/9214589741` / iOS: `ca-app-pub-3940256099942544/2435281174` |
| 2 | Rewarded | `chart_unlock_rewarded` | Chart pair temporary unlock | Android: `ca-app-pub-3940256099942544/5224354917` / iOS: `ca-app-pub-3940256099942544/1712485313` |
| 3 | Rewarded | `favorites_boost_rewarded` | Favorites slot boost (+3 pairs) | Same as above or separate unit |

> **Note:** You can use the same Rewarded ad unit ID for both chart unlock and favorites boost, or create separate ones for tracking. Using one is simpler.

### 2d. Save These Values

You'll need them for Step 5 below:

```
ADMOB_APP_ID=ca-app-pub-XXXXXXXX~YYYYYYYYYY
ADMOB_BANNER_AD_UNIT_ID=ca-app-pub-XXXXXXXX/ZZZZZZZZZ
ADMOB_REWARDED_AD_UNIT_ID=ca-app-pub-XXXXXXXX/WWWWWWWWW
```

---

## 3. Implementation Steps (In Order)

### Architecture rule for this slice

Keep all ad SDK logic out of screens/views.

| Layer | Owns | Must Not Own |
|-------|------|--------------|
| `lib/src/core/ads/` | AdMob IDs, SDK widgets, SDK services, fallback behavior | Feature-specific layout or product copy |
| `lib/src/core/monetization/` | Entitlement decisions: ads enabled, rewarded offers allowed, purchases | Google Mobile Ads SDK classes |
| Feature screens/widgets | Render `AdSupportShelf` or call existing monetization methods | `BannerAd`, `RewardedAd`, `AdRequest`, ad unit IDs |

Feature code should only decide **whether an ad surface is allowed** using `monetization.adsEnabled` or existing controller flags. It should not know how AdMob loads, fails, retries, or chooses test vs production IDs.

Target module shape:

```text
lib/src/core/ads/
├── ad_helper.dart                    # Test/production ad IDs + config checks
├── ad_banner_placeholder.dart        # Existing placeholder moved into ads module
├── ad_banner_widget.dart             # AdMob BannerAd lifecycle + fallback
└── admob_rewarded_ad_service.dart    # RewardedAd lifecycle behind RewardedAdService
```

The visual shelf can stay where it is for now (`features/convert/widgets/ad_support_shelf.dart`) because it is a reusable app UI wrapper already used by Convert, Charts, and Favorites. If it grows beyond a simple wrapper, move it later to `lib/src/shared/widgets/ad_support_shelf.dart`.

---

### No-account / no-config behavior

P4 can be implemented before the AdMob account exists.

Default behavior should be:

| Situation | Expected Behavior |
|-----------|-------------------|
| No AdMob account yet | App uses Google's official test App ID and test ad unit IDs automatically |
| No real ad unit IDs configured | App still runs because `ADMOB_USE_TEST_ADS` defaults to `true` |
| SDK/plugin unavailable in widget tests | `AdBannerWidget` catches the platform error and shows the existing placeholder |
| Runtime ad load fails in dev/test | Show the existing `AdBannerPlaceholder`, not a broken/blank UI |
| Production live ads requested but IDs missing | Fail fast instead of silently shipping placeholders |
| Production ad load fails with valid IDs | Hide/shrink the ad slot or show a neutral reserved space; do not show fake ads as production ads |

This preserves current UX while making the SDK integration safe to start before the AdMob console setup is complete.

---

### Ad surface sizing rules

The current placeholder layout has a nested-rectangle effect:

```text
BottomTabFrame footer space
└── AdSupportShelf full-width background / top border
    └── AdBannerPlaceholder rounded rectangle with horizontal margins
```

For real AdMob banners, avoid making the real ad look like a smaller ad inside a bigger ad box.

Use these rules:

| Component | Responsibility |
|-----------|----------------|
| `BottomTabFrame` | Reserves vertical space above the floating nav |
| `AdSupportShelf` | Provides app-level footer background, top border, safe spacing, and horizontal padding |
| `AdBannerWidget` | Measures the available shelf width, loads the adaptive banner, and centers the exact `AdWidget` size |
| `AdBannerPlaceholder` | Mirrors the real banner size/position for dev/test fallback only |

Implementation guidance:

- Do not give the placeholder its own external margin when it is already inside `AdSupportShelf`.
- Do not request the adaptive banner using full screen width if the shelf has horizontal padding.
- Use `LayoutBuilder` inside `AdBannerWidget` and request `AdSize.getLargeAnchoredAdaptiveBannerAdSize(constraints.maxWidth.floor())`.
- Center the returned `AdWidget` in a `SizedBox` matching `BannerAd.size`.
- Keep a small vertical shelf padding (`8px` top/bottom) so the banner does not touch the footer border or floating nav reserve.
- For dev/test fallback, make `AdBannerPlaceholder` the same requested width/height behavior as the real banner: centered, approx `320x50` minimum shape, no second oversized rounded card.
- For the chart picker bottom sheet, use the same `AdBannerWidget` sizing rules; do not duplicate custom margins in the sheet.

Target visual hierarchy:

```text
AdSupportShelf
└── Padding(horizontal: 16-24, vertical: 8)
    └── Center
        └── AdBannerWidget / AdBannerPlaceholder (exact banner-sized surface)
```

This keeps horizontal and vertical space predictable and prevents the real ad from appearing trapped inside a decorative placeholder container.

---

### Step 1: Add `google_mobile_ads` dependency

**File:** `pubspec.yaml`

**Action:** Add to `dependencies:` section:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # ... existing deps ...
  google_mobile_ads: ^8.0.0  # v8.0.0 latest (Dec 2025); requires Flutter 3.38.1+ ✓
```

**After:** Run `flutter pub get`

**Verification:** No version conflicts, package resolves.

---

### Step 2: Configure AndroidManifest.xml

**File:** `android/app/src/main/AndroidManifest.xml`

**Action:** Add `<meta-data>` tag inside `<application>`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="currency_converter"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- ADDED: AdMob App ID (Gradle injects test ID by default) -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="${admobApplicationId}"/>
        <!-- ... existing activity ... -->
        <meta-data android:name="flutterEmbedding" android:value="2" />
    </application>
    <!-- ... rest unchanged ... -->
</manifest>
```

**File:** `android/app/build.gradle.kts`

**Action:** Add a manifest placeholder in `defaultConfig`:

```kotlin
manifestPlaceholders["admobApplicationId"] =
    System.getenv("ADMOB_ANDROID_APP_ID")
        ?: "ca-app-pub-3940256099942544~3347511713"
```

**Important:** The Google test App ID is the default. Release builds pass the real App ID through the `ADMOB_ANDROID_APP_ID` environment variable.

**Why this crashes if missing:** Google docs say "Failure to do so results in a crash on app launch."

---

### Step 3: Configure iOS Info.plist

**File:** `ios/Runner/Info.plist`

**Action:** Add inside root `<dict>`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~3347511713</string>
```

**Note:** We use the Google test App ID directly. Replace with your real ID before iOS release.
iOS setup is for future use (App Store). Not blocking for Play Store first release but good to add now.
Before iOS release, also add the current Google AdMob `SKAdNetworkItems` list from the official docs.

---

### Step 4: Initialize SDK in main.dart

**File:** `lib/main.dart`

**Current code:**
```dart
import 'package:flutter/material.dart';
import 'src/app.dart';

void main() {
  runApp(const CurrencyConverterApp());
}
```

**New code:**
```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'src/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(MobileAds.instance.initialize());
  runApp(const CurrencyConverterApp());
}
```

**Key decisions:**
- `main()` stays synchronous; `unawaited` starts SDK init without delaying app startup
- `WidgetsFlutterBinding.ensureInitialized()` required before plugin init
- `MobileAds.instance.initialize()` returns a Future that completes when SDK is ready (or after 30s timeout per Google docs)
- Do **not** await initialization before `runApp`; otherwise a slow SDK init can hold a blank screen for up to 30 seconds
- Call as early as possible before any ad loading; the first ad load will wait internally if needed

---

### Step 5: Create AdHelper configuration class

**New file:** `lib/src/core/ads/ad_helper.dart`

**Purpose:** Centralize ad unit IDs with dev/prod switching. Never hardcode ad IDs in widgets.

**Important:** Do not use `kDebugMode` for deciding test ads. Profile builds and local release-style builds would use real ads, which is unsafe during QA. Use explicit Dart defines instead and default to test ads.

**Logic:**

```dart
import 'dart:io' show Platform;

class AdHelper {
  AdHelper._();

  static const bool _useTestAds = bool.fromEnvironment(
    'ADMOB_USE_TEST_ADS',
    defaultValue: true,
  );

  static bool get useTestAds => _useTestAds;

  static bool get showPlaceholderOnFailure => _useTestAds;

  // ─── Banner Ad Unit ──────────────────────────────────────
  // Used on: Convert tab, Charts tab, Chart picker sheet
  static const String _androidBannerAdUnitId = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_AD_UNIT_ID',
  );
  static const String _iosBannerAdUnitId = String.fromEnvironment(
    'ADMOB_IOS_BANNER_AD_UNIT_ID',
  );

  static String get bannerAdUnitId {
    if (_useTestAds) return _testBannerAdUnitId;
    final id = Platform.isAndroid ? _androidBannerAdUnitId : _iosBannerAdUnitId;
    if (id.isEmpty) throw StateError('Missing AdMob banner ad unit ID');
    return id;
  }

  static String get _testBannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/9214589741'
      : 'ca-app-pub-3940256099942544/2435281174';

  // ─── Rewarded Ad Unit ─────────────────────────────────────
  // Used for: chart pair unlock, favorites boost
  static const String _androidRewardedAdUnitId = String.fromEnvironment(
    'ADMOB_ANDROID_REWARDED_AD_UNIT_ID',
  );
  static const String _iosRewardedAdUnitId = String.fromEnvironment(
    'ADMOB_IOS_REWARDED_AD_UNIT_ID',
  );

  static String get rewardedAdUnitId {
    if (_useTestAds) return _testRewardedAdUnitId;
    final id = Platform.isAndroid
        ? _androidRewardedAdUnitId
        : _iosRewardedAdUnitId;
    if (id.isEmpty) throw StateError('Missing AdMob rewarded ad unit ID');
    return id;
  }

  static String get _testRewardedAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';
}
```

**Design notes:**
- Single source of truth for all ad unit IDs
- `ADMOB_USE_TEST_ADS` defaults to `true`, so debug, profile, and local release-style builds remain safe
- The app can be implemented before the AdMob account exists because test IDs are the default
- Missing production IDs fail fast only when `ADMOB_USE_TEST_ADS=false`
- Placeholder fallback is enabled only while `useTestAds == true`
- Test IDs are Google's official test units — they always return test ads, no risk of policy violation
- Real ad unit IDs come from `--dart-define` values at release time; no code change required
- Platform-aware test IDs (Android vs iOS have different test unit IDs)
- `Platform.isAndroid` used in non-const getter (NOT in const field — that would crash)
- App ID is NOT here — it lives in AndroidManifest.xml and Info.plist directly

---

### Step 6: Create AdBannerWidget (replaces AdBannerPlaceholder)

**New file:** `lib/src/core/ads/ad_banner_widget.dart`

**Move first:** Move the existing placeholder from
`lib/src/features/convert/widgets/ad_banner_placeholder.dart` to
`lib/src/core/ads/ad_banner_placeholder.dart`. This keeps fallback UI inside the ads module and avoids `core/ads` importing from a feature folder.

**Purpose:** A stateful widget that loads and displays a real AdMob banner ad. Falls back gracefully on failure.

**Logic:**

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_helper.dart';
import 'ad_banner_placeholder.dart';

/// Real AdMob banner ad widget.
///
/// Replaces [AdBannerPlaceholder]. Uses anchored adaptive banners
/// which optimize height per device width (aspect ratio ~320x50).
///
/// Lifecycle:
///   1. LayoutBuilder → read available width and load ad
///   2. Ad loads → setState → show AdWidget
///   3. Ad fails → placeholder in dev/test, shrink in production
///   4. dispose → dispose BannerAd
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  int? _loadedWidth;

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadBannerAd(int width) async {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;

    try {
      // v8.0.0: getLargeAnchoredAdaptiveBannerAdSize replaces deprecated
      // getCurrentOrientationAnchoredAdaptiveBannerAdSize.
      final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);

      if (!mounted || size == null) return;

      final ad = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        size: size,
        request: const AdRequest(nonPersonalizedAds: true),
        listener: BannerAdListener(
          onAdLoaded: (loadedAd) {
            if (!mounted || !identical(loadedAd, _bannerAd)) return;
            setState(() => _isLoaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('Banner ad failed to load: $error');
            ad.dispose();
            if (mounted && identical(ad, _bannerAd)) {
              setState(() {
                _bannerAd = null;
                _isLoaded = false;
              });
            }
          },
        ),
      );

      _bannerAd = ad;
      await ad.load();
    } catch (error) {
      // Keeps widget tests and unsupported environments from failing on
      // MissingPluginException or platform-channel setup errors.
      debugPrint('Banner ad skipped: $error');
      _bannerAd?.dispose();
      _bannerAd = null;
      if (mounted) setState(() => _isLoaded = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.floor();
        if (width > 0 && _loadedWidth != width) {
          _loadedWidth = width;
          unawaited(_loadBannerAd(width));
        }

        final ad = _bannerAd;
        if (!_isLoaded || ad == null) {
          return AdHelper.showPlaceholderOnFailure
              ? AdBannerPlaceholder(maxWidth: width.toDouble())
              : const SizedBox.shrink();
        }

        return Center(
          child: SizedBox(
            width: ad.size.width.toDouble(),
            height: ad.size.height.toDouble(),
            child: AdWidget(ad: ad),
          ),
        );
      },
    );
  }
}
```

**Key design decisions:**
- In dev/test mode, falls back to the existing `AdBannerPlaceholder` when the SDK is unavailable or no ad is loaded yet
- In production live-ad mode, returns `SizedBox.shrink()` on failure so the app does not display fake ads
- Uses **anchored adaptive banner** (`getLargeAnchoredAdaptiveBannerAdSize`) which is the v8.0.0 replacement for the deprecated current-orientation API
- Uses `LayoutBuilder`, not full screen `MediaQuery`, so the requested ad width matches the actual shelf/sheet width after padding
- Catches platform-channel errors so widget tests do not fail when the AdMob plugin is not registered
- Uses `AdRequest(nonPersonalizedAds: true)` by default to align with the app's privacy-first positioning until UMP consent is implemented
- Disposes properly in both `onAdFailedToLoad` callback and `dispose()`
- Handles edge case where ad size is null (very small screens)

---

### Step 7: Create AdMobRewardedAdService (implements RewardedAdService)

**New file:** `lib/src/core/ads/admob_rewarded_ad_service.dart`

**Purpose:** Real AdMob rewarded ad implementation. Replaces `RewardedAdServiceStub`.

**Interface it must satisfy:**
```dart
// rewarded_ad_service.dart (existing, DO NOT change)
abstract class RewardedAdService {
  Future<bool> showRewardedAd({required String rewardType});
}
```

**Logic:**

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../monetization/rewarded_ad_service.dart';
import 'ad_helper.dart';

/// Real AdMob rewarded ad service implementation.
///
/// Flow:
///   1. Load a RewardedAd
///   2. If loaded → show fullscreen
///   3. User watches → onUserEarnedReward marks reward as earned
///   4. Ad dismisses → return true only if reward was earned
///   5. User dismisses early / ad fails → return false
///
/// Each call creates a new ad instance (RewardedAd can only be shown once).
class AdMobRewardedAdService implements RewardedAdService {
  RewardedAd? _rewardedAd;
  Completer<bool>? _resultCompleter;
  bool _rewardEarned = false;

  @override
  Future<bool> showRewardedAd({required String rewardType}) {
    if (_resultCompleter != null) return false;

    _rewardEarned = false;
    _resultCompleter = Completer<bool>();

    unawaited(
      _loadAndShowAd(rewardType).catchError((Object error, StackTrace stack) {
        debugPrint('Rewarded ad error: $error');
        _completeResult(false);
      }),
    );

    return _resultCompleter!.future;
  }

  Future<void> _loadAndShowAd(String rewardType) async {
    try {
      _rewardedAd?.dispose();
      _rewardedAd = null;

      await RewardedAd.load(
        adUnitId: AdHelper.rewardedAdUnitId,
        request: const AdRequest(nonPersonalizedAds: true),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            debugPrint('Rewarded ad loaded for: $rewardType');
            _rewardedAd = ad;
            _setUpFullScreenCallbacks(ad);
            unawaited(_showAd(ad));
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('Rewarded ad failed to load: $error');
            _completeResult(false);
          },
        ),
      );
    } catch (error) {
      debugPrint('Rewarded ad failed before loading: $error');
      _completeResult(false);
    }
  }

  void _setUpFullScreenCallbacks(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Rewarded ad showed full screen');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Rewarded ad dismissed');
        ad.dispose();
        _rewardedAd = null;
        _completeResult(_rewardEarned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        _completeResult(false);
      },
      onAdImpression: (ad) {
        debugPrint('Rewarded ad impression recorded');
      },
    );
  }

  Future<void> _showAd(RewardedAd ad) async {
    try {
      await ad.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
          _rewardEarned = true;
        },
      );
    } catch (error) {
      debugPrint('Rewarded ad show threw: $error');
      ad.dispose();
      _rewardedAd = null;
      _completeResult(false);
    }
  }

  void _completeResult(bool success) {
    final completer = _resultCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(success);
    }
    _resultCompleter = null;
    _rewardEarned = false;
  }
}
```

**Key design decisions:**
- Uses `Completer<bool>` to bridge the callback-based AdMob API into the `Future<bool>` interface our existing code expects
- Guards against concurrent calls by keeping `_resultCompleter` non-null while an ad is active
- Disposes the ad in every exit path (dismiss, fail-to-show, fail-to-load)
- `onUserEarnedReward` marks reward eligibility; the service returns `true` only after the full-screen ad dismisses
- Early dismiss, failure, or any other outcome returns `false`
- `rewardType` parameter is logged but doesn't affect ad loading (same ad unit for both use cases)
- Uses `AdRequest(nonPersonalizedAds: true)` by default until a UMP consent flow is added

---

### Step 8: Update AdSupportShelf to use real banner

**File:** `lib/src/features/convert/widgets/ad_support_shelf.dart`

**Current code:**
```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'ad_banner_placeholder.dart';

class AdSupportShelf extends StatelessWidget {
  const AdSupportShelf({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.container,
        border: Border(top: BorderSide(color: colors.border.withValues(alpha: .14))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[const AdBannerPlaceholder()],
      ),
    );
  }
}
```

**New code:**
```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ads/ad_banner_widget.dart';

class AdSupportShelf extends StatelessWidget {
  const AdSupportShelf({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.container,
        border: Border(top: BorderSide(color: colors.border.withValues(alpha: .14))),
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: AdBannerWidget(),
      ),
    );
  }
}
```

**Changes:**
- Import changes from `ad_banner_placeholder.dart` → `../../../core/ads/ad_banner_widget.dart`
- Widget changes from `AdBannerPlaceholder()` → `AdBannerWidget()`
- Move horizontal/vertical spacing to `AdSupportShelf`; the banner widget measures the padded available width with `LayoutBuilder`
- Everything else stays identical (branded container, border, etc.)
- This updates Convert, Charts, and Favorites because all three tabs render the shared `AdSupportShelf`

---

### Step 9: Update ChartCurrencyPickerSheet banner

**File:** `lib/src/features/charts/widgets/chart_currency_picker_sheet.dart`

**Find this line (around line 166):**
```dart
const AdBannerPlaceholder(),
```

**Replace with:**
```dart
const AdBannerWidget(),
```

**Update import at top:**
```dart
// OLD:
import '../../convert/widgets/ad_banner_placeholder.dart';
// NEW:
import '../../../core/ads/ad_banner_widget.dart';
```

Also update any remaining placeholder imports to the moved module path:

```dart
import '../../../core/ads/ad_banner_placeholder.dart';
```

---

### Step 10: Wire real service in app.dart

**File:** `lib/src/app.dart`

**Change 1 — Import:**
```dart
// ADD:
import 'core/ads/admob_rewarded_ad_service.dart';

// REMOVE (no longer needed directly):
import 'core/monetization/rewarded_ad_service_stub.dart';
```

**Change 2 — Line 132, swap service instantiation:**
```dart
// OLD:
final adService = RewardedAdServiceStub();
// NEW:
final adService = AdMobRewardedAdService();
```

**Full context of the change area (lines 130-134):**
```dart
// BEFORE:
final ratesCache = SharedPreferencesRatesCache(prefs);
final adService = RewardedAdServiceStub();
_monetization = MonetizationController(prefs, adService: adService);

// AFTER:
final ratesCache = SharedPreferencesRatesCache(prefs);
final adService = AdMobRewardedAdService();
_monetization = MonetizationController(prefs, adService: adService);
```

**Why this works:** Both `RewardedAdServiceStub` and `AdMobRewardedAdService` implement `RewardedAdService`. The `MonetizationController` constructor accepts `RewardedAdService?` and uses duck-typing through the abstract interface. Zero changes needed in the controller or any UI layer.

---

### Step 11: Verify Remove Ads hiding banners (ALREADY DONE)

**Already implemented in the codebase — no changes needed!**

Both screens already gate `AdSupportShelf` with `adsEnabled`:

**ConvertScreen** (`convert_screen.dart:43`):
```dart
footer: monetization.adsEnabled ? const AdSupportShelf() : null,
```

**ChartsScreen** (`charts_screen.dart:46-48`):
```dart
footer: widget.monetization.adsEnabled
    ? const AdSupportShelf()
    : null,
```

**ChartCurrencyPickerSheet** (`chart_currency_picker_sheet.dart:165`):
```dart
if (widget.controller.adsEnabled) ...[
  const AdBannerPlaceholder(),  // ← will become AdBannerWidget in Step 9
  const SizedBox(height: 8),
],
```

**No additional work needed.** The `adsEnabled` → `null` footer pattern means the widget is never created when Remove Ads is active. This is already the cleanest approach.

---

### Step 12: Update tests

**File:** `test/widget_test.dart`

**Two references to update (lines 158 and 698):**

```dart
// OLD:
expect(find.byType(AdBannerPlaceholder), findsOneWidget);
// NEW:
expect(find.byType(AdBannerWidget), findsOneWidget);
```

**Update imports:**
```dart
// OLD:
// (import is implicit through other files — no direct import needed)
// NEW:
import 'package:currency_converter/src/core/ads/ad_banner_widget.dart';
```

**Important caveat:** `AdBannerWidget` loads asynchronously and returns `SizedBox.shrink()` until loaded. In test environment, the ad won't load (no AdMob SDK in tests), so:
- `find.byType(AdBannerWidget)` will still find the widget (it's in the tree, just not loaded)
- Platform-channel errors are caught inside `AdBannerWidget`, so widget tests should not fail with `MissingPluginException`
- Alternatively, test for `AdSupportShelf` instead (the parent container) when the test only cares that the ad slot exists

**Update the import for `AdBannerPlaceholder` if it exists as a direct import — remove it.**

---

### Step 13: Clean up old files

**After verification passes:**
- Delete `lib/src/features/convert/widgets/ad_banner_placeholder.dart` after moving its contents to `lib/src/core/ads/ad_banner_placeholder.dart`.
- Keep `lib/src/core/ads/ad_banner_placeholder.dart` as the dev/test fallback for missing SDK/config/ad-load failures.
- Keep `lib/src/core/monetization/rewarded_ad_service_stub.dart`. It is still useful for unit/widget tests and for `MonetizationController`'s default constructor fallback.

**Do not delete the stub unless you also change every test/controller path that depends on it.**

---

## 4. File Change Summary

| Action | File | What Changes |
|--------|------|-------------|
| **Modify** | `pubspec.yaml` | Add `google_mobile_ads: ^8.0.0` dependency |
| **Modify** | `android/app/src/main/AndroidManifest.xml` | Add AdMob APPLICATION_ID meta-data |
| **Modify** | `android/app/build.gradle.kts` | Add `admobApplicationId` manifest placeholder with test default |
| **Modify** | `ios/Runner/Info.plist` | Add GADApplicationIdentifier key |
| **Modify** | `lib/main.dart` | Add `MobileAds.instance.initialize()` |
| **CREATE** | `lib/src/core/ads/ad_helper.dart` | Ad ID config class (test vs real) |
| **MOVE** | `lib/src/features/convert/widgets/ad_banner_placeholder.dart` → `lib/src/core/ads/ad_banner_placeholder.dart` | Keep placeholder as ads-module fallback |
| **CREATE** | `lib/src/core/ads/ad_banner_widget.dart` | Real banner widget (stateful, adaptive) |
| **CREATE** | `lib/src/core/ads/admob_rewarded_ad_service.dart` | Real rewarded ad service |
| **Modify** | `lib/src/features/convert/widgets/ad_support_shelf.dart` | Swap placeholder → real banner |
| **Modify** | `lib/src/features/charts/widgets/chart_currency_picker_sheet.dart` | Swap placeholder → real banner |
| **Modify** | `lib/src/app.dart` | Swap stub service → real service |
| **Modify** | `test/widget_test.dart` | Update widget type references |
| **DELETE old path** | `lib/src/features/convert/widgets/ad_banner_placeholder.dart` | Removed after moving placeholder to `core/ads` |
| **KEEP** | `lib/src/core/monetization/rewarded_ad_service_stub.dart` | Required for tests/default fallback unless replaced explicitly |

**New directory structure:**
```
lib/src/core/ads/
├── ad_helper.dart                    # Ad unit ID config
├── ad_banner_widget.dart             # Banner ad widget
└── admob_rewarded_ad_service.dart    # Rewarded ad service
```

---

## 5. Verification Checklist

Run after each step, and definitely after completing all steps:

```bash
./scripts/check.sh
```

Expected: All tests pass, analyzer clean (no new warnings).

### Manual emulator verification:

```bash
# Launch with dev profile (has crypto providers)
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} \
  PROVIDER_PROFILE=dev_coinpaprika \
  APP_DEV_MODE=true \
  ./.devtools/run_ios_simulator_app.sh
```

**Check these scenarios:**

| # | Scenario | Expected Result |
|---|----------|----------------|
| 1 | Open Convert tab | Banner ad appears at bottom (test ad labeled "Google") |
| 2 | Open Charts tab | Banner ad appears at bottom |
| 3 | Open Favorites tab | Banner ad appears at bottom |
| 4 | Open pair picker in Charts | Banner ad appears at bottom of sheet |
| 5 | Scroll with banner | Banner stays fixed, doesn't jitter |
| 6 | Toggle Remove Ads in Dev Sandbox | All 4 ad surfaces disappear |
| 7 | Tap locked chart pair → Watch Ad | Fullscreen rewarded test ad plays |
| 8 | Complete rewarded ad | Pair unlocks (24h temp) |
| 9 | Dismiss rewarded ad early | No reward granted |
| 10 | Favorites tab → limit reached → Watch Ad | Fullscreen rewarded test ad plays |
| 11 | Network off → open app | No crash, banners just don't load (shrink) |

---

## 6. Pre-Release Switchover (Do This Last)

When ready to submit to Play Store:

1. **Pass native App IDs:**
   - Android: set `ADMOB_ANDROID_APP_ID=ca-app-pub-...~...` in the release build environment
   - iOS: replace the test App ID in `ios/Runner/Info.plist` before iOS release, or add an equivalent Xcode build setting later

2. **Pass production ad unit IDs with Dart defines:**
   ```bash
   ADMOB_ANDROID_APP_ID=ca-app-pub-...~... \
   flutter build appbundle \
     --dart-define=ADMOB_USE_TEST_ADS=false \
     --dart-define=ADMOB_ANDROID_BANNER_AD_UNIT_ID=ca-app-pub-.../... \
     --dart-define=ADMOB_ANDROID_REWARDED_AD_UNIT_ID=ca-app-pub-.../...
   ```

3. **Build release APK/App Bundle** (requires P6 keystore signing first):
   ```bash
   ./scripts/build_appbundle.sh
   ```

4. **Test on physical device** with release build — verify real ads load

5. **Verify in AdMob dashboard** that impressions register

6. **Update release scripts** so production ad defines are included only for release builds, not dev/emulator scripts.

---

## 7. Dependencies on Other P-Items

### Privacy and Consent Decision

AdMob changes the app's privacy surface. Before shipping live ads, do this review:

| Area | Required Decision |
|------|-------------------|
| Privacy policy | Disclose Google Mobile Ads, ad identifiers, approximate diagnostics, and third-party processing |
| Play Data Safety | Update the form for advertising ID / device identifiers as applicable |
| EEA / UK consent | Either add Google's UMP consent flow or keep requests non-personalized and document the limitation |
| App positioning | Reconfirm whether "zero tracking" still applies once live ads are enabled |

**Implementation default for P4:** Use `AdRequest(nonPersonalizedAds: true)` for banners and rewarded ads. This is not a full legal substitute for UMP where consent is required, but it keeps the first SDK integration aligned with the app's privacy-first direction while we decide whether to add UMP.

### Release Dependencies

| Depends On | Reason |
|------------|--------|
| **P6 — Keystore signing** | Release builds (which use real ad IDs) require signed APK/AAB |
| **P8 — Privacy policy** | AdMob requires privacy policy URL in app store listing |

**P4 can be developed independently** using test ad IDs. Only the final switchover to production IDs requires P6.

---

## 8. Risk Mitigations

| Risk | Mitigation |
|------|-----------|
| Account suspension from live ad clicks during dev | Test ads are default for all builds via `ADMOB_USE_TEST_ADS=true` |
| Banner doesn't fit small screen | Adaptive anchored banner handles sizing; fallback to `SizedBox.shrink` |
| Rewarded ad fails silently | `Completer` ensures Future always completes; UI shows "failed" state |
| SDK initialization timeout | Google's init has built-in 30s timeout; ads work even if init pending |
| Ad loading slow on first launch | Banner loads async; UI shows nothing until ready (no blocking) |
| Remove Ads buyers still see ads briefly | `adsEnabled` check prevents widget creation entirely |
| minSdk too low for AdMob | AdMob requires minSdk 21; Flutter default is already higher |

---

## 9. Review Results (2026-05-25)

First review found and fixed **9 issues** in the original plan:

| # | Issue | Severity | Fix Applied |
|---|-------|----------|-------------|
| 1 | **Wrong package version** — plan said `^5.3.0`, latest is `^8.0.0` (Dec 2025) | HIGH | Updated to `^8.0.0`. Requires Flutter 3.38.1+ (we have 3.41.7 ✓) |
| 2 | **Deprecated API** — `getCurrentOrientationAnchoredAdaptiveBannerAdSize` is deprecated in v8.0.0 | HIGH | Replaced with `getLargeAnchoredAdaptiveBannerAdSize` |
| 3 | **`Platform.isAndroid` in const context** — would crash at compile time. `const` fields can't call `Platform.isAndroid` | HIGH | Changed test IDs from `const` fields to non-const getters |
| 4 | **Gradle manifest placeholder `${ADMOB_APP_ID}`** — requires `build.gradle` manifestPlaceholders config that wasn't set up | MEDIUM | Added `admobApplicationId` manifest placeholder with test default and release env override |
| 5 | **`FullScreenContentCallback` wrong signature** — plan used `(_, __)` but callbacks take single `Ad` param (except `onAdFailedToShowFullScreenContent` which takes `(Ad, AdError)`) | HIGH | Fixed all callback signatures to match actual API |
| 6 | **Variable typo** — `rewardItem.amount` instead of `reward.amount` in `onUserEarnedReward` | MEDIUM | Fixed |
| 7 | **Step 11 was unnecessary** — `adsEnabled` gating already exists in `ConvertScreen`, `ChartsScreen`, and `ChartCurrencyPickerSheet` | LOW | Updated Step 11 to "verify only" — no code changes needed |
| 8 | **Missing `dart:async` import** — `Completer<bool>` requires it | MEDIUM | Added `import 'dart:async';` |
| 9 | **Unused `dart:io` import** in `ad_banner_widget.dart` — was imported but not used | LOW | Removed |

Second deep review found and fixed **9 more issues**:

| # | Issue | Severity | Fix Applied |
|---|-------|----------|-------------|
| 10 | **Startup delay risk** — awaiting `MobileAds.instance.initialize()` could hold a blank screen for up to 30s | HIGH | Use `unawaited(MobileAds.instance.initialize())` before `runApp` |
| 11 | **Unsafe test/prod switching** — `kDebugMode` would use real ads in profile/local release QA | HIGH | Default to test ads via `ADMOB_USE_TEST_ADS=true`; production IDs require explicit Dart defines |
| 12 | **Wrong banner width source** — using screen `MediaQuery` ignores shelf/sheet padding and can request a banner wider than the actual slot | HIGH | Use `LayoutBuilder` and reload only when available width changes |
| 13 | **Widget tests would hit platform channels** — real ad size/load calls can throw `MissingPluginException` | HIGH | Catch platform-channel errors inside `AdBannerWidget` and shrink gracefully |
| 14 | **Rewarded service lifecycle bug** — service could mark itself idle before the full-screen ad completed | HIGH | Keep `_resultCompleter` active until dismiss/failure and complete after dismissal |
| 15 | **Reward granted too early** — returning true directly from `onUserEarnedReward` can unlock before the ad dismisses | MEDIUM | Track `_rewardEarned`, return success only from `onAdDismissedFullScreenContent` |
| 16 | **Wrong release switchover** — plan still referenced `_realAppId` after removing it from `AdHelper` | MEDIUM | Use `ADMOB_ANDROID_APP_ID` for Android native App ID, update iOS plist before iOS release, and pass ad unit IDs with Dart defines |
| 17 | **Stub deletion would break tests/default controller path** | MEDIUM | Keep `RewardedAdServiceStub`; move the visual placeholder into `core/ads` and keep it as dev/test fallback |
| 18 | **Ignored rewarded `show()` Future** — show failures could become unhandled async errors | HIGH | Await `ad.show()` inside `_showAd`, call it with `unawaited`, and complete failure on thrown errors |
