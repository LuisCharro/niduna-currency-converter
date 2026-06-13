package com.niduna.currency_converter.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
import com.niduna.currency_converter.R
import es.antonborri.home_widget.HomeWidgetPlugin

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
        val views = RemoteViews(context.packageName, R.layout.widget_layout)

        val amountLabel = prefs.getString("amountLabel", "100 USD") ?: "100 USD"
        val updatedLabel = prefs.getString("updatedLabel", "") ?: ""

        views.setTextViewText(R.id.widget_amount, amountLabel)
        views.setTextViewText(R.id.widget_updated, updatedLabel)

        val trendUpColor = Color.parseColor("#6F8C49")
        val trendDownColor = Color.parseColor("#DC6543")

        for (i in 0..2) {
            val prefix = "pair_${i}_"
            val visible = prefs.getBoolean("${prefix}visible", false)

            val symbolId = context.resources.getIdentifier("pair_${i}_symbol", "id", context.packageName)
            val codeId = context.resources.getIdentifier("pair_${i}_code", "id", context.packageName)
            val valueId = context.resources.getIdentifier("pair_${i}_value", "id", context.packageName)
            val trendId = context.resources.getIdentifier("pair_${i}_trend", "id", context.packageName)

            if (visible && codeId != 0) {
                val symbol = prefs.getString("${prefix}symbol", "$") ?: "$"
                val code = prefs.getString("${prefix}code", "") ?: ""
                val value = prefs.getString("${prefix}value", "") ?: ""
                val trend = prefs.getString("${prefix}trend", "none") ?: "none"
                val change = prefs.getString("${prefix}change", "") ?: ""

                if (symbolId != 0) views.setTextViewText(symbolId, symbol)
                views.setTextViewText(codeId, code)
                if (valueId != 0) views.setTextViewText(valueId, value)

                if (trendId != 0) {
                    if (trend == "none" || change.isEmpty()) {
                        views.setViewVisibility(trendId, View.GONE)
                    } else {
                        views.setViewVisibility(trendId, View.VISIBLE)
                        val arrow = when (trend) {
                            "up" -> "↑"
                            "down" -> "↓"
                            else -> "→"
                        }
                        val color = if (trend == "down") trendDownColor else trendUpColor
                        views.setTextViewText(trendId, "$arrow $change")
                        views.setInt(trendId, "setTextColor", color)
                    }
                }
            } else {
                listOf(symbolId, codeId, valueId, trendId).forEach { id ->
                    if (id != 0) views.setViewVisibility(id, View.INVISIBLE)
                }
            }
        }

        return views
    }
}
