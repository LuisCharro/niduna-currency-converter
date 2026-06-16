import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/features/settings/widgets/switch_tile.dart';

void main() {
  testWidgets('switch tile is a labeled, toggleable, activatable control',
      (tester) async {
    final handle = tester.ensureSemantics();
    var changed = false;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SwitchTile(
          title: 'Dark Mode',
          value: true,
          onChanged: (_) => changed = true,
        ),
      ),
    ));

    // The entire tile must be one semantic node labeled "Dark Mode" that
    // is a toggleable, tappable control. ExcludeSemantics on the inner row
    // ensures there is exactly one node matching this label.
    final node = tester.getSemantics(find.bySemanticsLabel(RegExp('Dark Mode')));
    expect(
      node,
      matchesSemantics(
        label: 'Dark Mode',
        hasToggledState: true,
        isToggled: true,
        hasTapAction: true,
      ),
    );

    // Firing the semantics tap action on the node must call onChanged.
    final data = node.getSemanticsData();
    expect(
      data.hasAction(SemanticsAction.tap),
      isTrue,
      reason:
          'Screen readers require a tap action on the outer Semantics node. '
          'ExcludeSemantics suppresses the inner Switch, so the action must '
          'be forwarded explicitly via Semantics(onTap: ...).',
    );
    tester.semantics.tap(find.semantics.byLabel(RegExp('Dark Mode')));
    await tester.pump();
    expect(changed, isTrue);
    handle.dispose();
  });
}
