import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/src/features/favorites/data/favorite_usage_tracker.dart';

class _TestTracker with FavoriteUsageTracker {
  _TestTracker(this.prefs);

  @override
  final SharedPreferences prefs;
}

void main() {
  late SharedPreferences prefs;
  late _TestTracker tracker;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    tracker = _TestTracker(prefs);
  });

  test('initial usage count is 0', () {
    expect(tracker.usageCount('USD', 'EUR'), 0);
  });

  test('usageCount increments after recordUsage', () async {
    await tracker.recordUsage('USD', 'EUR');
    expect(tracker.usageCount('USD', 'EUR'), 1);

    await tracker.recordUsage('USD', 'EUR');
    expect(tracker.usageCount('USD', 'EUR'), 2);
  });

  test('different pairs have independent counts', () async {
    await tracker.recordUsage('USD', 'EUR');
    await tracker.recordUsage('USD', 'EUR');
    await tracker.recordUsage('GBP', 'JPY');

    expect(tracker.usageCount('USD', 'EUR'), 2);
    expect(tracker.usageCount('GBP', 'JPY'), 1);
    expect(tracker.usageCount('USD', 'GBP'), 0);
  });

  test('lastUsedAt returns null before any usage', () {
    expect(tracker.lastUsedAt('USD-EUR'), isNull);
  });

  test('lastUsedAt returns timestamp after recordUsage', () async {
    await tracker.recordUsage('USD', 'EUR');

    final lastUsed = tracker.lastUsedAt('USD-EUR');
    expect(lastUsed, isNotNull);
    expect(lastUsed!.isBefore(DateTime.now()), isTrue);
  });
}
