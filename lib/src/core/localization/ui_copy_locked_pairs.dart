part of 'ui_copy.dart';

String tapToUnlockLabel(BuildContext context) => switch (_lang(context)) {
      'es' => 'Toca para desbloquear',
      'de' => 'Tippen zum Freischalten',
      'it' => 'Tocca per sbloccare',
      'fr' => 'Touchez pour déverrouiller',
      _ => 'Tap to unlock',
    };

String unlockedFor24hLabel(BuildContext context) => switch (_lang(context)) {
      'es' => 'Desbloqueado · quedan 24 h',
      'de' => 'Freigeschaltet · 24 Std. verbleibend',
      'it' => 'Sbloccato · restano 24 h',
      'fr' => 'Déverrouillé · 24 h restantes',
      _ => 'Unlocked · 24h remaining',
    };

String currentCurrencyLabel(BuildContext context, String code) =>
    switch (_lang(context)) {
      'es' => 'Actual $code',
      'de' => 'Aktuell $code',
      'it' => 'Attuale $code',
      'fr' => 'Actuelle $code',
      _ => 'Current $code',
    };

String currentBadgeLabel(BuildContext context) => switch (_lang(context)) {
      'es' => 'Actual',
      'de' => 'Aktuell',
      'it' => 'Attuale',
      'fr' => 'Actuelle',
      _ => 'Current',
    };

String lockedBadgeLabel(BuildContext context) => switch (_lang(context)) {
      'es' => 'Bloqueado',
      'de' => 'Gesperrt',
      'it' => 'Bloccato',
      'fr' => 'Verrouillé',
      _ => 'Locked',
    };

String pairLockedTitle(BuildContext context) => switch (_lang(context)) {
      'es' => 'Este par está bloqueado',
      'de' => 'Dieses Paar ist gesperrt',
      'it' => 'Questa coppia è bloccata',
      'fr' => 'Cette paire est verrouillée',
      _ => 'This pair is locked',
    };

String pairLockedSubtitle(BuildContext context, bool canWatchAd) =>
    switch (_lang(context)) {
      'es' => canWatchAd
          ? 'Elige cómo desbloquearlo'
          : 'Los anuncios con recompensa no están disponibles tras Quitar anuncios',
      'de' => canWatchAd
          ? 'Wähle, wie du es freischalten möchtest'
          : 'Belohnungsanzeigen sind nach Werbung entfernen nicht verfügbar',
      'it' => canWatchAd
          ? 'Scegli come sbloccarla'
          : 'Gli annunci con ricompensa non sono disponibili dopo Rimuovi annunci',
      'fr' => canWatchAd
          ? 'Choisissez comment la déverrouiller'
          : 'Les publicités récompensées ne sont plus disponibles après Supprimer les publicités',
      _ => canWatchAd
          ? 'Choose how to unlock it'
          : 'Rewarded ads are unavailable after Remove Ads',
    };

String watchAdUnlockLabel(BuildContext context) => switch (_lang(context)) {
      'es' => 'Ver anuncio · Desbloquear 24 h',
      'de' => 'Anzeige ansehen · 24 Std. freischalten',
      'it' => 'Guarda annuncio · Sblocca per 24 h',
      'fr' => 'Voir la pub · Déverrouiller 24 h',
      _ => 'Watch ad · Unlock for 24h',
    };

String unlockAllPairsForeverLabel(BuildContext context) =>
    switch (_lang(context)) {
      'es' => 'Desbloquear todos los pares para siempre',
      'de' => 'Alle Paare dauerhaft freischalten',
      'it' => 'Sblocca tutte le coppie per sempre',
      'fr' => 'Déverrouiller toutes les paires pour toujours',
      _ => 'Unlock all pairs forever',
    };
