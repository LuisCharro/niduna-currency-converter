import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ChartOrientationRequest =
    Future<void> Function(List<DeviceOrientation>);

/// Owns the temporary orientation; child dialogs do not end this session.
class ChartViewerSession extends ChangeNotifier {
  ChartViewerSession({ChartOrientationRequest? requestOrientation})
    : _requestOrientation =
          requestOrientation ?? SystemChrome.setPreferredOrientations;

  final ChartOrientationRequest _requestOrientation;
  Future<void> _pending = Future<void>.value();
  bool _active = false;
  bool _disposed = false;
  bool _closing = false;
  bool get active => _active || _closing;

  Future<void> open(BuildContext context, WidgetBuilder builder) async {
    if (active || _disposed) return;
    final navigator = Navigator.of(context);
    final themes = InheritedTheme.capture(from: context, to: navigator.context);
    _active = true;
    notifyListeners();
    try {
      await navigator.push<void>(
        MaterialPageRoute<void>(
          builder: (context) => themes.wrap(builder(context)),
        ),
      );
    } finally {
      _active = false;
      _closing = true;
      await _enqueue(const [DeviceOrientation.portraitUp]);
      _closing = false;
      if (!_disposed) notifyListeners();
    }
  }

  void landscape() {
    if (!_active || _disposed) return;
    unawaited(
      _enqueue(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ], onlyWhileActive: true),
    );
  }

  Future<void> _enqueue(
    List<DeviceOrientation> orientations, {
    bool onlyWhileActive = false,
  }) {
    _pending = _pending.then((_) async {
      if (onlyWhileActive && (!_active || _disposed)) return;
      try {
        await _requestOrientation(orientations);
      } catch (error) {
        // The viewer remains adaptive and dismissible if Android refuses rotation.
        debugPrint('Chart orientation request failed: $error');
      }
    });
    return _pending;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
