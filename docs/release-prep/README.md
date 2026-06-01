# release-prep branch artifacts

This directory holds work-in-progress / disabled-state files that supported
the `release-prep` branch but were not part of the active source tree at
the time the release-prep work landed.

## Widget restoration history

The home-screen widget has had two implementations over the course of the
project. The current implementation lives in the source tree at
`android/app/src/main/java/com/niduna/currency_converter/widget/NidunaAppWidgetProvider.kt`.

### Approach taken (post-release-prep)

**AppWidgetProvider + RemoteViews** — extends the legacy `AppWidgetProvider`
Android framework class, uses `RemoteViews` to update TextViews in
`res/layout/widget_layout.xml`. No Jetpack Compose, no Glance, no
Compose-runtime inline reified calls.

Trade-off: the widget looks plainer (no Glance styling), but it
ships and works on the current Kotlin 2.2.20 + Gradle toolchain.

### Approach that was abandoned (release-prep)

**Glance (Jetpack Compose for AppWidgets)** — would have used
`GlanceAppWidget` + `HomeWidgetGlanceState`. This is what
`home_widget 0.9.2`'s upstream example uses.

Why abandoned: the Glance API depends on inline reified functions in
the Compose runtime (`currentState<T>()`, `LocalState.current`). The
Kotlin 2.2.20 back-end emits an internal compiler error ("Couldn't
inline method call") on those signatures, so any Glance-based widget
fails to compile in this project. The
`/Users/luis/Niduna/apps/currency-converter/docs/release-prep/README.md`
note in the original `release-prep` PR mentioned Glance as a
restoration plan; that plan didn't survive the upgrade to home_widget
0.9.2 + Kotlin 2.2.20.

**To revisit Glance later:** pin Kotlin to <=2.1.x in
`android/settings.gradle.kts` and re-add
`implementation("androidx.glance:glance-appwidget:1.1.1")` to
`android/app/build.gradle.kts`. Then write the Glance-based widget
following the home_widget 0.9.2 example pattern.

## Captured screenshots

`docs/release-prep/screenshots/` contains the 8 UI polish shots
(4 tabs × light/dark) captured via the `idb` smoke test workflow
documented in `docs/RELEASE_COMMANDS.md`. These were taken at the
end of the release-prep work and reflect the visual state at that
point (with the chart range selector and dark-mode decimal place
polish applied).
