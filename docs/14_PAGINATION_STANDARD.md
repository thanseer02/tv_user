# Pagination Standard & Implementation Guide

This document establishes the architecture, patterns, and best practices for implementing paginated lists and grids across the codebase.

---

## 🏗️ Architecture Overview

Pagination is built on three interconnected layers:

```
┌────────────────────────────────────────────────────────┐
│ UI Layer (View / Screen)                               │
│ - ListView / GridView with .withLoadMore()             │
│ - .orShowEmptyWidget() for empty/loading UI state      │
│ - ScrollController assigned to the scroll view         │
└───────────────────────────▲────────────────────────────┘
                            │ listens via Consumer / Selector
┌───────────────────────────┴────────────────────────────┐
│ ViewModel Layer                                        │
│ - Holds PaginationController                           │
│ - Implements loadData({bool initialCall = false})      │
│ - Uses fetchListData<T>() from Base ViewModel          │
└───────────────────────────▲────────────────────────────┘
                            │ fetches page items
┌───────────────────────────┴────────────────────────────┐
│ Repository Layer (WebAPIService Extension)             │
│ - Passes page & limit parameters                       │
│ - Returns Future<List<T>>                              │
└────────────────────────────────────────────────────────┘
```

---

## 🧩 1. The Controller: `PaginationController`

Defined in [`lib/providers/view_model.dart`](../lib/providers/view_model.dart):

```dart
class PaginationController {
  int page = 0;
  int limit = 6;
  bool isAllCompleted = false;
  bool isLoading = false;

  bool get canLoadMore => !isAllCompleted && !isLoading;

  void reset() {
    page = 1;
    isAllCompleted = false;
    isLoading = false;
  }
}
```

### Key Responsibilities:
- **`page`**: Current page offset or index.
- **`limit`**: Number of items requested per page (defaults to `6`).
- **`isAllCompleted`**: Set to `true` when the API returns fewer items than `limit`, meaning the end of the data stream is reached.
- **`canLoadMore`**: Guard flag returning `(!isAllCompleted) && (!isLoading)`.
- **`reset()`**: Resets the state back to page 1, clears `isAllCompleted` and `isLoading`.

---

## ⚙️ 2. ViewModel Implementation: `fetchListData<T>()`

ViewModels extend `ViewModel` from [`lib/providers/view_model.dart`](../lib/providers/view_model.dart) and use `fetchListData<T>()`:

```dart
class MyListingViewModel extends ViewModel {
  final PaginationController pagination = PaginationController();
  final List<MyItemModel> _items = [];

  List<MyItemModel> get items => List.unmodifiable(_items);

  /// Loads paginated items
  Future<void> loadItems({bool initialCall = false}) async {
    if (initialCall) {
      pagination.reset();
      _items.clear();
    }

    if (!pagination.canLoadMore) return;

    await fetchListData<MyItemModel>(
      controller: pagination,
      customLimit: 10,
      initialCall: initialCall,
      apiService: () async {
        final response = await WebAPIService().getMyItems(
          page: pagination.page,
          limit: pagination.limit,
          onError: (msg) => showToast(msg),
        );
        return response.data ?? <MyItemModel>[];
      },
      onShowError: (error) {
        showToast(error.message);
      },
      onSuccess: (newItems) async {
        _items.addAll(newItems);
      },
    );
  }

  void refreshItems() => loadItems(initialCall: true);
}
```

---

## 🖥️ 3. UI Layer: `ListScrollMoreWidget` & `.withLoadMore()`

Found in [`lib/widgets/list_scroll_more_widget.dart`](../lib/widgets/list_scroll_more_widget.dart) and [`lib/utils/extensions.dart`](../lib/utils/extensions.dart).

### The Extension Method:
```dart
extension ListViewExtension on ListView {
  Widget withLoadMore({
    required void Function(BuildContext context) onLoadMore,
    required bool Function(BuildContext context) canLoadMore,
  }) =>
      ListScrollMoreWidget(
        onLoadMore: onLoadMore,
        canLoadMore: canLoadMore,
        child: this,
      );
}

extension GridViewExtension on GridView {
  Widget withLoadMore({
    required void Function(BuildContext context) onLoadMore,
    required bool Function(BuildContext context) canLoadMore,
  }) =>
      GridScrollMoreWidget(
        onLoadMore: onLoadMore,
        canLoadMore: canLoadMore,
        child: this,
      );
}
```

### Complete Screen Pattern:
```dart
class MyListingScreen extends StatefulWidget {
  static const routeName = '/MyListingScreen';

  const MyListingScreen({super.key});

  @override
  State<MyListingScreen> createState() => _MyListingScreenState();
}

class _MyListingScreenState extends State<MyListingScreen> {
  final ScrollController _scrollController = ScrollController();
  late final MyListingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MyListingViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadItems(initialCall: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(title: const Text('My Listings')),
        body: Consumer<MyListingViewModel>(
          builder: (context, vm, child) {
            return RefreshIndicator(
              onRefresh: () async => vm.refreshItems(),
              child: ListView.separated(
                controller: _scrollController,
                itemCount: vm.items.length + (vm.pagination.canLoadMore ? 1 : 0),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index < vm.items.length) {
                    return ListTile(
                      title: Text(vm.items[index].title),
                    );
                  }

                  // Trailing pagination loader indicator:
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                },
              )
                  .withLoadMore(
                    canLoadMore: (context) => vm.pagination.canLoadMore,
                    onLoadMore: (context) => vm.loadItems(),
                  )
                  .orShowEmptyWidget(
                    items: vm.items,
                    isLoading: vm.isLoading,
                    text: 'No records found',
                  ),
            );
          },
        ),
      ),
    );
  }
}
```

---

## 🚫 Critical Rules & Anti-Patterns

1. **NEVER manually manage page numbers or custom flags**:
   - ❌ `int _myCurrentPage = 1; bool hasEnded = false;`
   - ✅ Always use `PaginationController` and `fetchListData<T>()`.
2. **Always supply a `ScrollController`**:
   - `ListScrollMoreWidget` has an assertion `assert(child.controller != null);`. If your `ListView` or `GridView` does not have a `controller`, runtime assertion error is thrown.
3. **Reset upon Refresh or Filters**:
   - When pulling to refresh or applying new query filters, call `pagination.reset()` and clear existing items (`_items.clear()`) before triggering the new query.
4. **Use `.withLoadMore()` & `.orShowEmptyWidget()`**:
   - Chain `.withLoadMore(...)` and `.orShowEmptyWidget(...)` directly to declarative `ListView` or `GridView` widgets for consistent scroll threshold detection and empty state handling.

