# FairRide Customer – Agent Execution Guidelines

This file serves as the primary entry point and source of truth for **all AI agents and pairing assistants** working on this codebase.

> **CRITICAL MANDATE**: Before writing, modifying, or deleting any code, the agent **MUST** check, respect, and strictly adhere to the guidelines and protocols documented in the [`docs/`](docs/) directory.

---

## 📚 Documentation Index (`docs/`)

Whenever executing user requests, reference the corresponding documentation files:

| Document | Purpose & Scope |
| :--- | :--- |
| [00_PROJECT_BOOTSTRAP.md](docs/00_PROJECT_BOOTSTRAP.md) | Setup, dependencies, and environment bootstrap guidelines |
| [01_ARCHITECTURE_SOURCE_OF_TRUTH.md](docs/01_ARCHITECTURE_SOURCE_OF_TRUTH.md) | Core MVVM pattern, Provider layers, and file structure |
| [02_DEVELOPMENT_RULES.md](docs/02_DEVELOPMENT_RULES.md) | Absolute development rules, sizing units, styles, and routing |
| [03_FEATURE_BUILD_WORKFLOW.md](docs/03_FEATURE_BUILD_WORKFLOW.md) | Step-by-step checklist for constructing new features |
| [04_API_INTEGRATION_STANDARD.md](docs/04_API_INTEGRATION_STANDARD.md) | Repository extensions on `WebAPIService`, model parsing, and Dio rules |
| [05_UI_IMPLEMENTATION_STANDARD.md](docs/05_UI_IMPLEMENTATION_STANDARD.md) | Visual design, theme palettes, Figma dimensions, and layout rules |
| [06_COMPONENT_REUSE_PROTOCOL.md](docs/06_COMPONENT_REUSE_PROTOCOL.md) | Discovery and usage of common widgets in `lib/widgets/` |
| [07_LOCALIZATION_STANDARD.md](docs/07_LOCALIZATION_STANDARD.md) | Multilingual localization practices (`.arb` keys, `gen-l10n`) |
| [08_AGENT_EXECUTION_PROTOCOL.md](docs/08_AGENT_EXECUTION_PROTOCOL.md) | AI agent exploration requirements and strict file modification boundaries |
| [09_AGENT_QUESTIONNAIRE.md](docs/09_AGENT_QUESTIONNAIRE.md) | Clarification protocol when requirements or API schemas are ambiguous |
| [10_AGENT_CHECKLIST.md](docs/10_AGENT_CHECKLIST.md) | Pre-execution and post-execution verification checklist |
| [11_KNOWN_PATTERNS.md](docs/11_KNOWN_PATTERNS.md) | Established code patterns and reference implementations |
| [12_ANTI_PATTERNS.md](docs/12_ANTI_PATTERNS.md) | Strictly prohibited antipatterns to prevent regressions |
| [13_NOTIFICATIONS.md](docs/13_NOTIFICATIONS.md) | Local and remote push notification guidelines |
| [14_PAGINATION_STANDARD.md](docs/14_PAGINATION_STANDARD.md) | Standard pagination guidelines, `ListScrollMoreWidget`, and `fetchListData` |

---

## ⚡ Core Rules Cheat Sheet

### 1. Sizing & Responsive Units (CRITICAL)
- **Only `.spMin` is permitted** for heights, widths, paddings, margins, border radiuses, and font sizes (e.g. `16.spMin`, `EdgeInsets.all(12.spMin)`).
- **NEVER** use `.w`, `.h`, `.r`, or standard `.sp`.

### 2. Typography & Colors
- **Typography**: Always use predefined text styles from [`lib/utils/styles.dart`](lib/utils/styles.dart) (e.g., `tsS14W400`, `tsS16W600`, `tsS20W700`). Do not write custom `TextStyle(...)` blocks.
- **Colors**: Always use [`AppColors()`](lib/utils/colors.dart) or palette tokens. Avoid raw hardcoded hex colors (`Color(0xFF...)`).

### 3. Architecture & State Management (CRITICAL)
- **MVVM + Provider**:
  - Views / Screens (`lib/features/<feature>/view/` or `views/`) are thin; contain no business logic or API calls.
  - ViewModels (`lib/features/<feature>/view_model/` or `view_models/`) extend `ViewModel` from [`lib/providers/view_model.dart`](lib/providers/view_model.dart), and their classes must always end with `ViewModel` (e.g. `BookingsViewModel`, `EditProfileViewModel`), **NEVER** `ScreenModel`.
  - Data repositories (`lib/features/<feature>/repo/`) are implemented as extensions on `WebAPIService`.
- **Strict Suffix Naming Conventions (CRITICAL)**:
  - **Widgets**: Every widget class must end with `Widget` (e.g., `TestWidget`), and widget files must end with `_widget.dart` (e.g., `test_widget.dart`).
  - **Screens**: Every screen class must end with `Screen` (e.g., `TestScreen`), and screen files under `view/` or `views/` must end with `_screen.dart` (e.g., `test_screen.dart`), **NEVER** `View` or `_view.dart`.
  - **Models**: Every model class must end with `Model` (e.g., `TestModel`), and model files must end with `_model.dart` (e.g., `test_model.dart`).
  - **ViewModels**: Every ViewModel class must end with `ViewModel` (e.g., `TestViewModel`), and files must end with `_view_model.dart`.
  - **Helpers**: Every helper class must end with `Helper` (e.g., `TestHelper`, `LocationHelper`), and files must end with `_helper.dart`.
- **Models & Serialization (CRITICAL)**: **Always use `json_serializable` when creating models**. Every model must use `@JsonSerializable()`, define `part '<filename>.g.dart';`, and provide `factory Model.fromJson(Map<String, dynamic> json) => _$ModelFromJson(json);` and `Map<String, dynamic> toJson() => _$ModelToJson(this);`. Use `@JsonKey(name: '...')` for snake_case field mappings.
- **ViewModel Repository Invocation Pattern (`.setProgress(this)`) (CRITICAL)**:
  - Repositories are always called inside ViewModels via `WebAPIService().<repoMethod>(onError: (msg) => showToast(msg), onSuccess: (result) => ...).setProgress(this);`.
  - Always chain `.setProgress(this)` at the end of the Future chain to automatically bind the loading state (`isLoading`) to the `MixinProgressProvider` inherited by `ViewModel`.
- **Paginated API Integration (`fetchListData`) (CRITICAL)**:
  - For all paginated API listings, **always use `fetchListData<T>()`** from `ViewModel` (in `lib/providers/view_model.dart`).
  - Do NOT manually manage `_page` counters or reinvent custom pagination flags. Rely on `ViewModel`'s built-in `page`, `canLoadMore`, and `reset()`.
  - Pass `apiService` returning `Future<List<T>>`, `limit`, `onShowError`, and `onSuccess`. When refreshing or applying filters, invoke `reset()` and clear previous items before fetching page 1.
- **Targeted Consumer Wrapping**: **NEVER wrap the entire screen or `Scaffold` in a `Consumer`**. Wrap `Consumer` or `Selector` tightly and precisely around only the exact widget that needs the reactive rebuild.
- **Use `context.read<T>()` for Operations**: For action callbacks, button taps, event handlers, and data operations (e.g., `onRefresh: () => context.read<VM>().refresh()`), always use `context.read<T>()`. Never use `context.watch<T>()` in callbacks.
- **No `setState`**: **Do NOT use `setState()`** in views. Keep views as `StatelessWidget`.
- **Use `ValueNotifier` for Simple Local State**: For simple ephemeral UI state (e.g., expand/collapse, active tabs, toggles, visibility), use `ValueNotifier<T>` with `ValueListenableBuilder<T>` instead of `setState` or `StatefulWidget`.

### 4. Component Reuse & Widget Extraction (CRITICAL)
- **Extract Widgets (CRITICAL)**: If there are more than two widgets or bigger sub-components in a screen, **extract them out of the screen file and move them into the feature's `widgets/` folder** (e.g. `lib/features/<feature>/widgets/`). Keep the screen/view file thin, clean, and declarative.
- **Check Before Creating**: Always inspect [`lib/widgets/`](lib/widgets/) (`buildAppBar`, `AppButton`, `CustomTextField`, `AppBottomSheet`, etc.) before building new UI components.
- Check [`lib/utils/extensions.dart`](lib/utils/extensions.dart) (`asAssetSvg()`, `asAssetImg()`) and [`lib/utils/app_build_methods.dart`](lib/utils/app_build_methods.dart).

### 5. Routing
- All routes must be named and registered in [`lib/utils/routes.dart`](lib/utils/routes.dart).

### 6. Prohibited Core Modifications
Do **NOT** alter without explicit permission:
- `lib/services/web_api_services.dart`
- `lib/services/_mixins_api.dart`
- `lib/providers/_base.dart`
- `lib/providers/_mixins.dart`
- `lib/providers/view_model.dart`

### 7. Code Quality & Conditional Operators (CRITICAL)
- **No Nested Conditional (Ternary) Operators**:
  - **NEVER use nested ternary / conditional operators** (e.g. `a ? b : c ? d : e` or `a ? (b ? c : d) : e`).
  - A single conditional operator is fine (`isEnabled ? this : that`), but do not go beyond that.
  - Nested conditionals tangle the code and degrade readability and maintainability. Use explicit `if`/`else` statements, early returns, or extracted helper getters/methods instead.
