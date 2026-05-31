import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/temporary_unlock.dart';
import 'monetization_entitlements.dart';
import 'purchase_service.dart';
import 'purchase_service_stub.dart';
import 'rewarded_ad_service.dart';
import 'rewarded_ad_service_stub.dart';
import 'temporary_unlock_store.dart';

class MonetizationController extends ChangeNotifier {
  MonetizationController(
    SharedPreferences preferences, {
    RewardedAdService? adService,
    PurchaseService? purchaseService,
  }) : _entitlements = MonetizationEntitlements(preferences),
       _adService = adService ?? RewardedAdServiceStub(),
       _purchaseService = purchaseService ?? PurchaseServiceStub() {
    _entitlements.load();
  }

  final MonetizationEntitlements _entitlements;
  final RewardedAdService _adService;
  final PurchaseService _purchaseService;

  static const int favoritesFreeLimit = 3;
  static const int favoritesTempBoostLimit = 6;
  static const int favoritesProLimit = 16;

  bool get hasActiveSubscription => _entitlements.hasActiveSubscription;
  bool get hasRemoveAdsLifetime => _entitlements.hasRemoveAdsLifetime;
  bool get hasChartsProLifetime => _entitlements.hasChartsProLifetime;
  bool get hasFavoritesProLifetime => _entitlements.hasFavoritesProLifetime;

  bool get adsEnabled => _entitlements.adsEnabled;
  bool get canSelectAnyChartPair => _entitlements.canSelectAnyChartPair;
  bool get canUseIntradayRanges => _entitlements.canUseIntradayRanges;
  bool get hasFavoritesBoostActive => _entitlements.hasFavoritesBoostActive;
  bool get canOfferRewardedChartUnlock =>
      _entitlements.canOfferRewardedChartUnlock;
  bool get canOfferRewardedFavoritesBoost =>
      _entitlements.canOfferRewardedFavoritesBoost;

  int get favoritesEffectiveLimit {
    if (_entitlements.hasActiveSubscription) return favoritesProLimit;
    if (_entitlements.hasFavoritesProLifetime) return favoritesProLimit;
    if (_entitlements.hasFavoritesBoostActive) return favoritesTempBoostLimit;
    return favoritesFreeLimit;
  }

  int get favoritesVisibleLimit {
    if (_entitlements.hasActiveSubscription) return favoritesProLimit;
    if (_entitlements.hasFavoritesProLifetime) return favoritesProLimit;
    if (_entitlements.hasFavoritesBoostActive) return favoritesTempBoostLimit;
    return favoritesFreeLimit;
  }

  int favoritesHiddenCount(int storedCount) {
    final visible = favoritesVisibleLimit;
    if (storedCount <= visible) return 0;
    return storedCount - visible;
  }

  bool _tempUnlocksLoaded = false;

  Set<String> get tempUnlockedCodes {
    if (!_tempUnlocksLoaded) {
      _tempUnlocksLoaded = true;
      loadTempUnlocks();
    }
    return _entitlements.tempUnlockedCodes();
  }

  bool isChartPairUnlocked(String base, String quote) =>
      _entitlements.isChartPairUnlocked(base, quote);

  Future<void> loadTempUnlocks() async {
    await _entitlements.loadTempUnlocks();
    notifyListeners();
  }

  Future<void> setSubscriptionActive(bool value) async {
    await _entitlements.setSubscriptionActive(value);
    notifyListeners();
  }

  Future<void> setRemoveAdsLifetime(bool value) async {
    await _entitlements.setRemoveAdsLifetime(value);
    notifyListeners();
  }

  Future<void> setChartsProLifetime(bool value) async {
    await _entitlements.setChartsProLifetime(value);
    notifyListeners();
  }

  Future<void> setFavoritesProLifetime(bool value) async {
    await _entitlements.setFavoritesProLifetime(value);
    notifyListeners();
  }

  Future<bool> requestRewardedChartUnlock(String base, String quote) async {
    if (!_entitlements.canOfferRewardedChartUnlock) return false;

    final success = await _adService.showRewardedAd(
      rewardType: 'chart_pair_unlock',
    );
    if (!success) return false;

    final store = TemporaryUnlockStore(_entitlements.preferences);
    final unlock = TemporaryUnlock(
      base: base,
      quote: quote,
      grantedAt: DateTime.now(),
    );
    await store.save(unlock);
    _entitlements.tempUnlocks[TemporaryUnlock.canonicalKey(base, quote)] =
        unlock;
    notifyListeners();
    return true;
  }

  Future<bool> requestRewardedFavoritesBoost() async {
    if (!_entitlements.canOfferRewardedFavoritesBoost) return false;

    final success = await _adService.showRewardedAd(
      rewardType: 'favorites_boost',
    );
    if (!success) return false;

    await _entitlements.setFavoritesBoostNow();
    notifyListeners();
    return true;
  }

  void clearFavoritesBoost() {
    _entitlements.clearFavoritesBoost();
    notifyListeners();
  }

  Future<void> grantFavoritesBoost() async {
    await _entitlements.setFavoritesBoostNow();
    notifyListeners();
  }

  void clearChartTempUnlocks() {
    _entitlements.clearChartTempUnlocks();
    notifyListeners();
  }

  void clearTempUnlocks() {
    clearChartTempUnlocks();
    clearFavoritesBoost();
  }

  Future<bool> purchaseChartsPro() async {
    final success = await _purchaseService.purchase(ProductType.chartsPro);
    if (!success) return false;
    await setChartsProLifetime(true);
    return true;
  }

  Future<bool> purchaseRemoveAds() async {
    final success = await _purchaseService.purchase(ProductType.removeAds);
    if (!success) return false;
    await setRemoveAdsLifetime(true);
    return true;
  }

  Future<bool> purchaseFavoritesPro() async {
    final success = await _purchaseService.purchase(ProductType.favoritesPro);
    if (!success) return false;
    await setFavoritesProLifetime(true);
    return true;
  }
}
