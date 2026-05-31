import '../../../../l10n/app_localizations.dart';
import '../../../core/monetization/purchase_service.dart';

String iapProductName(AppLocalizations? l10n, ProductType product) {
  switch (product) {
    case ProductType.removeAds:
      return l10n?.removingAds ?? "Removing Ads";
    case ProductType.chartsPro:
      return l10n?.unlockingPairs ?? "Unlocking all pairs";
    case ProductType.favoritesPro:
      return l10n?.unlockingFavoritesPro ?? 'Unlocking Favorites Pro';
    case ProductType.subscription:
      return l10n?.startingSubscription ?? "Starting subscription";
  }
}

String iapSuccessMessage(AppLocalizations? l10n, ProductType product) {
  switch (product) {
    case ProductType.removeAds:
      return l10n?.adsRemovedForever ?? 'All ads removed forever';
    case ProductType.chartsPro:
      return l10n?.allPairsUnlocked ?? 'All chart pairs unlocked';
    case ProductType.favoritesPro:
      return l10n?.favoritesProUnlocked ?? 'Up to 16 favorite pairs unlocked';
    case ProductType.subscription:
      return l10n?.subscriptionActive ?? 'Subscription active';
  }
}
