# AI-Agent Validation Checklist

Use this checklist to verify your work before completing feature implementation. Every item must be satisfied and verified.

## Phase 1: Environment & Setup Verification
- [ ] Commands run are prefixed with `fvm`.
- [ ] No hardcoded secrets exist in the source code; any new config variables are loaded from the environment/`.env`.

## Phase 2: Architecture & Structure Verification
- [ ] All new files reside in `lib/features/<feature_name>/` and are split into `view/`, `view_model/`, `model/`, and `repo/` folders.
- [ ] The new ViewModel class extends `ViewModel` from `lib/providers/view_model.dart`.
- [ ] No API or remote network operations are called directly in the View or ViewModel; all API calls go through the feature's repository.
- [ ] Endpoints are registered inside `lib/utils/urls.dart`.

## Phase 3: Code Generation & Models
- [ ] The API response models contain `@JsonSerializable()` mappings.
- [ ] Conflicting code files were cleared and generated using:
  ```bash
  fvm flutter pub run build_runner build --delete-conflicting-outputs
  ```
- [ ] The generated `.g.dart` files compile without warnings or errors.

## Phase 4: UI & UX Standards
- [ ] The view coordinates responsive design sizes using `ScreenUtil`.
- [ ] Font size changes **always** use `.spMin` to ensure legibility on smaller screens.
- [ ] Text widgets consume pre-constructed styles from `lib/utils/styles.dart` instead of writing custom `TextStyle` declarations.
- [ ] Colors are fetched from the theme extension using `context.brand` or `context.palette` instead of using raw hex codes.
- [ ] Async API actions are wrapped in loading visual feedback using the `.showCircleProgressOnCenter<VM>()` or `.setProgress(this)` extensions.
- [ ] Empty state conditions are handled gracefully using the `.orShowEmptyWidget` extension.

## Phase 5: Routing & Arguments
- [ ] The route name is defined as a static const string inside the screen file.
- [ ] Arguments are encapsulated inside a custom `Params` class.
- [ ] The route is registered in `lib/utils/routes.dart` and supports parameter casting.
- [ ] The screen retrieves its arguments using `context.getScreenParamsOf<Params>()`.

## Phase 6: Localization & Translations
- [ ] All text labels are localized using ARB translation templates in `lib/l10n/`.
- [ ] Every ARB key is formatted in `lowerCamelCase`.
- [ ] Translations were compiled and validated using:
  ```bash
  fvm flutter gen-l10n
  ```

## Phase 7: Compilation & Quality Check
- [ ] The project builds and compiles successfully without any Dart analyzer warnings.
- [ ] Checked for duplicate code or methods that could be shared in `lib/utils/extensions.dart`.
