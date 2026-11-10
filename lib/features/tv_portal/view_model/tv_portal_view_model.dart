import 'package:base_project/features/tv_portal/model/tv_portal_item_model.dart';
import 'package:base_project/features/tv_portal/repo/tv_portal_repository.dart';
import 'package:base_project/providers/view_model.dart';
import 'package:base_project/services/web_api_services.dart';
import 'package:base_project/utils/app_build_methods.dart';
import 'package:base_project/utils/extensions.dart';

class TvPortalViewModel extends ViewModel {
  bool _isDisposed = false;

  List<TvPortalItemModel> _urlList = [];
  List<TvPortalItemModel> get urlList => _urlList;

  int _focusedIndex = 0;
  int get focusedIndex => _focusedIndex;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  void setFocusedIndex(int index) {
    if (_isDisposed) return;
    if (_focusedIndex != index && index >= 0 && index < _urlList.length) {
      _focusedIndex = index;
      notifyListeners();
    }
  }

  Future<void> loadUrls() async {
    await WebAPIService()
        .fetchTvPortalUrls(
          onError: (error) {
            if (_isDisposed) return;
            showToast(error);
          },
          onSuccess: (items) {
            if (_isDisposed) return;
            _urlList = items;
            _focusedIndex = 0;
            notifyListeners();
          },
        )
        .setProgress(this);
  }
}
