import 'package:base_project/features/tv_portal/model/tv_portal_item_model.dart';
import 'package:base_project/features/tv_portal/repo/tv_portal_repository.dart';
import 'package:base_project/providers/view_model.dart';
import 'package:base_project/services/web_api_services.dart';

class TvPortalViewModel extends ViewModel {
  List<TvPortalItemModel> _urlList = [];
  List<TvPortalItemModel> get urlList => _urlList;

  int _focusedIndex = 0;
  int get focusedIndex => _focusedIndex;

  void setFocusedIndex(int index) {
    if (_focusedIndex != index && index >= 0 && index < _urlList.length) {
      _focusedIndex = index;
      notifyListeners();
    }
  }

  Future<void> loadUrls() async {
    await WebAPIService()
        .fetchTvPortalUrls(
          onError: (error) {
            // Error handling through base progress/API mixin
          },
          onSuccess: (items) {
            _urlList = items;
            notifyListeners();
          },
        )
        .setProgress(this);
  }
}
