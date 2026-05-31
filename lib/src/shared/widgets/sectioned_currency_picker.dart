import 'package:flutter/material.dart';

import '../../core/currency/currency_groups.dart';
import '../../core/currency/supported_currencies.dart';
import '../../core/theme/app_colors.dart';
import 'currency_picker_chrome.dart';
import 'currency_section_header.dart';

typedef CurrencyTileBuilder = Widget Function(
  BuildContext context,
  SupportedCurrency currency,
);

class SectionedCurrencyPicker extends StatefulWidget {
  const SectionedCurrencyPicker({
    required this.title,
    this.subtitle,
    required this.currencies,
    required this.tileBuilder,
    this.initialExpandedSections,
    this.headerWidget,
    this.itemComparator,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<SupportedCurrency> currencies;
  final CurrencyTileBuilder tileBuilder;
  final Set<CurrencySection>? initialExpandedSections;
  final Widget? headerWidget;
  final Comparator<SupportedCurrency>? itemComparator;

  @override
  State<SectionedCurrencyPicker> createState() =>
      _SectionedCurrencyPickerState();
}

class _SectionedCurrencyPickerState extends State<SectionedCurrencyPicker> {
  String _query = '';
  late final Set<CurrencySection> _expandedSections =
      Set<CurrencySection>.from(
    widget.initialExpandedSections ??
        CurrencySection.values.where((s) => s.defaultExpanded),
  );

  List<SupportedCurrency> get _filtered {
    final q = _query.toLowerCase();
    if (q.isEmpty) return widget.currencies;
    return widget.currencies
        .where((c) =>
            c.code.toLowerCase().contains(q) ||
            c.name.toLowerCase().contains(q))
        .toList();
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
                        itemCount: groups.length,
                        itemBuilder: (context, i) =>
                            _group(context, groups[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Text(
        'No currencies found',
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
      result.add(Padding(
        padding: const EdgeInsets.only(left: 52),
        child: Divider(
          height: 1,
          color: AppColors.of(context).border.withValues(alpha: .15),
        ),
      ));
    }
    return result;
  }
}
