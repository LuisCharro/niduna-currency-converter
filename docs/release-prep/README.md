# release-prep branch artifacts

This directory holds work-in-progress / disabled-state files that
supported the `release-prep` branch but were not part of the active
source tree at the time the release-prep work landed.

## Home-screen widget history (Android + iOS)

The project has two home-screen widget implementations. Both are
"code complete" but only the Android one is shipped in main right
now. The iOS one is in main but disabled (see "Current state" below).

### Android widget — shipped (working)

**Path:** `android/app/src/main/java/com/niduna/currency_converter/widget/NidunaAppWidgetProvider.kt`
**Approach:** `AppWidgetProvider` + `RemoteViews`. No Glance, no Compose.
**Status:** ✅ Built, end-to-end verified on Android 16 emulator.
Data bridge (Dart → SharedPreferences) confirmed working.

The widget is **disabled by default** in this commit:
- `AndroidManifest.xml` does not have the `<receiver>` block
- The Kotlin file is in the source tree but not wired to a receiver

To enable: re-add the `<receiver>` block to `AndroidManifest.xml`
(remove the comment marker, paste the receiver declaration back in
from the `feature/widget-restore` commit `55d7839`). The Kotlin
file is buildable as-is.

### iOS widget — code complete, sim install blocked

**Path:** `ios/Runner/Widgets/NidunaWidget/NidunaWidget.swift`
**Approach:** `WidgetBundle` + `TimelineProvider` + `UserDefaults(suiteName:)`
for the App Group data bridge. Modern iOS 17+ WidgetKit conventions.
**Status:** ⚠️ Code complete and reviewed. The Xcode project has
the `NidunaWidget` target wired up. The `Embed App Extensions` build
phase is **disabled by default in main** so the iOS sim can install
the app. Re-enable for real-device testing.

Why disabled: `xcrun simctl install` on iOS 26 / Xcode 26 fails with
`Invalid placeholder attributes` for any widget extension. This is a
known simctl bug, not a code issue. On a real iPhone via Xcode's
"Run" button, the widget installs and runs.

### Why Glance isn't used (Android)

We tried the Glance path first (it's what `home_widget 0.9.2`'s
upstream example uses). It failed: Glance's API depends on inline
reified functions in the Compose runtime (`currentState<T>()`,
`LocalState.current`). The Kotlin 2.2.20 back-end emits an internal
compiler error ("Couldn't inline method call") on those signatures.
Any Glance-based widget fails to compile in this project.

**To revisit Glance later:** pin Kotlin to <=2.1.x in
`android/settings.gradle.kts` and re-add
`implementation("androidx.glance:glance-appwidget:1.1.1")` to
`android/app/build.gradle.kts`. Then write the Glance-based widget
following the home_widget 0.9.2 example pattern.

### To re-enable the iOS widget target

The default state in `main` has the `NidunaWidget` target in the
Xcode project but the embed phase removed (so the sim app installs
without the widget). To re-enable for real-device testing:

```bash
# Add the embed phase back
cd ios && GEM_HOME=/opt/homebrew/Cellar/cocoapods/1.16.2_2/libexec \
    ruby -e "
    require 'xcodeproj'
    project = Xcodeproj::Project.open('Runner.xcodeproj')
    runner = project.targets.find { |t| t.name == 'Runner' }
    embed = runner.new_copy_files_build_phase('Embed App Extensions')
    embed.symbol_dst_subfolder_spec = :plug_ins
    embed.run_only_for_deployment_postprocessing = '0'
    widget_product = project.targets.find { |t| t.name == 'NidunaWidget' }.product_reference
    build_file = embed.add_file_reference(widget_product)
    build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
    # Move the phase to after PBXResourcesBuildPhase to break Flutter's Thin Binary cycle
    phases = runner.build_phases
    resources_idx = phases.index(phases.find { |p| p.is_a?(Xcodeproj::Project::Object::PBXResourcesBuildPhase) })
    phases.delete(embed)
    phases.insert(resources_idx + 1, embed)
    project.save
    "
```

Or use the `ios/scripts/add_widget_target.rb` script which is
idempotent and recreates the full setup (run with
`GEM_HOME=/opt/homebrew/Cellar/cocoapods/1.16.2_2/libexec ruby
ios/scripts/add_widget_target.rb`).

## Captured screenshots

`docs/release-prep/screenshots/` contains the 8 UI polish shots
(4 tabs × light/dark) captured via the `idb` smoke test workflow
documented in `docs/RELEASE_COMMANDS.md`. These were taken at the
end of the release-prep work and reflect the visual state at that
point (with the chart range selector and dark-mode decimal place
polish applied).

## Review report

`docs/REVIEW-2026-06-01.md` contains a full audit of `main` done
on 2026-06-01/02 — stats, test coverage, build artifacts,
architecture review, UI review, and prioritised findings (P0–P3).
Read it for the current state of the codebase.
