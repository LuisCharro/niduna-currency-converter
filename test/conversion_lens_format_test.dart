import 'package:currency_converter/src/features/convert/widgets/conversion_lens_positioner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatLensValue does not leave punctuation after fiat integers', () {
    expect(formatLensValue(100, 'EUR'), '100');
    expect(formatLensValue(738, 'GBP'), '738');
    expect(formatLensValue(1000, 'USD'), '1,000');
  });
}
