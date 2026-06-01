package com.niduna.currency_converter.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import com.niduna.currency_converter.R
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Niduna home-screen widget.
 *
 * Uses the legacy `AppWidgetProvider` + `RemoteViews` pattern instead of
 * Glance. Why:
 * - The plugin's Glance example relies on `currentState<T>()` and
 *   `LocalState.current` — both inline reified functions from the
 *   Compose runtime. The Kotlin 2.2.20 back-end ICEs ("Couldn't inline
 *   method call") on those signatures, so any Glance-based widget fails
 *   to compile in this project.
 * - `AppWidgetProvider` uses a static `widget_layout.xml` and `RemoteViews`
 *   to update TextViews. No Compose, no inliner, no problem.
 *
 * The trade-off is a less pretty widget (no Glance Compose styling) but
 * it ships and works.
 *
 * The Dart side that pushes data is
 * `lib/src/core/widget/home_widget_provider.dart` — it calls
 * `HomeWidget.saveWidgetData(...)` after the conversion controller loads
 * a fresh snapshot.
 */
class NidunaAppWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = buildRemoteViews(context)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun buildRemoteViews(context: Context): RemoteViews {
        val prefs = HomeWidgetPlugin.getData(context)
        val baseCode = prefs.getString("baseCode", "USD") ?: "USD"
        val quoteCode = prefs.getString("quoteCode", "EUR") ?: "EUR"
        // amount / rate come in as strings (see home_widget_provider.dart)
        // because raw SharedPreferences has no getDouble. We only need
        // them as numbers for the local fallback when convertedAmount is
        // not pre-formatted.
        val amount = prefs.getString("amount", null)?.toDoubleOrNull() ?: 100.0
        val rate = prefs.getString("rate", null)?.toDoubleOrNull() ?: 0.0
        val convertedAmount = prefs.getString("convertedAmount", "") ?: ""
        val updatedAt = prefs.getString("updatedAt", "") ?: ""

        val amountText = String.format("%.0f %s", amount, baseCode)
        val convertedText = if (convertedAmount.isNotEmpty()) {
            "= $convertedAmount"
        } else {
            String.format("= %.2f %s", amount * rate, quoteCode)
        }
        val updatedText = if (updatedAt.isNotEmpty()) "Updated $updatedAt" else ""

        val views = RemoteViews(context.packageName, R.layout.widget_layout)
        views.setTextViewText(R.id.widget_amount, amountText)
        views.setTextViewText(R.id.widget_converted, convertedText)
        views.setTextViewText(R.id.widget_updated, updatedText)
        return views
    }
}
