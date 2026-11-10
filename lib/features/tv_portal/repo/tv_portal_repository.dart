import 'package:base_project/features/tv_portal/model/tv_portal_item_model.dart';
import 'package:base_project/services/web_api_services.dart';
import 'package:base_project/utils/urls.dart';
import 'package:dio/dio.dart';

extension TvPortalRepository on WebAPIService {
  /// Fetches public URLs from the backend API: `http://localhost:8000/api/v1/urls/public`
  Future<List<TvPortalItemModel>> fetchTvPortalUrls({
    required Function(String error) onError,
    required Function(List<TvPortalItemModel> urls) onSuccess,
  }) async {
    try {
      final response = await dio.get<dynamic>(
        urlPublicTvUrls,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      final dynamic responseData = response.data;
      if (responseData is List) {
        final List<TvPortalItemModel> items = responseData
            .map((e) => TvPortalItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
        onSuccess(items);
        return items;
      } else if (responseData is Map<String, dynamic>) {
        final dynamic rawList = responseData['data'] ?? responseData['urls'];
        if (rawList is List) {
          final List<TvPortalItemModel> items = rawList
              .map((e) => TvPortalItemModel.fromJson(e as Map<String, dynamic>))
              .toList();
          onSuccess(items);
          return items;
        }
      }

      onError('Invalid response format received from server');
      return [];
    } catch (e) {
      final String errorMessage = e.toString();
      onError(errorMessage);
      return [];
    }
  }
}
