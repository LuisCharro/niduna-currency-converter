import 'package:flutter/widgets.dart';

import 'app_localizations.dart';
import 'app_localizations_en.dart';

AppLocalizations l10n(BuildContext context) {
  return AppLocalizations.of(context) ?? AppLocalizationsEn();
}
