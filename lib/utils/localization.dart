import 'package:base_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Top-level shorthand getter: `l10n.someString`
AppLocalizations get l10n => Localization.locale;

class Localization {
  static late BuildContext _context;
  static BuildContext get context => _context;
  Localization.init(BuildContext context) {
    _context = context;
  }
  static AppLocalizations get locale {
    return AppLocalizations.of(context)!;
  }

  /// Static shorthand getter: `Localization.l10n.someString`
  static AppLocalizations get l10n => locale;
}

/// Extension on [BuildContext] for widget tree access: `context.l10n.someString`
extension LocalizationContextExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
