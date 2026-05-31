import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/temporary_unlock.dart';

class MonetizationEntitlements {
  MonetizationEntitlements(this.preferences);

  final SharedPreferences preferences;

  static const String _subscriptionKey = 'entitlement_subscription_active';
  static const String _removeAdsKey = 'entitlement_remove_ads_lifetime';
  static const String _chartsProKey = 'entitlement_charts_pro_lifetime';
  static const String _favoritesProKey = 'entitlement_favorites_pro_lifetime';
  static const String _favoritesBoostKey = 'favorites_boost_granted_at';

  bool hasActiveSubscription = false;
  bool hasRemoveAdsLifetime = false;
  bool hasChartsProLifetime = false;
  bool hasFavoritesProLifetime = false;
  int? favoritesBoostGrantedAtMs;

  final Map<String, TemporaryUnlock> tempUnlocks = {};

  bool get adsEnabled => !hasActiveSubscription && !hasRemoveAdsLifetime;

  bool get canSelectAnyChartPair =>
      hasActiveSubscription || hasChartsProLifetime;

  bool get canUseIntradayRanges => hasActiveSubscription;

  bool get canOfferRewardedChartUnlock =>
      !hasActiveSubscription &&
      !hasRemoveAdsLifetime &&
      !hasChartsProLifetime;

  bool get canOfferRewardedFavoritesBoost =>
      !hasActiveSubscription &&
      !hasRemoveAdsLifetime &&
      !hasFavoritesProLifetime;

  bool get hasFavoritesBoostActive {
    final ms = favoritesBoostGrantedAtMs;
    if (ms == null) return false;
    final grantedAt = DateTime.fromMillisecondsSinceEpoch(ms);
    return !DateTime.now().isAfter(grantedAt.add(const Duration(hours: 24)));
  }

  void load() {
    hasActiveSubscription = preferences.getBool(_subscriptionKey) ?? false;
    hasRemoveAdsLifetime = preferences.getBool(_removeAdsKey) ?? false;
    hasChartsProLifetime = preferences.getBool(_chartsProKey) ?? false;
    hasFavoritesProLifetime = preferences.getBool(_favoritesProKey) ?? false;
    favoritesBoostGrantedAtMs = preferences.getInt(_favoritesBoostKey);
  }

  Future<void> loadTempUnlocks() async {
    final raw = preferences.getString('temp_unlocks_registry');
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = _decodeJsonMap(raw);
      for (final entry in decoded.entries) {
        try {
          final u = TemporaryUnlock.fromJson(entry.value);
          if (!u.isExpired) {
            tempUnlocks[TemporaryUnlock.canonicalKey(u.base, u.quote)] = u;
          }
        } catch (_) {}
      }
    } catch (_) {}
  }

  Map<String, dynamic> _decodeJsonMap(String source) {
    try {
      return jsonDecode(source) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> setSubscriptionActive(bool value) async {
    hasActiveSubscription = value;
    await preferences.setBool(_subscriptionKey, value);
  }

  Future<void> setRemoveAdsLifetime(bool value) async {
    hasRemoveAdsLifetime = value;
    await preferences.setBool(_removeAdsKey, value);
  }

  Future<void> setChartsProLifetime(bool value) async {
    hasChartsProLifetime = value;
    await preferences.setBool(_chartsProKey, value);
  }

  Future<void> setFavoritesProLifetime(bool value) async {
    hasFavoritesProLifetime = value;
    await preferences.setBool(_favoritesProKey, value);
  }

  Future<void> setFavoritesBoostNow() async {
    favoritesBoostGrantedAtMs = DateTime.now().millisecondsSinceEpoch;
    await preferences.setInt(_favoritesBoostKey, favoritesBoostGrantedAtMs!);
  }

  void clearFavoritesBoost() {
    favoritesBoostGrantedAtMs = null;
    preferences.remove(_favoritesBoostKey);
  }

  void clearChartTempUnlocks() {
    tempUnlocks.clear();
    preferences.remove('temp_unlocks_registry');
  }

  bool isFreeDefaultPair(String base, String quote) {
    final freePairs = [('USD', 'EUR'), ('EUR', 'USD')];
    return freePairs.contains((base, quote));
  }

  bool isChartPairUnlocked(String base, String quote) {
    if (isFreeDefaultPair(base, quote)) return true;
    if (hasActiveSubscription) return true;
    if (hasChartsProLifetime) return true;
    final unlock = tempUnlocks[TemporaryUnlock.canonicalKey(base, quote)];
    if (unlock != null && !unlock.isExpired) return true;
    return false;
  }

  Set<String> tempUnlockedCodes() => tempUnlocks.keys.toSet();
}
