# UI Implementation Standard

This document details the visual implementation, typography, palette theming, loading state feedback, and responsive layout standards of the application.

## Figma to Responsive Code (ScreenUtil)

We utilize the **`flutter_screenutil`** package for visual element responsiveness:

- **Target Design Dimensions**: `428 x 926` (Figma Canvas Dimensions, registered in `main.dart`).
- **Sizing Rule**: You must strictly use **only** the `.spMin` size extension for all sizing measurements (margins, paddings, border radiuses, heights, widths, and font sizes) to achieve consistent scale across varying mobile form factors:
  ```dart
  Text(
    Localization.locale.titleText,
    style: tsS16W600.copyWith(fontSize: 16.spMin),
  )
  ```
- **Margins & Paddings**: Never use `.w`, `.h`, `.r`, or `.sp`. Instead, construct paddings and sizes utilizing `.spMin`:
  ```dart
  padding: EdgeInsets.symmetric(horizontal: 24.spMin, vertical: 12.spMin)
  ```

## Styling, Fonts, and Typography

- **Default Font Family**: `'OpenSans'` (specified across text configurations).
- **Rule**: Do not declare custom standalone `TextStyle` options in local widgets. Always import styles defined in `lib/utils/styles.dart` (e.g. `tsS14W400`, `tsS16W600`, `tsS22W600`) and apply `.copyWith()` for minor shifts (like color overrides).

## Brand Colors & Themes

We manage custom colors through **`ThemeExtension`** elements to support seamless light and dark mode switches:

1. **`AppBrandColors`**: Accessible via `context.brand`. Houses precise semantic branding tokens (e.g. `success`, `warning`, `danger`, `primaryBlue`, `textLightGray`):
   ```dart
   final colors = context.brand;
   return Scaffold(
     backgroundColor: colors.bgDeepNavy,
     body: Text(
       Localization.locale.hello,
       style: tsS16W600.copyWith(color: colors.textWhite),
     ),
   );
   ```
2. **`AppPalette`**: Accessible via `context.palette`. Houses the core primitive palette configurations.

## Async Actions & Loading Visual Feedback

Never leave the screen unresponsive while communicating with background APIs. This project handles progressive spinner loops via reactive extensions in `lib/utils/extensions.dart`:

### 1. Embedded Widget Loading (`showCircleProgressOnCenter`)
Use this extension to block actions on specific widgets and show an embedded progress spinner at the center of the viewport:
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Consumer<ProfileViewModel>(
      builder: (context, vm, _) {
        return ProfileContent(details: vm.profile);
      },
    ).showCircleProgressOnCenter<ProfileViewModel>(), // Automatically displays spinner on loading states
  );
}
```

### 2. Progress State Indicator (`setProgress(this)`)
Do **not** use `.showOverlayProgress` on critical state operations. Instead, always use the `.setProgress(this)` extension directly on the API Future inside the consumed ViewModel class. This automatically toggles `isLoading` on the ViewModel, which dynamically triggers the center progress indicator and blocks user input via `showCircleProgressOnCenter` in the View layer:
```dart
// Inside ViewModel
Future<void> submitAction() async {
  await _repo.submitData().setProgress(this); // Drives isLoading automatically
}
```

## Empty State Architecture

When lists return empty or records are not found:
- Avoid writing manual conditional empty container placeholders.
- Always use the `.orShowEmptyWidget` extension from `WidgetExtension`:
  ```dart
  listViewWidget.orShowEmptyWidget(
    items: vm.dataList,
    isLoading: vm.isLoading,
    text: Localization.locale.noDevicesFound,
  )
  ```
- This helper automatically swaps the viewport with a beautiful localized SVG illustration and text when the data list is empty, and returns the original widget list when data is present.
