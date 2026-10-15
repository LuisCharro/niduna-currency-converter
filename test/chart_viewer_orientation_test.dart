import 'dart:async';
import 'package:currency_converter/src/features/charts/presentation/chart_viewer_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'closing during pending rotation restores portrait after landscape and blocks duplicate open',
    (tester) async {
      final calls = <List<DeviceOrientation>>[];
      final landscape = Completer<void>();
      final session = ChartViewerSession(
        requestOrientation: (orientations) {
          calls.add(orientations);
          return orientations.first == DeviceOrientation.portraitUp
              ? Future.value()
              : landscape.future;
        },
      );
      late BuildContext home;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              home = context;
              return const Scaffold();
            },
          ),
        ),
      );
      final opened = session.open(
        home,
        (_) => const Scaffold(body: Text('viewer')),
      );
      await tester.pumpAndSettle();
      session.landscape();
      await tester.pump();
      expect(calls.length, 1);
      await session.open(home, (_) => const Text('duplicate'));
      Navigator.of(tester.element(find.text('viewer'))).pop();
      await tester.pumpAndSettle();
      expect(session.active, isTrue);
      landscape.complete();
      await opened;
      expect(calls.last, [DeviceOrientation.portraitUp]);
      expect(session.active, isFalse);
      await tester.pumpWidget(const SizedBox());
      session.dispose();
    },
  );
}
