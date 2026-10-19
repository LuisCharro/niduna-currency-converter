import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/currency_flag_icon.dart';
import '../../../shared/widgets/currency_picker_chrome.dart';

class SavedBaseCurrencySheet extends StatelessWidget {
  const SavedBaseCurrencySheet({
    required this.base,
    required this.codes,
    super.key,
  });
  static const addCurrencyResult = '__add_currency__';
  final String base;
  final List<String> codes;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    final colors = AppColors.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .75,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CurrencyPickerHeader(
                title: loc.convertFromTitle,
                subtitle: loc.savedCurrenciesSubtitle,
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: codes.length,
                  itemBuilder: (context, index) {
                    final currency = currencyByCode(codes[index]);
                    return Semantics(
                      selected: currency.code == base,
                      child: ListTile(
                        key: Key('saved_base_${currency.code}'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        leading: CurrencyFlagIcon(
                          code: currency.code,
                          symbol: currency.symbol,
                          radius: 18,
                        ),
                        title: Text(currency.name),
                        subtitle: Text(currency.code),
                        trailing: currency.code == base
                            ? Icon(Icons.check_rounded, color: colors.primary)
                            : null,
                        onTap: () => Navigator.pop(context, currency.code),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              TextButton.icon(
                onPressed: () => Navigator.pop(context, addCurrencyResult),
                icon: const Icon(Icons.add_rounded),
                label: Text(loc.addAnotherCurrency),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
