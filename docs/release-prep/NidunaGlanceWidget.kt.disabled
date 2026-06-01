package com.niduna.currency_converter.widget

import android.content.Context
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.layout.Column
import androidx.glance.layout.contentAlignment
import androidx.glance.modifier.fillMaxSize
import androidx.glance.text.Text
import androidx.glance.text textStyle
import androidx.glance.unit.ColorProvider
import com.home_widget.HomeWidget

class NidunaGlanceWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: Int) {
        provideContent {
            val data = HomeWidget.getWidgetData(context)
            val baseCode = data.getString("baseCode") ?: "USD"
            val quoteCode = data.getString("quoteCode") ?: "EUR"
            val amount = data.getDouble("amount", 100.0)
            val rate = data.getDouble("rate", 0.0)
            val convertedAmount = data.getString("convertedAmount") ?: ""
            val updatedAt = data.getString("updatedAt") ?: ""

            Column(
                modifier = Modifier.fillMaxSize(),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = String.format("%.0f %s", amount, baseCode),
                    style = TextStyle(color = ColorProvider(0xFF1C1917.toColor()), fontSize = 18.sp),
                )
                Text(
                    text = if (convertedAmount.isNotEmpty()) "= $convertedAmount" else String.format(
                        "%.2f %s",
                        amount * rate,
                        quoteCode,
                    ),
                    style = TextStyle(
                        color = ColorProvider(0xFF1C1917.toColor()),
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold,
                    ),
                )
                Text(
                    text = if (updatedAt.isNotEmpty()) "Updated $updatedAt" else "",
                    style = TextStyle(color = ColorProvider(0xFF78716C.toColor()), fontSize = 12.sp),
                )
            }
        }
    }
}

class NidunaGlanceWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = NidunaGlanceWidget()
}
