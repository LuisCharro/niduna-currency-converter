import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/convert/models/rate_card_data.dart';
import '../../features/convert/widgets/share/rate_card_image.dart';
import 'rate_card_renderer.dart';

/// Renders [data] as a branded card off-screen, writes a temp PNG, and opens
/// the OS share sheet. Off-screen (Positioned far left) so there is no flash.
Future<void> shareRateCard(BuildContext context, RateCardData data) async {
  final overlay = Overlay.of(context);
  final key = GlobalKey();
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -10000,
      top: 0,
      child: Material(
        type: MaterialType.transparency,
        child: RepaintBoundary(key: key, child: RateCardImage(data: data)),
      ),
    ),
  );
  final messenger = ScaffoldMessenger.of(context);
  overlay.insert(entry);
  try {
    // Let the off-screen card lay out and paint before capturing.
    await Future<void>.delayed(const Duration(milliseconds: 40));
    final bytes = await RateCardRenderer.captureBoundary(key, pixelRatio: 3);
    if (bytes == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Couldn’t create the image, try again')),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/niduna-rates.png');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(file.path)],
        text: 'Exchange rates · ${data.baseAmountLabel} — via Niduna',
      ),
    );
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Couldn’t share the rates, try again')),
    );
  } finally {
    entry.remove();
  }
}
