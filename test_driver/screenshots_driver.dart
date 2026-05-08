import 'dart:async';
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot:
        (String name, List<int> image, [Map<String, Object?>? args]) async {
          final outputDir =
              Platform.environment['SCREEN_OUTPUT_DIR'] ?? '.tmp/screens/ios';
          final directory = Directory(outputDir);
          await directory.create(recursive: true);
          final file = File('${directory.path}/$name.png');
          await file.writeAsBytes(image, flush: true);
          return true;
        },
  );
}