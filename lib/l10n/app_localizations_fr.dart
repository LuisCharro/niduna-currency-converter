// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Convertisseur de devises';

  @override
  String get tabConvert => 'Convertir';

  @override
  String get tabFavorites => 'Favoris';

  @override
  String get tabCharts => 'Graphique';

  @override
  String get tabSettings => 'Réglages';

  @override
  String get btnSwap => 'Échanger';

  @override
  String get btnClear => 'Effacer';

  @override
  String get btnRemove => 'Retirer';

  @override
  String get btnAdd => 'Ajouter des devises';

  @override
  String get btnDone => 'Terminé';

  @override
  String get btnCancel => 'Annuler';

  @override
  String get btnBuy => 'Acheter';

  @override
  String get btnRefresh => 'Actualiser';

  @override
  String get labelFrom => 'De';

  @override
  String get labelTo => 'À';

  @override
  String get labelAmount => 'Montant';

  @override
  String get labelResult => 'Résultat';

  @override
  String get labelRate => 'Taux';

  @override
  String get labelLastUpdated => 'Dernière mise à jour';

  @override
  String get labelNoFavorites =>
      'Épinglez les paires que vous consultez le plus';

  @override
  String get labelAddFavorite => 'Ajouter un favori';

  @override
  String get favoritesLocalSubtitle =>
      'Paires locales enregistrées sur cet appareil';

  @override
  String favoritesEmptyBody(Object limit) {
    return 'Balayez une devise vers la gauche dans Convertir, puis touchez Favori. Jusqu\'à $limit paires, gratuit.';
  }

  @override
  String get favoritesOpenConvert => 'Ouvrir Convertir';

  @override
  String get favoritesLimitMessage =>
      'Vous pouvez épingler jusqu\'à 3 paires dans cette version.';

  @override
  String get favoritesCachedRate => 'Taux quotidien enregistré';

  @override
  String get favoritesRateUnavailable => '--';

  @override
  String get removeFavoriteTooltip => 'Retirer le favori';

  @override
  String get reorderFavoriteTooltip => 'Réorganiser le favori';

  @override
  String get openFavoriteTooltip => 'Ouvrir la paire dans Convertir';

  @override
  String get favoriteActionPin => 'Favori';

  @override
  String get favoriteActionSaved => 'En favori';

  @override
  String get labelRemoveAds => 'Supprimer les publicités';

  @override
  String get labelAbout => 'À propos';

  @override
  String get labelVersion => 'Version';

  @override
  String get labelPrivacy => 'Politique de confidentialité';

  @override
  String get privacyOptionsTitle => 'Options de confidentialité';

  @override
  String get privacyOptionsSubtitle =>
      'Gérer le consentement publicitaire et les choix de confidentialité';

  @override
  String get labelNoAccount => 'Aucun compte';

  @override
  String get labelNoCloudSync => 'Pas de synchronisation cloud';

  @override
  String get labelNoAnalytics => 'Pas d\'analyse';

  @override
  String get labelOfflineMode => 'Mode hors ligne';

  @override
  String get labelCachedRates => 'Taux en cache';

  @override
  String get labelConversion => 'Conversion';

  @override
  String get labelData => 'Données';

  @override
  String get labelPremium => 'Premium';

  @override
  String get labelDefaultBaseCurrency => 'Devise de base par défaut';

  @override
  String get labelDecimalPlaces => 'Décimales';

  @override
  String get labelRefreshOnOpen => 'Actualiser à l\'ouverture';

  @override
  String get labelRefreshOnOpenSubtitle =>
      'Récupérer les nouveaux taux au démarrage de l\'app';

  @override
  String get labelClearAllData => 'Effacer les données enregistrées';

  @override
  String get labelClearAllDataSubtitle =>
      'Taux, historique des graphiques et déverrouillages temporaires. Favoris et réglages conservés.';

  @override
  String get labelRestorePurchases => 'Restaurer les achats';

  @override
  String get labelRestorePurchasesSubtitle =>
      'Revérifier les achats locaux sur cet appareil';

  @override
  String get premiumUnlocks => 'Avantages Premium';

  @override
  String get premiumActive => 'Premium actif';

  @override
  String get oneTimePurchaseNote => 'Achats uniques ; aucun compte requis.';

  @override
  String get paidUnlocksStay => 'Les achats restent sur cet appareil.';

  @override
  String get ownedOnDevice => 'Acheté sur cet appareil';

  @override
  String get chartsProTitle => 'Charts Pro';

  @override
  String get dataSourcesSubtitle => 'Un résumé et tes choix de confidentialité';

  @override
  String get versionTapHint =>
      'Touchez 7 fois pour débloquer les options développeur';

  @override
  String get noRatesTitle => 'Pas encore de taux';

  @override
  String get noRatesSubtitle =>
      'Tirez pour actualiser ou appuyez sur synchroniser lorsque vous êtes de nouveau en ligne';

  @override
  String get dailyRatesTitle => 'Taux de change quotidiens';

  @override
  String get quickAmounts => 'Montants rapides';

  @override
  String get amountSheetTitle => 'Saisir le montant';

  @override
  String get selectBaseCurrency => 'Sélectionner la devise de base';

  @override
  String get searchCurrencies => 'Devise, pays ou code';

  @override
  String get searchCodeOrName => 'Rechercher un code ou un nom';

  @override
  String get addCurrenciesTitle => 'Ajouter des devises';

  @override
  String get conversionLensTitle => 'Loupe de conversion';

  @override
  String get staleRateWarning =>
      'Taux obsolètes — les valeurs peuvent différer du marché actuel';

  @override
  String get errorNetworkFailed =>
      'Erreur réseau. Utilisation des taux en cache.';

  @override
  String get errorNoData => 'Aucune donnée disponible';

  @override
  String get msgFavoriteAdded => 'Favori ajouté';

  @override
  String get msgFavoriteRemoved => 'Favori supprimé';

  @override
  String get purchasing => 'Achat en cours…';

  @override
  String get processingPayment => 'Traitement du paiement…';

  @override
  String get purchaseComplete => 'Achat terminé !';

  @override
  String get purchaseFailed => 'Échec de l\'achat';

  @override
  String get pleaseWait => 'Veuillez patienter…';

  @override
  String get tryAgainLater => 'Réessayez plus tard';

  @override
  String get removingAds => 'Suppression des publicités…';

  @override
  String get unlockingPairs => 'Déverrouillage de toutes les paires…';

  @override
  String get startingSubscription => 'Démarrage de l\'abonnement…';

  @override
  String get adsRemovedForever =>
      'Toutes les publicités supprimées pour toujours';

  @override
  String get allPairsUnlocked =>
      'Toutes les paires de graphiques déverrouillées';

  @override
  String get subscriptionActive => 'Abonnement actif';

  @override
  String get dataDetailsTitle => 'Données et confidentialité';

  @override
  String get dataPolicyTitle => 'Politique quotidienne des données';

  @override
  String get dataPrivacyLine =>
      'Tes favoris et réglages restent sur cet appareil. Des services externes fournissent les taux et Google affiche des annonces lorsqu’elles sont activées.';

  @override
  String get updatesTitle => 'Mises à jour';

  @override
  String get updatesLine1 =>
      'Ce sont des taux journaliers indicatifs, pas des prix en temps réel.';

  @override
  String get updatesLine2 =>
      'Si l’actualisation à l’ouverture est activée, l’app vérifie les mises à jour à la première ouverture de la journée.';

  @override
  String get updatesLine3 =>
      'Vous pouvez actualiser manuellement à tout moment.';

  @override
  String get fiatDataTitle => 'Données fiat';

  @override
  String get fiatDataLine1 =>
      'Taux fiat : Frankfurter, avec des données publiques de banques centrales.';

  @override
  String get fiatDataLine2 =>
      'Les graphiques fiat affichent jusqu’à 2 ans d’historique quotidien.';

  @override
  String get fiatDataLine3 =>
      'Les taux enregistrés sont disponibles hors ligne.';

  @override
  String get cryptoDataTitle => 'Données crypto';

  @override
  String get clearDataTitle => 'Données enregistrées';

  @override
  String get clearDataLine1 =>
      'Efface les taux fiat et crypto enregistrés et l’historique des graphiques.';

  @override
  String get clearDataLine2 =>
      'Efface aussi les déverrouillages temporaires des graphiques.';

  @override
  String get clearDataLine3 =>
      'Les favoris, le thème et les réglages de l’app sont conservés.';

  @override
  String get favoritesProTitle => 'Favorites Pro';

  @override
  String get favoritesLimitMessageUpgrade =>
      'Pin up to 3 pairs. Watch an ad or upgrade to add more.';

  @override
  String favoritesPairsHidden(Object count) {
    return '$count paires masquées';
  }

  @override
  String get favoritesWatchAdToShow => 'Regarder une pub pour tout voir';

  @override
  String get favoritesUnlockForever => 'Débloquer 16 paires pour toujours';

  @override
  String get favoritesLimitReached => 'Favorites limit reached';

  @override
  String favoritesLimitActionSubtitle(Object freeLimit, Object storedCount) {
    return 'You\'ve pinned $storedCount of $freeLimit free pairs';
  }

  @override
  String get watchAdToAddMore => 'Regarder une pub pour ajouter 3 de plus';

  @override
  String get unlockingFavoritesPro => 'Unlocking Favorites Pro';

  @override
  String get favoritesProUnlocked => 'Up to 16 favorite pairs unlocked';

  @override
  String get refreshRatesTooltip => 'Actualiser les taux';

  @override
  String get shareRatesTooltip => 'Partager les taux';

  @override
  String get openSettingsTooltip => 'Réglages';

  @override
  String get closeTooltip => 'Fermer';

  @override
  String get removeCurrencyLabel => 'Supprimer la devise';

  @override
  String get toggleFavoriteLabel => 'Ajouter ou retirer des favoris';

  @override
  String get setAsBaseLabel => 'Définir comme devise de base';

  @override
  String get swapCurrenciesTooltip => 'Échanger les devises';

  @override
  String get rateFreshnessInfoLabel => 'Infos sur la fraîcheur des taux';

  @override
  String get changeChartPairLabel => 'Changer la paire du graphique';

  @override
  String changeBaseCurrencyLabel(String code) {
    return 'Changer la devise de base, actuellement $code';
  }

  @override
  String editAmountLabel(String amount) {
    return 'Modifier le montant, actuellement $amount';
  }

  @override
  String openPairLabel(String code) {
    return 'Ouvrir la conversion $code';
  }

  @override
  String chartRangeLabel(String range) {
    return 'Période $range';
  }

  @override
  String get cryptoDataSourceLine =>
      'Taux et graphiques crypto : exchange-api de fawazahmed0.';

  @override
  String get clearDataDialogTitle => 'Effacer les données enregistrées ?';

  @override
  String get snackCacheCleared => 'Cache vidé';

  @override
  String get snackRestoreChecking => 'Vérification de vos achats…';

  @override
  String get labelThemeMode => 'Thème';

  @override
  String get themeModeSystem => 'Système';

  @override
  String get themeModeLight => 'Clair';

  @override
  String get themeModeDark => 'Sombre';

  @override
  String get labelSendFeedback => 'Envoyer des commentaires';

  @override
  String get sendFeedbackSubtitle =>
      'Questions, idées ou bugs — nous lisons tout';

  @override
  String feedbackEmailSubject(String version) {
    return 'Retour sur Currency Converter ($version)';
  }

  @override
  String snackNoEmailApp(String email) {
    return 'Aucune application de messagerie trouvée — contactez-nous à $email';
  }

  @override
  String favoritesMorePairsHeader(Object effectiveLimit, Object visibleCount) {
    return 'AUTRES PAIRES · $visibleCount SUR $effectiveLimit';
  }

  @override
  String get favoritesAddPairSlot => 'Ajouter une paire';

  @override
  String get favoritesWantMorePairs => 'Plus de paires ?';

  @override
  String get favoritesWatchAdPillLabel => 'Pub +3';

  @override
  String get favoritesProPillLabel => '16 à vie';

  @override
  String get favoritesFirstPairPreview => 'Votre première paire apparaît ici';

  @override
  String get convertFromTitle => 'Convertir depuis';

  @override
  String get savedCurrenciesSubtitle => 'Choisissez une devise de votre liste';

  @override
  String get addAnotherCurrency => 'Ajouter une autre devise…';

  @override
  String convertFromCurrency(String code) {
    return 'Convertir depuis $code';
  }

  @override
  String get btnUndo => 'Annuler';

  @override
  String get convertSwipeActionsExplanation =>
      'Changez la devise de base, ajoutez un favori ou supprimez.';

  @override
  String get favoritesSwipeHint =>
      'Balayez vers la gauche pour supprimer une paire enregistrée.';

  @override
  String currencyRemoved(String code) {
    return '$code supprimée de votre liste';
  }

  @override
  String get expandChartTooltip => 'Afficher en paysage';

  @override
  String get collapseChartTooltip => 'Revenir en portrait';

  @override
  String get chartAdLoading => 'Chargement de la publicité…';

  @override
  String get chartAdUnavailable => 'Publicité indisponible';

  @override
  String get chartAdInstructions =>
      'Suivez les instructions de la publicité pour obtenir la récompense';

  @override
  String get dataSummaryRates =>
      'Taux journaliers indicatifs, pas des cours en temps réel. Si Actualiser à l’ouverture est activé, l’app vérifie les données à la première ouverture du jour. Tu peux aussi actualiser manuellement. Les taux enregistrés fonctionnent hors ligne.';

  @override
  String get rateSourcesTitle => 'Sources des données';

  @override
  String get rateSourcesIntro =>
      'Taux fiat : Frankfurter. Taux crypto : exchange-api.';

  @override
  String get chartDataHelpTitle => 'À propos des données du graphique';
}
