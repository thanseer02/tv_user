# Strictly Prohibited Anti-Patterns

This document outlines prohibited practices that must be strictly avoided. Writing any of these anti-patterns in the codebase will fail validation.

## 1. Direct Network Calls in View or ViewModel
- **Anti-Pattern**: Constructing `Dio` or `Http` in a view or ViewModel, calling `executeAPI` or `dio` from a ViewModel, or referencing `WebAPIService` from a view.
- **Why**: Violates separation of concerns. Views stay on the ViewModel. ViewModels call repository methods. The repository owns the HTTP call.
- **Correction**: Declare the repository as an extension on `WebAPIService` under `lib/features/<feature>/repo/` (for example `extension ProfileRepo on WebAPIService`). Call that method from the ViewModel with `WebAPIService().fetchProfileDetails(...)`. Do not create a repository class.

## 2. Hardcoded Typography Styles and Hexadecimal Colors
- **Anti-Pattern**: Defining inline `TextStyle(color: Color(0xFF1A2B3C), fontSize: 16)` or using raw hex codes in widgets.
- **Why**: Breaks dark/light mode switching and the central design system.
- **Correction**: Use base text styles from `lib/utils/styles.dart` and retrieve colors via `context.brand` or `context.palette`. Always append `.spMin` to the font size for responsiveness.

## 3. Inline Hardcoded String Literals
- **Anti-Pattern**: Rendering UI text labels using inline Strings: `const Text("Submit Form")`.
- **Why**: Prevents localization support.
- **Correction**: Always add keys in standard camelCase to the `.arb` files and consume them via the localization helper: `Localization.locale.submitForm`.

## 4. Passing ViewModels in Widget Constructors
- **Anti-Pattern**: Instantiating or passing `ViewModel` instances inside custom child widget constructor parameters: `MyChildWidget(viewModel: myViewModel)`.
- **Why**: Causes unnecessary rebuilds, couples components, and bypasses Provider's dependency injection context.
- **Correction**: Use standard Provider accessors inside the child widget: `context.read<MyViewModel>()`, `context.watch<MyViewModel>()`, or wrap specific sections in a `Consumer` or `Selector`.

## 5. Bypassing Base Provider Classes
- **Anti-Pattern**: Extending ViewModels from `ChangeNotifier` directly instead of the project's base `ViewModel` class.
- **Why**: Bypasses shared logic for pagination, unified error handling, and loading state management.
- **Correction**: Ensure all feature ViewModel classes extend `ViewModel` from `lib/providers/view_model.dart`.

## 6. Duplicate or Redundant Utility Functions
- **Anti-Pattern**: Implementing custom formatters (e.g. currency, date), progress spinners, or dialog popups from scratch.
- **Why**: Inflates bundle sizes and leads to design inconsistencies.
- **Correction**: Always check `lib/utils/extensions.dart` and `lib/utils/app_build_methods.dart` for reusable extensions (e.g., `.showCircleProgressOnCenter`, `.setProgress`, `.toFormatted`, `showToast`) before writing custom helpers.

## 7. Wrapping Entire Screen or Scaffold in Consumer
- **Anti-Pattern**: Wrapping the entire `Scaffold` or root build method in `Consumer<MyViewModel>`.
- **Why**: Rebuilds the whole screen (including AppBars, backgrounds, static layouts) on every state change, causing severe frame drops and jank.
- **Correction**: Wrap `Consumer` or `Selector` strictly and precisely around the specific leaf widgets that require the reactive rebuild.

## 8. Using setState in Views
- **Anti-Pattern**: Using `StatefulWidget` with `setState()` in feature views.
- **Why**: Scatters state outside of the MVVM architecture and leads to unnecessary rebuilds.
- **Correction**: Keep views as `StatelessWidget`. Use the ViewModel for feature state, and `ValueNotifier<T>` with `ValueListenableBuilder<T>` for simple local ephemeral UI state (e.g. toggles, expand/collapse).

## 9. Bloated Screen Files with Inline / Private Sub-Widgets
- **Anti-Pattern**: Defining more than two widgets, or large sub-components, directly inside the screen/view file.
- **Why**: Makes screen files cluttered, difficult to maintain, hard to navigate, and hinders modularity and unit/widget testability.
- **Correction**: Extract widgets that exceed two components or are large in size into dedicated files inside the feature's `widgets/` folder (e.g. `lib/features/<feature>/widgets/`). Keep screen files thin, focused, and declarative.

## 10. Nested Conditional (Ternary) Operators
- **Anti-Pattern**: Nesting conditional operators: `conditionA ? value1 : conditionB ? value2 : value3` or `conditionA ? (conditionB ? value1 : value2) : value3`.
- **Why**: Deeply nested conditionals tangle logic, obscure intent, reduce readability, and make maintenance and debugging error-prone.
- **Correction**: Single ternary operators are acceptable (`isEnabled ? this : that`), but never nest them. Use clear `if`/`else` statements, early returns, or separate extracted helper getters/methods instead.

