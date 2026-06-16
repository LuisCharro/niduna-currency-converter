import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/shared/widgets/floating_pill_nav_item.dart';

void main() {
  testWidgets('FloatingPillNavItem exposes a labeled button node to AT',
      (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Row(
            children: [
              FloatingPillNavItem(
                icon: Icons.swap_horiz,
                label: 'Convert',
                isSelected: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    // There must be exactly one semantics node carrying the label.
    expect(find.bySemanticsLabel('Convert'), findsOneWidget);

    final node = tester.getSemantics(find.bySemanticsLabel('Convert'));
    final data = node.getSemanticsData();

    // The node must advertise itself as a button.
    expect(data.flagsCollection.isButton, isTrue);

    // The node must carry the selected state (Tristate.isTrue when selected).
    expect(data.flagsCollection.isSelected, Tristate.isTrue);

    handle.dispose();
  });

  testWidgets(
      'FloatingPillNavItem semantics node has a tap action registered (AT-activatable)',
      (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Row(
            children: [
              FloatingPillNavItem(
                icon: Icons.swap_horiz,
                label: 'Convert',
                isSelected: false,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    final node = tester.getSemantics(find.bySemanticsLabel('Convert'));
    final data = node.getSemanticsData();

    // This is the key AT-visible bug guard: if onTap: is absent from the
    // Semantics node, no SemanticsAction.tap is registered and a screen
    // reader cannot activate the item even though it can focus it.
    expect(
      data.hasAction(SemanticsAction.tap),
      isTrue,
      reason:
          'Screen readers require a tap action on the Semantics node to activate '
          'the item. ExcludeSemantics suppresses the inner GestureDetector, so '
          'the action must be forwarded explicitly via Semantics(onTap: ...).',
    );

    handle.dispose();
  });
}
