import 'package:base_project/models/app_error_model.dart';

import '/providers/_base.dart';
import '/providers/_mixins.dart';
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
abstract class ViewModel extends BaseProvider
    with MixinProgressProvider, MixinAPIProvider {
  final int _page = 1;
  final bool _isAllCompleted = false;

  int get page => _page;

  bool get canLoadMore => (!_isAllCompleted) && (!super.isLoading);

  /// If you want to execute an [apiService] which has a pagination use
  /// [fetchListData]
  ///
  /// [_isAllCompleted]
  /// will be marked as ```true``` when [limit] does not matches with list
  /// returned by API
  ///
  /// By default [limit] is ```6```
   Future<void> fetchListData<IM>({
    required final Future<List<IM>> Function() apiService,
    required OnShowError onShowError,
    required Future<void> Function(List<IM>) onSuccess,
    final int customLimit = 6,
    bool initialCall = false,
    required PaginationController controller,
  }) async {
    controller.limit = customLimit;
    if (controller.isLoading) return;

    controller.isLoading = true;
    if (initialCall) {
      notifyListeners();
    }

    try {
      final models = await apiService();
      if (models.length == controller.limit) {
        controller.page++;
      } else {
        controller.isAllCompleted = true;
      }
      controller.isLoading = false;
      await onSuccess(models);
    } catch (error) {
      onShowError(AppError(message: error.toString()));
    } finally {
      controller.isLoading = false;
      notifyListeners();
    }
  }

}
