import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'widget_data.dart';

class HomeWidgetProvider {
  // The Android widget class that reads these keys. Must match the
  // class declared in AndroidManifest.xml.
  static const _androidWidgetName =
      'com.niduna.currency_converter.widget.NidunaAppWidgetProvider';

  Future<void> pushData(HomeWidgetData data) async {
    try {
      // home_widget 0.9.2's `saveWidgetData` takes a SINGLE primitive
      // value per call (Boolean, Float, String, Double, Long). Maps are
      // not supported — the plugin's Kotlin side throws
      // "Invalid Type" for anything else. So we call it once per key.
      // See home_widget 0.9.2's example/lib/main.dart for the pattern.
      //
      // Numerics are sent as strings because the widget side reads from
      // raw SharedPreferences (via the plugin's HomeWidgetPlugin.getData
      // helper), and SharedPreferences has no getDouble.
      await Future.wait<bool?>([
        HomeWidget.saveWidgetData<String>('baseCode', data.baseCode),
        HomeWidget.saveWidgetData<String>('quoteCode', data.quoteCode),
        HomeWidget.saveWidgetData<String>('rate', data.rate.toString()),
        HomeWidget.saveWidgetData<String>('amount', data.amount.toString()),
        HomeWidget.saveWidgetData<String>(
          'convertedAmount',
          data.convertedAmount,
        ),
        HomeWidget.saveWidgetData<String>('updatedAt', data.updatedAt),
      ]);
      // Force the system to re-render the widget so the new data shows.
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        qualifiedAndroidName: _androidWidgetName,
      );
    } on MissingPluginException catch (_) {
      // No-op in test / non-widget environments
    }
  }

  Future<void> clearData() async {
    try {
      for (final key in [
        'baseCode',
        'quoteCode',
        'rate',
        'amount',
        'convertedAmount',
        'updatedAt',
      ]) {
        await HomeWidget.saveWidgetData<String>(key, '');
      }
    } on MissingPluginException catch (_) {
      // No-op in test / non-widget environments
    }
  }
}
