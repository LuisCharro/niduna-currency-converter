import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/ads/ad_consent_manager.dart';

void main() {
  test('waits for a late consent result before allowing ad requests', () async {
    final result = Completer<bool>();
    final manager = AdConsentManager.forTesting(() => result.future);

    final initialization = manager.initialize();
    await Future<void>.delayed(Duration.zero);

    expect(manager.canRequestAds, isFalse);
    expect(initialization, isNot(same(result.future)));

    result.complete(true);
    await initialization;

    expect(manager.canRequestAds, isTrue);
  });
}
