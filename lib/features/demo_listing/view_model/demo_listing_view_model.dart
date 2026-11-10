import 'package:base_project/providers/view_model.dart';

class DemoListingViewModel extends ViewModel {
  final PaginationController pagination = PaginationController();
  final List<String> _items = [];

  List<String> get items => _items;

  Future<void> loadItems({bool initialCall = false}) async {
    if (initialCall) {
      pagination.reset();
      _items.clear();
    }

    if (!pagination.canLoadMore) {
      return;
    }

    await fetchListData<String>(
      customLimit: 8,
      initialCall: initialCall,
      controller: pagination,
      apiService: () async {
       

        // Replace this demo-only stub with a real API call.
        // For a real API, call your service here, return the current page items,
        // and let fetchListData handle pagination using the returned list length.
        const totalPages = 3;
        if (pagination.page > totalPages) {
          return [];
        }

        final startIndex = (pagination.page - 1) * pagination.limit;

        return List.generate(
          pagination.limit,
          (index) => 'Demo item ${startIndex + index + 1}',
        );
      },
      onShowError: (error) {},
      onSuccess: (newItems) async {
        _items.addAll(newItems);
      },
    );
  }

  void refreshItems() {
    loadItems(initialCall: true);
  }
}
