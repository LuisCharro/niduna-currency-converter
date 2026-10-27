# Google Play recommendations — Android implementation plan

**Prepared:** 2026-10-27. **Status:** investigation and plan only; no app,
Play Console or release settings changed. **Baseline:** Production 1.0.1 (12),
Submission 9, published 26 October 2026 at 15:55 (Console time); 100% rollout
to the existing EU27 + Switzerland selection. Source commit `272e07d`; bundle
SHA-256 `da906b91c1b07609577c9c5b864ff1e323985ad588b4d98f8ccec7660bc5e127`.

**Goal:** investigate and address all four recommendations on the Production
dashboard without regressing phone usability, the chart viewer, consent, ads
or purchases. A recommendation is an observed Play signal, not proof of a
specific user-facing bug; establish a baseline before choosing code changes.

## Play Console inputs captured on 2026-10-27

Source: [Production dashboard](https://play.google.com/console/u/0/developers/6219086036817053258/app/4973875544480645622/tracks/production),
release **1.0.1 (12)**, with all four recommendations expanded.

1. **Edge-to-edge may not display for all users** — Android 15 enforces
   edge-to-edge for apps targeting API 35+. Google asks us to handle insets,
   test Android 15 and later, and points to `enableEdgeToEdge()` / Java
   `EdgeToEdge.enable()` as backward-compatible native options. Decide the
   Flutter-appropriate approach after testing; do not add a native call blindly.
   [Android 15 guidance](https://developer.android.com/about/versions/15/behavior-changes-15#edge-to-edge).
2. **Your app uses deprecated APIs or parameters for edge-to-edge** — Play
   lists `android.view.Window.setStatusBarColor`, `setNavigationBarColor`,
   `setNavigationBarDividerColor`, and
   `LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES`. It identifies obfuscated start
   locations `G1.r.a`, `N.c.m`, and `A2.a.w`. Google asks for migration away
   from these APIs or parameters. The same Android 15 guidance applies.
3. **Remove resizability and orientation restrictions in your app to support
   large screen devices** — Play identifies
   `<activity android:name="com.honestfern.currency_converter.MainActivity"
   android:screenOrientation="PORTRAIT" />`. Google asks us to remove the
   restriction and test multiple screen sizes and orientations on Android 16
   and earlier. [Android 16 large-screen guidance](https://developer.android.com/about/versions/16/behavior-changes-16#large-screens-form-factors).
4. **Improve your app's memory and performance with R8 optimisation** — Play
   identifies two items: **optimised resource shrinking is not enabled** and
   **upgrade Android Gradle plugin (AGP) to 9.0 or higher**. Google links to
   [code optimisation](https://developer.android.com/google/play/vitals/code-optimization).
   Treat size/performance improvements as hypotheses to measure, not guarantees.

## Baseline in this repo

- `pubspec.yaml` is `1.0.1+12`; the preserved bundle manifest says min SDK 24,
  target SDK 36 and portrait `MainActivity`. `android/app/src/main/AndroidManifest.xml`
  explicitly sets `android:screenOrientation="portrait"`.
- `android/settings.gradle.kts` pins AGP **8.11.1**, Kotlin **2.2.20**;
  `android/gradle/wrapper/gradle-wrapper.properties` uses Gradle **8.14**.
  Locally installed Flutter is **3.41.7**, Dart **3.11.5**. Recheck the
  candidate toolchain and lockfile before working. The release Gradle block
  does not explicitly set minify/shrink flags, but the build has a mapping;
  inspect the effective Flutter/Gradle release configuration before claiming
  either R8 or resource shrinking is disabled.
- `lib/src/app_shell.dart` applies `AppTheme.systemOverlayFor` through
  `AnnotatedRegion`; `lib/src/core/theme/app_theme.dart` supplies bar colours,
  divider colour, contrast and icon brightness. Flutter engine or plugins can
  translate these requests into platform calls. The app uses `SafeArea` and
  `MediaQuery` in several places, including `bottom_tab_frame.dart` and
  `floating_pill_nav.dart`; their presence alone does not prove every screen is
  safe around bars, cutouts, gestures or the keyboard.
- `lib/src/features/charts/presentation/chart_viewer_session.dart` requests
  landscape for the expanded chart and restores portrait after closing. Its
  lifecycle is covered by `test/chart_viewer_orientation_test.dart`. Removing
  the manifest lock alone could change the phone UX and still leave runtime
  orientation requests; preserve a usable chart if a device ignores rotation.
- The local `build/app/outputs/mapping/release/mapping.txt` contains entries
  corresponding to the three obfuscated names; `G1.r.a` includes inlined
  Flutter `PlatformPlugin.setSystemChromeSystemUIOverlayStyle`, while `N.c.m`
  and `A2.a.w` are synthetic methods. Its timestamp is near the build-12
  candidate, but this file is **not hash-bound to the uploaded AAB** in the
  receipt. Treat it as a diagnostic clue, not proof of ownership or that a
  particular plugin is responsible. Preserve and verify the exact mapping
  for the uploaded artifact before assigning each call site.
- Existing tests include `test/app_system_ui_test.dart`,
  `test/chart_viewer_orientation_test.dart`, chart viewer and large-text
  tests. `./scripts/check.sh` is the app's normal validation gate.

## Step 1 — Establish a visual and release baseline

**Files/evidence:** no source edits initially; `android/app/src/main/AndroidManifest.xml`,
`lib/src/app_shell.dart`, `lib/src/core/theme/app_theme.dart`, affected screens,
the preserved AAB/manifest and release mapping.

1. Record current Flutter, Gradle, AGP, Kotlin and plugin versions, release
   settings, bundle checksum, mapping provenance and baseline bundle/download
   sizes. Use a separate, clearly labelled test build with test ads; keep
   production signing and identifiers out of screenshots and logs.
2. Capture the current UI on Android 15/API 35 and Android 16/API 36, with
   gesture and three-button navigation, light/dark modes, display cutout,
   keyboard open, small phone and a large-screen tablet/foldable. Include all
   four tabs, sheets, snackbars, banner, expanded chart and Settings. Add a
   pre-15 Android device/API as a compatibility comparison. Record actual
   overlaps, missing controls and contrast failures; do not infer them solely
   from Play warnings.
3. Confirm chart open/close/back, rotation while a dialog is open, state after
   configuration changes, and free/paid layouts. Record each finding and
   whether a physical device or emulator was used.

**Accept:** baseline screenshots and a short issue matrix identify each actual
failure, relevant OS/navigation/size and any untested scenario. Google Play's
recommendations remain recorded even if a defect cannot be reproduced.

## Step 2 — Insets and system bars (recommendations 1 and 2)

**Likely files:** `lib/src/app_shell.dart`, `lib/src/core/theme/app_theme.dart`,
`lib/src/shared/widgets/bottom_tab_frame.dart`, `floating_pill_nav.dart`,
screen/sheet widgets, Android themes, and `test/app_system_ui_test.dart`.

1. Trace safe-area and keyboard insets per screen and overlays; apply insets
   once at the correct level. Preserve tap targets, floating navigation, ad
   shelves, snackbars and content scrolling. Test system bar icon contrast
   against actual light/dark backgrounds and both navigation modes.
2. Retrieve/verify the code-12 R8 mapping tied to the shipped AAB and retrace
   the three reported locations. Inspect Flutter embedding, AndroidX and
   plugin/dependency call sites. Check `SystemUiOverlayStyle` requests and
   theme parameters separately from calls made by bundled SDKs; record each
   confirmed owner and version. Do not edit generated SDK code or assign
   synthetic names to a plugin without evidence.
3. Choose the smallest compatible Flutter/Android change for confirmed
   app-owned calls and visual defects. Investigate a Flutter or plugin update
   where an upstream component owns a call; verify compatibility and changelog
   before upgrading. If no supported fix exists, document the upstream owner,
   version and residual warning instead of claiming it is resolved.
   Play's deprecated-API signal appears to come from analysing the bundle's
   code, so it can persist while the Flutter embedding still contains those
   calls, even if the app never triggers them; expect only a Flutter upgrade
   to clear it. A cheap app-side step: `AppTheme.systemOverlayFor` sets
   `systemNavigationBarColor` and `systemNavigationBarDividerColor`; leaving
   them `null` (transparent bars under edge-to-edge) stops the app requesting
   those calls at runtime — verify nav-bar contrast afterwards.
4. Add focused tests for discovered inset/contrast regressions and run visual
   checks against the Step 1 matrix. Flutter's
   [edge-to-edge migration](https://docs.flutter.dev/release/breaking-changes/default-systemuimode-edge-to-edge)
   and Android guidance are starting points; recheck current versions.

**Accept:** reachable content and readable system icons with no unintended
overlap in tested scenarios; report each deprecated call as removed, upstream
pending, or still unexplained, with evidence. Do not promise that Play clears
the signal until it analyses a later shipped release.

## Step 3 — Responsive orientation and resizing (recommendation 3)

**Likely files:** Android manifest, chart viewer session/screen, tab frames,
Convert, Favorites, Charts, Settings and `test/chart_viewer_orientation_test.dart`.

1. Establish the desired phone and large-screen behavior before removing the
   manifest lock. Android 16 with target SDK 36 ignores fixed orientation
   restrictions on qualifying screens of smallest width at least 600dp; test
   fold/unfold, tablet landscape, split-screen resizing and smaller windows.
2. Make layouts usable in portrait and landscape, bound overly wide content,
   keep controls scrollable and preserve input, saved currencies/favorites,
   navigation, dialogs and chart state across rotation/resizing. Ensure the
   expanded chart remains useful even when an orientation request is ignored.
3. Rework `ChartViewerSession` and its portrait restore only as needed for the
   agreed phone behavior. Test delayed and denied rotation, close/back,
   lifecycle, reopening, dialogs and rapid resizing. Avoid a temporary platform
   opt-out as the planned solution; document any unavoidable exception.
4. Remove the manifest restriction once the responsive behavior is ready;
   inspect the **merged release manifest**, not only the source manifest.

**Accept:** phone and large-screen scenarios work without clipped controls,
lost state or trapped chart navigation, with Android 16 and a pre-16 version
represented; merged manifest no longer declares the fixed portrait value.

## Step 4 — R8 and toolchain (recommendation 4)

**Likely files:** `android/settings.gradle.kts`, `android/gradle.properties`,
`android/gradle/wrapper/gradle-wrapper.properties`, `android/app/build.gradle.kts`,
Flutter/plugin dependencies and release build scripts.

1. Inspect effective release R8/minification/resource shrinking, merged keep
   rules and the output of the existing signed bundle build. Save the mapping,
   size, startup and memory measurements where available, and compare on the
   same device/configuration. Avoid claiming a real performance gain from size
   alone.
2. Evaluate the smallest supported route. Google documents opt-in optimised
   resource shrinking on AGP 8.12/8.13, with resource shrinking enabled, and
   default behaviour on AGP 9+ when shrinking is enabled. Current **8.11.1**
   is below that range: do not just add the flag and claim success.
   [R8 configuration](https://developer.android.com/topic/performance/app-optimization/enable-app-optimization).
3. Separately investigate the requested **AGP 9+** migration: compatible
   Flutter stable, Gradle, JDK, Kotlin and every Android plugin, including
   Google Mobile Ads/UMP, Billing, package info, review and home widget.
   Flutter's [built-in Kotlin migration guidance](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin)
   describes compatibility changes; local Flutter 3.41.7 predates the 3.44
   legacy-Kotlin compatibility described there. Recheck the current guidance
   at implementation time. Use an isolated candidate; upgrade neither Flutter
   nor AGP on the assumption that the other is compatible.
4. Compare AGP 8.12/8.13 as a possible incremental experiment against the
   AGP 9+ path. The intermediate route may address resource shrinking but
   **does not satisfy Google's separate AGP 9+ recommendation**. If the 9+
   migration is not safely compatible, document the blocker and defer it.
5. Build and exercise the **optimised release variant** with test ads and
   appropriate Billing test setup: startup, rates/offline, consent/privacy,
   banner, opt-in reward, all three purchase products, restore, review link,
   widget and both orientations. Check R8 keep rules, manifest, symbols and
   mapping; no actual purchase or live-ad click is required for this plan.

**Accept:** effective configuration and tool versions evidenced; release
bundle builds and passes smoke checks, mapping is retained, and before/after
size plus any performance measurements are recorded. Each of Google's two R8
items is explicitly resolved or left with a documented blocker and next step.

## Verification and later release

- Run `./scripts/check.sh` after implementation, plus targeted tests for the
  changed behavior and the device matrix above. Record failures and untested
  devices; do not label an emulator as a physical device.
- Run the repo's release preparation and verification workflow for a new,
  unused version code; preserve the signed AAB, upload certificate, hash,
  deobfuscation mapping, merged manifest and test evidence. Existing build 12
  stays the published baseline. Do not commit keys or private receipts.
- Install the candidate on Closed Alpha for Luis's real-device acceptance;
  only submit a later Production release when he separately asks. Do not change
  countries, prices, AdMob settings, store listing or website as part of this
  plan. Review the entire pending Play batch before any authorized submission.
- After publication, inspect Play's release-specific recommendations again.
  Automated warnings may persist or lag; record what Play reports and any
  remaining upstream dependency issue, rather than marking success early.

The site currently contains `softwareVersion: 1.0.0`; its separate pending
item calls for updating that metadata after publication verification. This
plan does not authorize a site deployment.
