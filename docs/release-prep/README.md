# release-prep branch artifacts

This directory holds work-in-progress / disabled-state files that support the
`release-prep` branch but should NOT be in the active source tree.

## Files

### `NidunaGlanceWidget.kt.disabled`

The original Android home-screen widget implementation, renamed with `.disabled`
because it was blocking the release build.

**Why disabled:** the project uses `home_widget: 0.7.0` (Flutter package). That
version declares `glance-appwidget` as an `implementation` dependency, which
means the Glance API is NOT exposed to this app's compile classpath. The widget
source compiles against Glance symbols that the app cannot resolve.

**Why we shipped without it:** fixing this properly requires either
(a) bumping `home_widget` to `>=0.8.0` (which exposes Glance as `api`), or
(b) rewriting the widget without Glance using the older AppWidgetProvider
pattern. Both are too invasive to bundle into the release-prep pass.

**Restoration plan:** post-publish, either bump `home_widget` and rename the
file back to `NidunaGlanceWidget.kt`, or rewrite the widget with
AppWidgetProvider. The file in this directory is the verbatim original.

## Captured screenshots

See `docs/superpowers/plans/release-prep-screenshots.md` for the 8 UI polish
shots (4 tabs × light/dark) captured via the `idb` smoke test workflow
documented in `docs/RELEASE_COMMANDS.md`.
