import 'package:flutter/material.dart';

import '../../../core/localization/ui_copy.dart';
import '../../../core/currency/supported_currencies.dart';
import '../../../core/currency/currency_groups.dart';
import '../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/widgets/currency_picker_chrome.dart';
import 'currency_picker_tile.dart';
import 'currency_section_header.dart';

class CurrencyPickerSheet extends StatefulWidget {
  const CurrencyPickerSheet({
    required this.title,
    required this.base,
    required this.selectedCodes,
    required this.onSelectBase,
    required this.onToggleCode,
    required this.selectBaseMode,
    super.key,
  });

  final String title;
  final String base;
  final List<String> selectedCodes;
  final ValueChanged<String> onSelectBase;
  final ValueChanged<String> onToggleCode;
  final bool selectBaseMode;

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  late final Set<String> _selectedCodes = widget.selectedCodes.toSet();
  String _query = '';
  final Set<CurrencySection> _expandedSections = <CurrencySection>{};

  @override
  void initState() {
    super.initState();
    for (final section in CurrencySection.values) {
      if (section.defaultExpanded) {
        _expandedSections.add(section);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groups = _filteredGroups();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .84,
      minChildSize: .42,
      maxChildSize: .92,
      builder: (context, scrollController) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            children: <Widget>[
              CurrencyPickerHeader(title: widget.title, subtitle: _subtitle(l10n)),
              const SizedBox(height: 12),
              CurrencyPickerSearchField(
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: groups.isEmpty
                    ? _emptyResult(context)
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return _buildGroup(context, group);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyResult(BuildContext context) {
    return Center(
      child: Text(
        'No currencies found',
        style: TextStyle(color: AppColors.of(context).muted, fontSize: 14),
      ),
    );
  }

  Widget _buildGroup(BuildContext context, CurrencyGroup group) {
    final isExpanded = _expandedSections.contains(group.section);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CurrencySectionHeader(
          group: group,
          isExpanded: isExpanded,
          onToggle: () => setState(() {
            if (_expandedSections.contains(group.section)) {
              _expandedSections.remove(group.section);
            } else {
              _expandedSections.add(group.section);
            }
          }),
        ),
        if (isExpanded) ..._buildGroupItems(context, group),
      ],
    );
  }

  List<Widget> _buildGroupItems(BuildContext context, CurrencyGroup group) {
    final sorted = _sortGroup(group.currencies);
    return sorted.map((currency) {
      final isBase = currency.code == widget.base;
      final isSelected = _selectedCodes.contains(currency.code);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CurrencyPickerTile(
            currency: currency,
            isBase: isBase,
            isSelected: isSelected,
            selectBaseMode: widget.selectBaseMode,
            onTap: () {
              if (widget.selectBaseMode) {
                widget.onSelectBase(currency.code);
              } else {
                _toggle(currency.code);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Divider(
              height: 1,
              color: AppColors.of(context).border.withValues(alpha: .15),
            ),
          ),
        ],
      );
    }).toList();
  }

  List<CurrencyGroup> _filteredGroups() {
    final allCurrencies = allSupportedCurrencies.where(_matchesQuery).toList();
    return buildCurrencyGroups(currencies: allCurrencies);
  }

  List<SupportedCurrency> _sortGroup(List<SupportedCurrency> currencies) {
    final sorted = List<SupportedCurrency>.from(currencies);
    sorted.sort((a, b) {
      final aRank = _itemRank(a.code);
      final bRank = _itemRank(b.code);
      if (aRank != bRank) return aRank.compareTo(bRank);
      return a.code.compareTo(b.code);
    });
    return sorted;
  }

  int _itemRank(String code) {
    if (code == widget.base) return 0;
    if (_selectedCodes.contains(code)) return 1;
    return 2;
  }

  bool _matchesQuery(SupportedCurrency currency) {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return currency.code.toLowerCase().contains(normalized) ||
        currency.name.toLowerCase().contains(normalized);
  }

  String _subtitle(AppLocalizations? l10n) {
    if (widget.selectBaseMode) {
      return currentBaseSubtitle(context, widget.base);
    }
    return shownBaseSubtitle(context, _selectedCodes.length, widget.base);
  }

  void _toggle(String code) {
    if (code == widget.base) return;
    setState(() {
      if (_selectedCodes.contains(code)) {
        if (_selectedCodes.length == 1) return;
        _selectedCodes.remove(code);
      } else {
        _selectedCodes.add(code);
      }
    });
    widget.onToggleCode(code);
  }
}
