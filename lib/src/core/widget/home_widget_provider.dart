import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'widget_data.dart';

class HomeWidgetProvider {
  static const _androidWidgetName =
      'com.niduna.currency_converter.widget.NidunaAppWidgetProvider';

  Future<void> pushData(HomeWidgetData data) async {
    try {
      final futures = <Future<bool?>>[
        HomeWidget.saveWidgetData<String>('baseCode', data.baseCode),
        HomeWidget.saveWidgetData<String>('amountLabel', data.amountLabel),
        HomeWidget.saveWidgetData<String>('updatedLabel', data.updatedLabel),
      ];

      for (var i = 0; i < 3; i++) {
        final has = data.pairs.length > i;
        final p = has
            ? data.pairs[i]
            : const WidgetPair(code: '', symbol: '', value: '');
        final prefix = 'pair_${i}_';
        futures.addAll([
          HomeWidget.saveWidgetData<String>('${prefix}code', p.code),
          HomeWidget.saveWidgetData<String>('${prefix}symbol', p.symbol),
          HomeWidget.saveWidgetData<String>('${prefix}value', p.value),
          HomeWidget.saveWidgetData<String>('${prefix}trend', p.trend),
          HomeWidget.saveWidgetData<String>('${prefix}change', p.changePercent),
          HomeWidget.saveWidgetData<bool>('${prefix}visible', has),
        ]);
      }

      await Future.wait(futures);
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        qualifiedAndroidName: _androidWidgetName,
      );
    } on MissingPluginException catch (_) {}
  }

  Future<void> clearData() async {
    try {
      for (final key in ['baseCode', 'amountLabel', 'updatedLabel']) {
        await HomeWidget.saveWidgetData<String>(key, '');
      }
      for (var i = 0; i < 3; i++) {
        final prefix = 'pair_${i}_';
        for (final suffix in ['code', 'symbol', 'value', 'trend', 'change']) {
          await HomeWidget.saveWidgetData<String>('$prefix$suffix', '');
        }
        await HomeWidget.saveWidgetData<bool>('${prefix}visible', false);
      }
    } on MissingPluginException catch (_) {}
  }
}
