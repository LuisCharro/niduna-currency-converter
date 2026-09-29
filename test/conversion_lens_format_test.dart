import 'package:currency_converter/src/features/convert/widgets/conversion_lens_positioner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatLensValue does not leave punctuation after fiat integers', () {
    expect(formatLensValue(100, 'EUR'), '100');
    expect(formatLensValue(738, 'GBP'), '738');
    expect(formatLensValue(1000, 'USD'), '1,000');
  });

  test('formatLensValue renders quick-amount presets as clean integers', () {
    // Regression: these used to render as "1.000", "10.00", "50.00".
    expect(formatLensValue(1, 'USD'), '1');
    expect(formatLensValue(10, 'USD'), '10');
    expect(formatLensValue(50, 'USD'), '50');
    expect(formatLensValue(100, 'USD'), '100');
    expect(formatLensValue(1000, 'USD'), '1,000');
  });

  test('formatLensValue keeps genuinely fractional amounts at a fixed precision', () {
    expect(formatLensValue(12.5, 'USD'), '12.50');
    expect(formatLensValue(0.879, 'EUR'), '0.88');
  });

  test('formatLensValue never shows decimals for zero-decimal currencies', () {
    expect(formatLensValue(15733.4, 'JPY'), '15,733');
    expect(formatLensValue(1, 'JPY'), '1');
  });

  test('formatLensConvertedAmount matches the main list formatter at every magnitude', () {
    // Regression: the right column used to drop decimals above 100 and show
    // 3 decimals below 10, producing "0.879 EUR" / "879 EUR" side by side.
    expect(formatLensConvertedAmount(0.8794, 'EUR'), '0.88');
    expect(formatLensConvertedAmount(8.794, 'EUR'), '8.79');
    expect(formatLensConvertedAmount(43.97, 'EUR'), '43.97');
    expect(formatLensConvertedAmount(87.94, 'EUR'), '87.94');
    expect(formatLensConvertedAmount(879.4, 'EUR'), '879.40');
  });

  test('formatLensConvertedAmount is zero-decimal for JPY-style currencies', () {
    expect(formatLensConvertedAmount(15733.4, 'JPY'), '15,733');
  });

  test('formatHeroConverted has no fractional part for zero-decimal currencies', () {
    expect(formatHeroConverted(15733.4, 'JPY'), '15,733');
  });
}
