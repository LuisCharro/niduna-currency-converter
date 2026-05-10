import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonetizationController extends ChangeNotifier {
  MonetizationController(this._preferences) {
    _load();
  }

  final SharedPreferences _preferences;

  static const String _subscriptionKey = 'entitlement_subscription_active';
  static const String _removeAdsKey = 'entitlement_remove_ads_lifetime';
  static const String _chartsProKey = 'entitlement_charts_pro_lifetime';

  bool _hasActiveSubscription = false;
  bool _hasRemoveAdsLifetime = false;
  bool _hasChartsProLifetime = false;

  bool get hasActiveSubscription => _hasActiveSubscription;
  bool get hasRemoveAdsLifetime => _hasRemoveAdsLifetime;
  bool get hasChartsProLifetime => _hasChartsProLifetime;

  bool get adsEnabled => !_hasActiveSubscription && !_hasRemoveAdsLifetime;

  bool get canSelectAnyChartPair =>
      _hasActiveSubscription || _hasChartsProLifetime;

  bool get canUseIntradayRanges => _hasActiveSubscription;

  void _load() {
    _hasActiveSubscription = _preferences.getBool(_subscriptionKey) ?? false;
    _hasRemoveAdsLifetime = _preferences.getBool(_removeAdsKey) ?? false;
    _hasChartsProLifetime = _preferences.getBool(_chartsProKey) ?? false;
  }

  Future<void> setSubscriptionActive(bool value) async {
    _hasActiveSubscription = value;
    await _preferences.setBool(_subscriptionKey, value);
    notifyListeners();
  }

  Future<void> setRemoveAdsLifetime(bool value) async {
    _hasRemoveAdsLifetime = value;
    await _preferences.setBool(_removeAdsKey, value);
    notifyListeners();
  }

  Future<void> setChartsProLifetime(bool value) async {
    _hasChartsProLifetime = value;
    await _preferences.setBool(_chartsProKey, value);
    notifyListeners();
  }
}
