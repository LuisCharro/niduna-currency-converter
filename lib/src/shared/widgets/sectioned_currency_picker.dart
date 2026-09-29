import 'package:flutter/material.dart';

import '../../core/currency/currency_groups.dart';
import '../../core/currency/supported_currencies.dart';
import '../../core/localization/ui_copy.dart';
import '../../core/theme/app_colors.dart';
import 'currency_picker_chrome.dart';
import 'currency_section_header.dart';

typedef CurrencyTileBuilder =
    Widget Function(BuildContext context, SupportedCurrency currency);

class SectionedCurrencyPicker extends StatefulWidget {
  const SectionedCurrencyPicker({
    required this.title,
    this.subtitle,
    required this.currencies,
    required this.tileBuilder,
    this.initialExpandedSections,
    this.headerWidget,
    this.itemComparator,
    this.highlightedCodes = const <String>[],
    this.popularCodes = popularCurrencyCodes,
    this.expandSectionsForCodes = const <String>[],
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<SupportedCurrency> currencies;
  final CurrencyTileBuilder tileBuilder;
  final Set<CurrencySection>? initialExpandedSections;
  final Widget? headerWidget;
  final Comparator<SupportedCurrency>? itemComparator;

  /// Codes to surface first, under a "Selected" heading, when the sheet
  /// opens with no active search (e.g. the current base, or the currently
  /// visible/selected currencies).
  final List<String> highlightedCodes;

  /// Widely-used currencies to surface under a "Popular" heading, skipping
  /// any already shown in [highlightedCodes]. Defaults to a standard set.
  final List<String> popularCodes;

  /// Codes whose containing region/category group should start expanded
  /// (in addition to [initialExpandedSections]). Typically the current
  /// base or quote currency.
  final List<String> expandSectionsForCodes;

  @override
  State<SectionedCurrencyPicker> createState() =>
      _SectionedCurrencyPickerState();
}

class _SectionedCurrencyPickerState extends State<SectionedCurrencyPicker> {
  String _query = '';
  late final Set<CurrencySection> _expandedSections = _initialExpanded();

  Set<CurrencySection> _initialExpanded() {
    final result = Set<CurrencySection>.from(
      widget.initialExpandedSections ??
          CurrencySection.values.where((s) => s.defaultExpanded),
    );
    for (final code in widget.expandSectionsForCodes) {
      final section = sectionForCode(code, widget.currencies);
      if (section != null) result.add(section);
    }
    return result;
  }

  List<SupportedCurrency> get _filtered {
    final q = _query.toLowerCase();
    if (q.isEmpty) return widget.currencies;
    return widget.currencies
        .where(
          (c) =>
              c.code.toLowerCase().contains(q) ||
              c.name.toLowerCase().contains(q),
        )
        .toList();
  }

  bool get _showTopSection => _query.isEmpty;

  List<SupportedCurrency> get _topSelected {
    final byCode = {for (final c in widget.currencies) c.code: c};
    final result = <SupportedCurrency>[];
    for (final code in widget.highlightedCodes) {
      final currency = byCode[code];
      if (currency != null && !result.any((c) => c.code == code)) {
        result.add(currency);
      }
    }
    return result;
  }

  List<SupportedCurrency> get _topPopular {
    final byCode = {for (final c in widget.currencies) c.code: c};
    final selectedCodes = _topSelected.map((c) => c.code).toSet();
    final result = <SupportedCurrency>[];
    for (final code in widget.popularCodes) {
      if (selectedCodes.contains(code)) continue;
      final currency = byCode[code];
      if (currency != null) result.add(currency);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final groups = buildCurrencyGroups(currencies: _filtered);
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
              CurrencyPickerHeader(
                title: widget.title,
                subtitle: widget.subtitle,
              ),
              const SizedBox(height: 12),
              CurrencyPickerSearchField(
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
              const SizedBox(height: 12),
              if (widget.headerWidget != null) ...[
                widget.headerWidget!,
                const SizedBox(height: 8),
              ],
              Expanded(
                child: groups.isEmpty
                    ? _emptyState(context)
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: groups.length + (_showTopSection ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (_showTopSection) {
                            if (i == 0) return _topSection(context);
                            return _group(context, groups[i - 1]);
                          }
                          return _group(context, groups[i]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topSection(BuildContext context) {
    final selected = _topSelected;
    final popular = _topPopular;
    if (selected.isEmpty && popular.isEmpty) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selected.isNotEmpty)
          ..._topSubsection(context, pickerSelectedSectionLabel(context), selected),
        if (popular.isNotEmpty)
          ..._topSubsection(context, pickerPopularSectionLabel(context), popular),
      ],
    );
  }

  List<Widget> _topSubsection(
    BuildContext context,
    String label,
    List<SupportedCurrency> items,
  ) {
    final colors = AppColors.of(context);
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.muted,
            letterSpacing: 0.5,
          ),
        ),
      ),
      for (final currency in items) ...[
        widget.tileBuilder(context, currency),
        Padding(
          padding: const EdgeInsets.only(left: 52),
          child: Divider(height: 1, color: colors.border.withValues(alpha: .15)),
        ),
      ],
    ];
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Text(
        noCurrenciesFound(context),
        style: TextStyle(color: AppColors.of(context).muted, fontSize: 14),
      ),
    );
  }

  Widget _group(BuildContext context, CurrencyGroup group) {
    final expanded = _expandedSections.contains(group.section);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CurrencySectionHeader(
          group: group,
          isExpanded: expanded,
          onToggle: () => setState(() {
            if (_expandedSections.contains(group.section)) {
              _expandedSections.remove(group.section);
            } else {
              _expandedSections.add(group.section);
            }
          }),
        ),
        if (expanded) ..._groupItems(context, group),
      ],
    );
  }

  List<Widget> _groupItems(BuildContext context, CurrencyGroup group) {
    var items = group.currencies.toList();
    if (widget.itemComparator != null) {
      items.sort(widget.itemComparator);
    }
    final result = <Widget>[];
    for (final currency in items) {
      result.add(widget.tileBuilder(context, currency));
      result.add(
        Padding(
          padding: const EdgeInsets.only(left: 52),
          child: Divider(
            height: 1,
            color: AppColors.of(context).border.withValues(alpha: .15),
          ),
        ),
      );
    }
    return result;
  }
}
