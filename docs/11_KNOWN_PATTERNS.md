# Known Implementation Patterns

This document details proven coding patterns from the codebase that you can reference when implementing common features.

## 1. Infinite List Pagination Pattern

To build paginated scrolling lists using the built-in infinite scroll helpers:

### Repository
Repositories are extensions on `WebAPIService`. There is no repository class to construct. The extension methods are called on a `WebAPIService` instance.

```dart
import 'package:base_project/services/web_api_services.dart';
import 'package:base_project/utils/urls.dart';
import '../model/my_item_model.dart';

extension MyItemRepository on WebAPIService {
  Future<List<MyItemModel>> fetchPageList({
    required int page,
    required int limit,
  }) {
    return executeAPI<List<MyItemModel>>(
      methodToCall: initTokenToHeader().then(
        (value) => initLangPrefToHeader().then(
          (value) => dio.get(
            urlMyItemList,
            queryParameters: {'page': page, 'limit': limit},
          ),
        ),
      ),
      converter: (responseMap) {
        final rows = responseMap['data'] as List<dynamic>;
        return rows
            .map((row) => MyItemModel.fromJson(row as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
```

### ViewModel Implementation
```dart
import 'package:base_project/providers/view_model.dart';
import 'package:base_project/services/web_api_services.dart';
import '../model/my_item_model.dart';
import '../repo/my_item_repo.dart';

class MyItemViewModel extends ViewModel {
  final List<MyItemModel> _items = [];
  List<MyItemModel> get items => _items;

  Future<void> fetchItems({bool isRefresh = false}) async {
    if (isRefresh) {
      reset(); // Reset page back to 1 and complete flag to false
      _items.clear();
    }

    // fetchListData automatically increments the page and sets isAllCompleted
    fetchListData<MyItemModel>(
      apiService: () =>
          WebAPIService().fetchPageList(page: page, limit: 10),
      onShowError: (appError) => debugPrint(appError.message),
      onSuccess: (newItems) {
        _items.addAll(newItems);
        notifyListeners();
      },
      limit: 10,
    );
  }
}
```

### View Implementation
```dart
@override
Widget build(BuildContext context) {
  return ChangeNotifierProvider(
    create: (_) => MyItemViewModel()..fetchItems(isRefresh: true),
    child: Scaffold(
      body: Consumer<MyItemViewModel>(
        builder: (context, vm, _) {
          return ListView.builder(
            itemCount: vm.items.length,
            itemBuilder: (context, index) => Text(vm.items[index].title),
          ).withLoadMore(
            onLoadMore: (context) => vm.fetchItems(),
            canLoadMore: (context) => vm.canLoadMore,
          );
        },
      ),
    ),
  );
}
```

---

## 2. Progressive Critical Operations Pattern

For critical state operations (like Login, Submitting Forms, or Processing Payments) where user input must be blocked, do **not** use `showOverlayProgress`. Instead, register `.setProgress(this)` on the Future within the ViewModel and wrap the View Scaffold's body with `showCircleProgressOnCenter<MyViewModel>()`:

### ViewModel
```dart
// --- Feature State ---
List<FavoriteLocationItem> _favoriteLocations = [];
List<FavoriteLocationItem> get favoriteLocations => _favoriteLocations;

/// Standard repository invocation in ViewModel:
Future<void> fetchFavoriteLocations() async {
  WebAPIService()
      .getFavoriteLocations(
        onError: (msg) {
          showToast(msg);
        },
        onSuccess: (result) {
          _favoriteLocations = result.data ?? [];
        },
      )
      .setProgress(this); // Automatically manages isLoading = true -> false
}
```

### View
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Consumer<MyViewModel>(
      builder: (context, vm, _) {
        return BodyContent();
      },
    ).showCircleProgressOnCenter<MyViewModel>(), // Intercepts taps and shows loader during execution
  );
}
```

---

## 3. Theme Detection & Extension Pattern

To fetch specific colors dynamically based on the active dark or light theme:

```dart
@override
Widget build(BuildContext context) {
  // 1. Access standard color scheme properties
  final cs = Theme.of(context).colorScheme;

  // 2. Access custom app brand colors via theme extensions
  final brand = context.brand;

  return Container(
    color: cs.surface,
    child: Text(
      Localization.locale.styledTitle,
      style: tsS16W600.copyWith(color: brand.primaryBlue),
    ),
  );
}
```

---

## 4. Localized Keys with Custom Styling

```dart
Text(
  Localization.locale.hello, // Global helper accessor
  style: tsS14W400.copyWith(
    fontSize: 14.spMin, // Responsive ScreenUtil constraint
    color: context.brand.neutralFg,
  ),
)
```
