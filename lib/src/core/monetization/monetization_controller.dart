import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/temporary_unlock.dart';
import 'purchase_service.dart';
import 'purchase_service_stub.dart';
import 'rewarded_ad_service.dart';
import 'rewarded_ad_service_stub.dart';
import 'temporary_unlock_store.dart';

class MonetizationController extends ChangeNotifier {
  MonetizationController(
    this._preferences, {
    RewardedAdService? adService,
    PurchaseService? purchaseService,
  }) : _adService = adService ?? RewardedAdServiceStub(),
       _purchaseService = purchaseService ?? PurchaseServiceStub() {
    _load();
  }

  final SharedPreferences _preferences;
  final RewardedAdService _adService;
  final PurchaseService _purchaseService;

  static const String _subscriptionKey = 'entitlement_subscription_active';
  static const String _removeAdsKey = 'entitlement_remove_ads_lifetime';
  static const String _chartsProKey = 'entitlement_charts_pro_lifetime';
  static const String _favoritesProKey = 'entitlement_favorites_pro_lifetime';
  static const String _favoritesBoostKey = 'favorites_boost_granted_at';

  bool _hasActiveSubscription = false;
  bool _hasRemoveAdsLifetime = false;
  bool _hasChartsProLifetime = false;
  bool _hasFavoritesProLifetime = false;
  int? _favoritesBoostGrantedAtMs;
  bool _tempUnlocksLoaded = false;

  bool get hasActiveSubscription => _hasActiveSubscription;
  bool get hasRemoveAdsLifetime => _hasRemoveAdsLifetime;
  bool get hasChartsProLifetime => _hasChartsProLifetime;
  bool get hasFavoritesProLifetime => _hasFavoritesProLifetime;

  bool get adsEnabled =>
      !_hasActiveSubscription && !_hasRemoveAdsLifetime;

  bool get canSelectAnyChartPair =>
      _hasActiveSubscription || _hasChartsProLifetime;

  bool get canUseIntradayRanges => _hasActiveSubscription;

  bool get canOfferRewardedChartUnlock =>
      !_hasActiveSubscription &&
      !_hasRemoveAdsLifetime &&
      !_hasChartsProLifetime;

  bool get canOfferRewardedFavoritesBoost =>
      !_hasActiveSubscription &&
      !_hasRemoveAdsLifetime &&
      !_hasFavoritesProLifetime;

  static const int favoritesFreeLimit = 3;
  static const int favoritesTempBoostLimit = 6;
  static const int favoritesProLimit = 16;

  int get favoritesEffectiveLimit {
    if (_hasActiveSubscription) return favoritesProLimit;
    if (_hasFavoritesProLifetime) return favoritesProLimit;
    if (hasFavoritesBoostActive) return favoritesTempBoostLimit;
    return favoritesFreeLimit;
  }

  int get favoritesVisibleLimit {
    if (_hasActiveSubscription) return favoritesProLimit;
    if (_hasFavoritesProLifetime) return favoritesProLimit;
    if (hasFavoritesBoostActive) return favoritesTempBoostLimit;
    return favoritesFreeLimit;
  }

  bool get hasFavoritesBoostActive {
    final ms = _favoritesBoostGrantedAtMs;
    if (ms == null) return false;
    final grantedAt = DateTime.fromMillisecondsSinceEpoch(ms);
    return !DateTime.now().isAfter(
      grantedAt.add(const Duration(hours: 24)),
    );
  }

  int favoritesHiddenCount(int storedCount) {
    final visible = favoritesVisibleLimit;
    if (storedCount <= visible) return 0;
    return storedCount - visible;
  }

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
    final unlock =
        _tempUnlocks[TemporaryUnlock.canonicalKey(base, quote)];
    if (unlock != null && !unlock.isExpired) return true;
    return false;
  }

  void _load() {
    _hasActiveSubscription =
        _preferences.getBool(_subscriptionKey) ?? false;
    _hasRemoveAdsLifetime =
        _preferences.getBool(_removeAdsKey) ?? false;
    _hasChartsProLifetime =
        _preferences.getBool(_chartsProKey) ?? false;
    _hasFavoritesProLifetime =
        _preferences.getBool(_favoritesProKey) ?? false;
    _favoritesBoostGrantedAtMs =
        _preferences.getInt(_favoritesBoostKey);
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
          if (!u.isExpired) {
            _tempUnlocks[TemporaryUnlock.canonicalKey(u.base, u.quote)] = u;
          }
        } catch (_) {}
      }
    } catch (_) {}
  }

  Map<String, dynamic> _decodeJsonMap(String source) {
    try {
      return _parseJsonMap(source);
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
          final k = source.substring(i, ks).trim().replaceAll('"', '').trim();
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

  Future<void> setFavoritesProLifetime(bool value) async {
    _hasFavoritesProLifetime = value;
    await _preferences.setBool(_favoritesProKey, value);
    notifyListeners();
  }

  Future<bool> requestRewardedChartUnlock(
    String base,
    String quote,
  ) async {
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

  Future<bool> requestRewardedFavoritesBoost() async {
    if (!canOfferRewardedFavoritesBoost) return false;

    final success = await _adService.showRewardedAd(
      rewardType: 'favorites_boost',
    );
    if (!success) return false;

    _favoritesBoostGrantedAtMs =
        DateTime.now().millisecondsSinceEpoch;
    await _preferences.setInt(
      _favoritesBoostKey,
      _favoritesBoostGrantedAtMs!,
    );
    notifyListeners();
    return true;
  }

  void clearFavoritesBoost() {
    _favoritesBoostGrantedAtMs = null;
    _preferences.remove(_favoritesBoostKey);
    notifyListeners();
  }

  Future<void> grantFavoritesBoost() async {
    _favoritesBoostGrantedAtMs =
        DateTime.now().millisecondsSinceEpoch;
    await _preferences.setInt(
      _favoritesBoostKey,
      _favoritesBoostGrantedAtMs!,
    );
    notifyListeners();
  }

  void clearChartTempUnlocks() {
    _tempUnlocks.clear();
    _preferences.remove('temp_unlocks_registry');
    notifyListeners();
  }

  bool _isFreeDefaultPair(String base, String quote) {
    final freePairs = [('USD', 'EUR'), ('EUR', 'USD')];
    return freePairs.contains((base, quote));
  }

  void clearTempUnlocks() {
    clearChartTempUnlocks();
    clearFavoritesBoost();
  }

  Future<bool> purchaseChartsPro() async {
    final success =
        await _purchaseService.purchase(ProductType.chartsPro);
    if (!success) return false;
    await setChartsProLifetime(true);
    return true;
  }

  Future<bool> purchaseRemoveAds() async {
    final success =
        await _purchaseService.purchase(ProductType.removeAds);
    if (!success) return false;
    await setRemoveAdsLifetime(true);
    return true;
  }

  Future<bool> purchaseFavoritesPro() async {
    final success =
        await _purchaseService.purchase(ProductType.favoritesPro);
    if (!success) return false;
    await setFavoritesProLifetime(true);
    return true;
  }
}
