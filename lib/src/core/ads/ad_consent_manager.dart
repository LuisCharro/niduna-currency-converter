import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

typedef AdConsentTestResolver = Future<bool> Function();

/// Owns the UMP lifecycle and the gate used by every ad surface.
///
/// The manager deliberately starts closed: an ad request is allowed only
/// after UMP has refreshed consent information and says it is safe to request
/// ads. This keeps test/plugin failures fail-closed instead of bypassing UMP.
class AdConsentManager extends ChangeNotifier {
  AdConsentManager._({AdConsentTestResolver? testResolver})
    : _testResolver = testResolver;

  @visibleForTesting
  AdConsentManager.forTesting(AdConsentTestResolver resolver)
    : _testResolver = resolver;

  static final AdConsentManager instance = AdConsentManager._();

  Future<void>? _initialization;
  final AdConsentTestResolver? _testResolver;
  bool _canRequestAds = false;
  bool _privacyOptionsRequired = false;

  bool get canRequestAds => _canRequestAds;
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    final testResolver = _testResolver;
    if (testResolver != null) {
      _canRequestAds = await testResolver();
      notifyListeners();
      return;
    }

    // The Flutter test binding has no Android UMP channel. Avoid creating
    // timeout timers there; the Android/iOS path remains fail-closed below.
    if (WidgetsBinding.instance.runtimeType.toString().contains(
      'TestWidgetsFlutterBinding',
    )) {
      return;
    }

    final info = ConsentInformation.instance;
    final done = Completer<void>();

    void complete() {
      if (!done.isCompleted) done.complete();
    }

    try {
      info.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          try {
            await ConsentForm.loadAndShowConsentFormIfRequired((error) {
              if (error != null) {
                debugPrint('UMP consent form error: ${error.message}');
              }
            });
          } catch (error) {
            debugPrint('UMP consent form failed: $error');
          } finally {
            await _refresh(info);
            complete();
          }
        },
        (error) {
          debugPrint('UMP consent info update failed: ${error.message}');
          unawaited(_refresh(info).whenComplete(complete));
        },
      );
    } catch (error) {
      debugPrint('UMP initialization unavailable: $error');
      await _refresh(info);
      complete();
    }

    // AppShell starts this work without awaiting it, so waiting here does not
    // delay the first frame. Ad surfaces wait for the real UMP result instead
    // of racing a short timeout and permanently disabling ads for this run.
    await done.future;
    if (_canRequestAds) {
      try {
        await MobileAds.instance.initialize();
      } catch (error) {
        debugPrint('Mobile Ads initialization failed: $error');
      }
    }
  }

  Future<void> _refresh(ConsentInformation info) async {
    try {
      _canRequestAds = await info.canRequestAds();
      _privacyOptionsRequired =
          await info.getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (error) {
      debugPrint('UMP consent state unavailable: $error');
      _canRequestAds = false;
      _privacyOptionsRequired = false;
    }
    notifyListeners();
  }

  Future<void> showPrivacyOptions() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((error) {
        if (error != null) {
          debugPrint('UMP privacy options error: ${error.message}');
        }
      });
      await _refresh(ConsentInformation.instance);
    } catch (error) {
      debugPrint('UMP privacy options unavailable: $error');
    }
  }
}
