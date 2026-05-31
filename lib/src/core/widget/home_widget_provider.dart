import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'widget_data.dart';

class HomeWidgetProvider extends ChangeNotifier {
  static const _widgetDataKey = 'niduna_home_widget_data';

  Future<void> pushData(HomeWidgetData data) async {
    await HomeWidget.saveWidgetData(_widgetDataKey, data.toJson());
  }

  Future<void> clearData() async {
    await HomeWidget.saveWidgetData(_widgetDataKey, <String, dynamic>{});
  }
}
