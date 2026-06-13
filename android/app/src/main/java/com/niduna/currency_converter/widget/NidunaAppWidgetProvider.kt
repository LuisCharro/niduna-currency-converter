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

        val symbolIds = intArrayOf(
            R.id.pair_0_symbol, R.id.pair_1_symbol, R.id.pair_2_symbol,
        )
        val codeIds = intArrayOf(
            R.id.pair_0_code, R.id.pair_1_code, R.id.pair_2_code,
        )
        val valueIds = intArrayOf(
            R.id.pair_0_value, R.id.pair_1_value, R.id.pair_2_value,
        )
        val trendIds = intArrayOf(
            R.id.pair_0_trend, R.id.pair_1_trend, R.id.pair_2_trend,
        )

        for (i in 0..2) {
            val prefix = "pair_${i}_"
            val code = prefs.getString("${prefix}code", "") ?: ""
            val value = prefs.getString("${prefix}value", "") ?: ""

            if (code.isNotEmpty()) {
                val symbol = prefs.getString("${prefix}symbol", "$") ?: "$"
                val trend = prefs.getString("${prefix}trend", "none") ?: "none"
                val change = prefs.getString("${prefix}change", "") ?: ""

                views.setTextViewText(symbolIds[i], symbol)
                views.setTextViewText(codeIds[i], code)
                views.setTextViewText(valueIds[i], value)

                if (trend == "none" || change.isEmpty()) {
                    views.setViewVisibility(trendIds[i], View.GONE)
                } else {
                    views.setViewVisibility(trendIds[i], View.VISIBLE)
                    val arrow = when (trend) {
                        "up" -> "\u2191"
                        "down" -> "\u2193"
                        else -> "\u2192"
                    }
                    val color = if (trend == "down") trendDownColor else trendUpColor
                    views.setTextViewText(trendIds[i], "$arrow $change")
                    views.setInt(trendIds[i], "setTextColor", color)
                }
            } else {
                views.setTextViewText(symbolIds[i], "\u2013")
                views.setTextViewText(codeIds[i], "\u2013")
                views.setTextViewText(valueIds[i], "\u2013")
                views.setViewVisibility(trendIds[i], View.GONE)
            }
        }

        return views
    }
}
