# Component Reuse Protocol

This document defines how to identify, inspect, and reuse existing widgets inside the `lib/widgets/` folder before writing new ones.

## Library of Existing Core Widgets

All globally shared UI components reside in the `lib/widgets/` folder:

| Component File | Widget Name | Purpose | Configuration & Overrides |
| :--- | :--- | :--- | :--- |
| `app_button_widget.dart` | `AppButton` | Standardized visual buttons (square, curved, primary, secondary). | Supports custom background colors, text, and tap callbacks. Exposes constructors like `AppButton.curvedButton` and `AppButton.squareButton`. |
| `app_custom_text_field.dart` | `CustomTextField` | Standardized forms input field. | Exposes hint styles, text styles, input validators, prefix/suffix widgets, controllers, and obscure text controls. |
| `app_progress_widget.dart` | `AppProgressWidget` | Standard circular/linear loading spinner. | Renders the styled application progress indicator globally. |
| `app_radio_button_widget.dart` | `AppRadioButtonWidget` | Standard styled radio button selectors. | Accepts active boolean states and tap callbacks. |
| `custom_checkbox_widget.dart` | `CustomCheckBoxWidget` | Custom checkbox toggle. | Integrates clean active states and custom handlers. |
| `custom_app_bar.dart` | `buildAppBar()` | Globally standardized header app bar. | Returns a styled app bar with actions, back buttons, and customizable title parameters. |
| `list_scroll_more_widget.dart` | `ListScrollMoreWidget` | Infinite loading support for ListViews. | Auto-schedules retrieval triggers when lists are scrolled to the bottom. |

## Modifying Existing Components Safely

If a design calls for a slight visual tweak to an existing widget:
- **Do not clone or duplicate the file.**
- **Rule**: Extend the functionality of the existing widget.
- Implement optional configuration parameters inside the constructor with safe default values:
  ```dart
  // Example of extending a button with a border parameter
  const AppButton({
    super.key,
    required this.text,
    required this.onTap,
    this.backgroundColor,
    this.borderColor, // New optional parameter
  });
  ```
- Verify that your additions maintain backward compatibility and do not break other screens that consume the same widget.

## ListView & GridView Infinite Scrolling

When rendering lists that support infinite scrolling (pagination):
- Wrap your `ListView` or `GridView` inside the `.withLoadMore` extension from `lib/utils/extensions.dart`.
- This utility injects the corresponding custom scroll listener automatically and calls your view model's pagination logic:
  ```dart
  ListView.builder(
    itemCount: vm.list.length,
    itemBuilder: (context, index) => ListItem(item: vm.list[index]),
  ).withLoadMore(
    onLoadMore: (context) => vm.loadMoreData(),
    canLoadMore: (context) => vm.canLoadMore,
  )
  ```
