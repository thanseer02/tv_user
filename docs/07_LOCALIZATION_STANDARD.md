# Localization Standard

This document details the localization architecture, rules, and commands to manage multilingual support in this application.

## Translations Core & Architecture

The application implements localization using standard **Flutter localizations** (ARB files).

- **Source Translations Directory**: `lib/l10n/`
- **Supported Translation Locales**: English (`app_en.arb`) and Japanese (`app_ja.arb`) (configured inside `main.dart` and the localization yaml settings).
- **Global Helper**: `LanguageProvider` handles switching locales, fetching language lists, and persisting the user's selected language in `SharedPreferences`.

## Rules for ARB Keys & Formatting

1. **Rule**: String values must never be hardcoded in any presentation widget or screen file.
2. **Key Formatting**: Keys inside `.arb` files must follow **`lowerCamelCase`** rules:
   - **Correct**: `"profileTitle": "User Profile"`
   - **Incorrect**: `"Profile_title": "User Profile"`, `"PROFILE_TITLE": "User Profile"`
3. **Translation Content**: Maintain identical key sets across both `app_en.arb` and `app_ja.arb` files to prevent compile-time generation errors.

```json
// Example lib/l10n/app_en.arb
{
  "hello": "Hello",
  "save": "Save",
  "search": "Search"
}
```

## Running the Localization Generator

Whenever you add or modify keys in the `.arb` files, run the translation generator command:

```bash
fvm flutter gen-l10n
```

This updates the auto-generated code and makes the keys available via the `AppLocalizations` class.

## Consuming Localized Text in Widgets

1. **Import the Localization Helper**:
   ```dart
   import 'package:base_project/utils/localization.dart';
   ```
2. **Access the Localized Strings**:
   Use the `Localization.locale` helper to read your keys:
   ```dart
   Text(
     Localization.locale.hello,
     style: tsS16W600,
   )
   ```
3. **Using LanguageProvider**:
   Use the global `LanguageProvider` to change the language or fetch active locales:
   ```dart
   // Change to Japanese
   context.read<LanguageProvider>().setLocale = const Locale('ja');

   // Check active locale
   final isEnglish = context.watch<LanguageProvider>().isEnglish;
   ```
