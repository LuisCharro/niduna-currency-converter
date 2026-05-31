import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'widget_data.dart';

class HomeWidgetProvider {
  static const _widgetDataKey = 'niduna_home_widget_data';

  Future<void> pushData(HomeWidgetData data) async {
    try {
      await HomeWidget.saveWidgetData(_widgetDataKey, data.toJson());
    } on MissingPluginException catch (_) {
      // No-op in test / non-widget environments
    }
  }

  Future<void> clearData() async {
    try {
      await HomeWidget.saveWidgetData(_widgetDataKey, <String, dynamic>{});
    } on MissingPluginException catch (_) {
      // No-op in test / non-widget environments
    }
  }
}
