// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get hello => 'こんにちは';

  @override
  String get appTitle => 'スマートTVポータル';

  @override
  String get splashLoading => 'TV環境を初期化中...';

  @override
  String get urlListingTitle => 'ポータル / リンクを選択';

  @override
  String get urlListingSubtitle => 'リモコンの十字キー(上下/決定)で選択してください';

  @override
  String get emptyUrlList => 'URLが見つかりません';

  @override
  String get openUrl => '開く';

  @override
  String get backToUrls => '一覧に戻る';

  @override
  String get webViewTitle => 'Webポータル';

  @override
  String get webViewLoading => 'コンテンツを読み込み中...';

  @override
  String get reload => '再読み込み';

  @override
  String get exit => '終了';

  @override
  String get remoteHelp => 'リモコン: 矢印キーで移動 • 決定キーで選択';
}
