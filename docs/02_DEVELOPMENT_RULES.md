# Strict Development Rules

These rules represent the absolute constraints of this project. Both developers and AI-agents must strictly follow them without exceptions.

## 1. Development & Version Command Rules
- **Rule**: All commands must use `FVM` (Flutter Version Management).
  - Use `fvm flutter ...` instead of `flutter ...`.
  - Use `fvm dart ...` instead of `dart ...`.

## 2. API Integration & Model Constraints
- **Rule**: Always use the Repository + Model approach. Never invoke Dio/Http directly in the ViewModel or View.
- **Rule (CRITICAL)**: **Always use `json_serializable` when creating models**. Use `@JsonSerializable()`, define `part '<filename>.g.dart';`, and provide `_$ModelFromJson(json)` and `_$ModelToJson(this)`. Use `@JsonKey(name: '...')` for snake_case field mapping.
- **Rule**: Run `build_runner` with `--delete-conflicting-outputs` to generate serialization code (`.g.dart` files).
- **Rule (CRITICAL)**: **Use `fetchListData<T>()` for paginated APIs**. ViewModels managing paginated listings must use `fetchListData<T>()` provided by base `ViewModel` (in `lib/providers/view_model.dart`) with `page`, `canLoadMore`, and `reset()`, instead of maintaining custom pagination page counters or flags.
- **Rule**: Do not assume API contracts. If headers, methods, or request/response structures are missing, stop and request them immediately.

## 3. UI and Sizing Rules
- **Rule**: Sizing must use `ScreenUtil` responsive units.
  - **CRITICAL**: You must strictly use **only** the `.spMin` extension for all sizes, heights, widths, margins, paddings, border radiuses, and font sizes (e.g. `24.spMin`, `EdgeInsets.symmetric(horizontal: 24.spMin)`). Do **not** use other ScreenUtil extensions like `.w`, `.h`, `.r`, or `.sp`.
  - Sizing must match the Figma design spec design size: `const Size(428, 926)` (configured in `main.dart`).
- **Rule**: Use the predefined styling classes inside `lib/utils/styles.dart` (e.g. `tsS14W400`). Do not write ad-hoc `TextStyle` declarations on text widgets.
- **Rule**: Use the predefined color values inside `lib/utils/brand_colors.dart` (via `context.brand`) or `lib/utils/app_palette.dart` (via `context.palette`). Avoid using raw hardcoded hexadecimal color representations (e.g. `Color(0xFF...)`).

## 4. Class & File Naming Conventions (CRITICAL)
- **Rule (CRITICAL)**: Follow strict suffix naming conventions:
  - **Widgets**: Every widget class must end with `Widget` (e.g. `TestWidget`, `LocationDraggableSheetWidget`), and widget files must end with `_widget.dart` (e.g. `test_widget.dart`).
  - **Screens**: Every screen class must end with `Screen` (e.g. `TestScreen`, `EditProfileScreen`), and screen files under `view/` or `views/` must end with `_screen.dart` (e.g. `edit_profile_screen.dart`), **NEVER** `View` or `_view.dart`.
  - **Models**: Every model class must end with `Model` (e.g. `TestModel`, `RideOwnerItemModel`), and model files must end with `_model.dart`.
  - **ViewModels**: Every ViewModel class must end with `ViewModel` (e.g. `TestViewModel`, `BookingsViewModel`), and files must end with `_view_model.dart`. **NEVER** `ScreenModel`.
  - **Helpers**: Every helper class must end with `Helper` (e.g. `TestHelper`, `LocationHelper`), and files must end with `_helper.dart`.
- **Rule**: Always implement routing using **Named Routes** registered in `lib/utils/routes.dart`.
- **Rule**: If a destination view requires arguments, define a strongly-typed `Params` class inside that destination screen file (e.g. `ProfileScreenParams`).
- **Rule**: Retrieve arguments using the `context.getScreenParamsOf<Params>()` extension method rather than raw `ModalRoute` casting inside views.

## 5. Component Reuse, Extraction & Zero-Duplication
- **Rule (CRITICAL)**: If there are more than two widgets or bigger sub-components in a screen, extract them out of the screen file and move them into the feature's `widgets/` folder (e.g. `lib/features/<feature>/widgets/`). Keep screen files thin, clean, and declarative.
- **Rule**: Before writing a new UI component, search the `lib/widgets` directory to see if a matching component (e.g., `AppButton`, `CustomTextField`) already exists.
- **Rule**: Do not duplicate core business flows or utilities. Always check `lib/utils/extensions.dart` and `lib/utils/app_build_methods.dart` for helpers first.

## 6. Localization
- **Rule**: Never use hardcoded String literals in presentation widgets. All copy must be localized using ARB files under `lib/l10n/`.
- **Rule**: Keys inside `.arb` files must follow `lowerCamelCase` formatting.
- **Rule**: After modifying an `.arb` file, run `fvm flutter gen-l10n`.

## 7. Security and Credentials
- **Rule**: Never commit credentials, passwords, private keys, or system-sensitive endpoints to source control.
- **Rule**: Store configurations in the `.env` file and instruct the development environment on the required environment keywords.

## 8. Provider Scoping & State Management
- **Rule**: Do not wrap an entire screen or `Scaffold` in a `Consumer`. Wrap `Consumer` or `Selector` tightly and precisely around only the exact widget that needs the reactive rebuild.
- **Rule**: Use `context.read<T>()` for read-only operations and callbacks (e.g. button clicks, async triggers, `onRefresh`). Never use `context.watch<T>()` in callbacks.
- **Rule**: Do not use `setState()` in views. Keep views as `StatelessWidget`.
- **Rule**: Use `ValueNotifier<T>` paired with `ValueListenableBuilder<T>` for simple local UI state (e.g. toggles, expand/collapse, active tabs).

## 9. Code Quality & Conditional Operators
- **Rule (CRITICAL)**: **Do not use nested conditional (ternary) operators**.
  - A single conditional operator is fine (`isEnabled ? this : that`), but do not go beyond that (e.g., `a ? b : c ? d : e`).
  - Nested conditionals tangle the code and hurt maintainability. Use clear `if`/`else` statements, early returns, or extracted helper getters/methods instead.

