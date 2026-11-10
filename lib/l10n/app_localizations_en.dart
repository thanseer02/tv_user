// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get hello => 'Hello';

  @override
  String get appTitle => 'Smart TV Portal';

  @override
  String get splashLoading => 'Initializing TV Experience...';

  @override
  String get urlListingTitle => 'Select Portal / Stream';

  @override
  String get urlListingSubtitle =>
      'Use your remote D-Pad (Up / Down / Enter) to select a link';

  @override
  String get emptyUrlList => 'No URLs found';

  @override
  String get openUrl => 'Open';

  @override
  String get backToUrls => 'Back to List';

  @override
  String get webViewTitle => 'Web View Portal';

  @override
  String get webViewLoading => 'Loading content...';

  @override
  String get reload => 'Reload';

  @override
  String get exit => 'Exit';

  @override
  String get remoteHelp =>
      'Remote Control: Use Arrow Keys / D-Pad to Navigate • Enter / OK to Select';
}
