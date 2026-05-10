import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/temporary_unlock.dart';
import 'rewarded_ad_service.dart';
import 'rewarded_ad_service_stub.dart';
import 'temporary_unlock_store.dart';

class MonetizationController extends ChangeNotifier {
  MonetizationController(this._preferences, {RewardedAdService? adService})
      : _adService = adService ?? RewardedAdServiceStub() {
    _load();
  }

  final SharedPreferences _preferences;
  final RewardedAdService _adService;

  static const String _subscriptionKey = 'entitlement_subscription_active';
  static const String _removeAdsKey = 'entitlement_remove_ads_lifetime';
  static const String _chartsProKey = 'entitlement_charts_pro_lifetime';

  bool _hasActiveSubscription = false;
  bool _hasRemoveAdsLifetime = false;
  bool _hasChartsProLifetime = false;
  bool _tempUnlocksLoaded = false;

  bool get hasActiveSubscription => _hasActiveSubscription;
  bool get hasRemoveAdsLifetime => _hasRemoveAdsLifetime;
  bool get hasChartsProLifetime => _hasChartsProLifetime;

  bool get adsEnabled => !_hasActiveSubscription && !_hasRemoveAdsLifetime;

  bool get canSelectAnyChartPair =>
      _hasActiveSubscription || _hasChartsProLifetime;

  bool get canUseIntradayRanges => _hasActiveSubscription;

  bool get canOfferRewardedChartUnlock =>
      !_hasActiveSubscription &&
      !_hasRemoveAdsLifetime &&
      !_hasChartsProLifetime;

  Set<String> get tempUnlockedCodes {
    if (!_tempUnlocksLoaded) {
      _tempUnlocksLoaded = true;
      loadTempUnlocks();
    }
    return _tempUnlocks.keys.toSet();
  }

  final Map<String, TemporaryUnlock> _tempUnlocks = {};

  bool isChartPairUnlocked(String base, String quote) {
    if (_isFreeDefaultPair(base, quote)) return true;
    if (_hasActiveSubscription) return true;
    if (_hasChartsProLifetime) return true;
    final unlock = _tempUnlocks[TemporaryUnlock.canonicalKey(base, quote)];
    if (unlock != null && !unlock.isExpired) return true;
    return false;
  }

  void _load() {
    _hasActiveSubscription = _preferences.getBool(_subscriptionKey) ?? false;
    _hasRemoveAdsLifetime = _preferences.getBool(_removeAdsKey) ?? false;
    _hasChartsProLifetime = _preferences.getBool(_chartsProKey) ?? false;
  }

  Future<void> loadTempUnlocks() async {
    final store = TemporaryUnlockStore(_preferences);
    await store.cleanExpired();
    final raw = _preferences.getString('temp_unlocks_registry');
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = _decodeJsonMap(raw);
      for (final entry in decoded.entries) {
        try {
          final u = TemporaryUnlock.fromJson(entry.value);
          if (!u.isExpired) _tempUnlocks[TemporaryUnlock.canonicalKey(u.base, u.quote)] = u;
        } catch (_) {}
      }
    } catch (_) {}
  }

  Map<String, dynamic> _decodeJsonMap(String source) {
    try {
      final decoded = _parseJsonMap(source);
      if (decoded is Map) return decoded.cast<String, dynamic>();
    } catch (_) {}
    return {};
  }

  Map<String, dynamic> _parseJsonMap(String source) {
    final result = <String, dynamic>{};
    var i = 0;
    while (i < source.length) {
      if (source[i] == '{') {
        i++;
        while (i < source.length && source[i] != '}') {
          final ks = source.indexOf("':", i);
          if (ks == -1 || ks >= source.length) break;
          final k =
              source.substring(i, ks).trim().replaceAll('"', '').trim();
          i = ks + 2;
          if (i >= source.length) break;
          final vs = source.indexOf(':', i);
          if (vs == -1 || vs >= source.length) break;
          i = vs + 1;
          while (i < source.length && source[i] == ' ') i++;
          if (i >= source.length) break;
          final commaIdx = source.indexOf(',', i);
          final braceIdx = source.indexOf('}', i);
          var ve = commaIdx;
          if (ve == -1 || (braceIdx >= 0 && braceIdx < ve)) ve = braceIdx;
          if (ve == -1) ve = source.length;
          result[k] = source.substring(i, ve).trim().replaceAll('"', '').trim();
          i = ve + 1;
        }
      } else {
        i++;
      }
    }
    return result;
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

  Future<bool> requestRewardedChartUnlock(String base, String quote) async {
    if (!canOfferRewardedChartUnlock) return false;

    final success = await _adService.showRewardedAd(
      rewardType: 'chart_pair_unlock',
    );
    if (!success) return false;

    final unlock = TemporaryUnlock(
      base: base,
      quote: quote,
      grantedAt: DateTime.now(),
    );

    final store = TemporaryUnlockStore(_preferences);
    await store.save(unlock);

    _tempUnlocks[TemporaryUnlock.canonicalKey(base, quote)] = unlock;
    notifyListeners();
    return true;
  }

  bool _isFreeDefaultPair(String base, String quote) {
    final freePairs = [
      ('USD', 'EUR'),
      ('EUR', 'USD'),
    ];
    return freePairs.contains((base, quote));
  }

  void clearTempUnlocks() {
    _tempUnlocks.clear();
    _preferences.remove('temp_unlocks_registry');
    notifyListeners();
  }
}
