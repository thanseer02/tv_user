# Project Bootstrap Guide

This document describes the environment and initial setup rules for the Flutter MVVM base project.

## FVM (Flutter Version Management)

All development operations **must** use FVM to ensure version consistency. The project specifies the Flutter version in `.fvmrc` or `.fvm/fvm_config.json`.

- **Active Flutter SDK Version**: `3.29.3` (or as defined in `.fvmrc`)
- **FVM Commands Prefix**: All `flutter` and `dart` commands must be prefixed with `fvm`.
  - Fetch dependencies: `fvm flutter pub get`
  - Run build runner: `fvm flutter pub run build_runner build --delete-conflicting-outputs`
  - Run app: `fvm flutter run`
  - Localization generation: `fvm flutter gen-l10n`

## Environment & Configuration Management

The application manages environment-specific variables and credentials via clean configuration architectures.

1. **Build Environments**:
   - Enumerated in `lib/utils/enums.dart` (`EnumBuildEnvironment.live`, `EnumBuildEnvironment.uat`, `EnumBuildEnvironment.dg`).
   - The selected environment is configured in `lib/configs/app_configs.dart` under `AppConfig.server`.
   - URL matching is resolved dynamically inside `lib/helpers/url_helpers.dart`.

2. **Sensitive Secrets & Keys**:
   - **Rule**: No secrets (API keys, client secrets, sensitive URLs) should be hardcoded in any Dart file.
   - All sensitive credentials must be stored in a `.env` file at the project root.
   - The developer should keep `.env` excluded from source control (present in `.gitignore`) and provide instructions or keywords for dynamic loading.

## Quick-Start Bootstrap Commands

Run these commands in order to bootstrap the project after cloning:

```bash
# 1. Ensure FVM is installed and install the required Flutter version
fvm install

# 2. Get dependencies
fvm flutter pub get

# 3. Generate localized string classes
fvm flutter gen-l10n

# 4. Generate JSON serializable models
fvm flutter pub run build_runner build --delete-conflicting-outputs
```
