import 'dart:io';

import 'package:base_project/features/tv_portal/model/tv_portal_item_model.dart';
import 'package:base_project/helpers/url_helpers.dart';
import 'package:base_project/services/web_api_services.dart';
import 'package:base_project/utils/urls.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

extension TvPortalRepository on WebAPIService {
  /// Fetches public URLs from the backend API.
  /// Tries the primary endpoint, and if on Android, tries the emulator fallback (10.0.2.2)
  /// before reporting an error.
  Future<List<TvPortalItemModel>> fetchTvPortalUrls({
    required Function(String error) onError,
    required Function(List<TvPortalItemModel> urls) onSuccess,
  }) async {
    final List<String> endpointsToTry = [urlPublicTvUrls];
    if (!kIsWeb) {
      try {
        if (Platform.isAndroid && !endpointsToTry.contains(UrlHelpers.emulatorTvUrls)) {
          endpointsToTry.add(UrlHelpers.emulatorTvUrls);
        }
      } catch (_) {}
    }

    String lastError = 'No internet connection';

    for (final String endpoint in endpointsToTry) {
      try {
        final response = await dio.get<dynamic>(
          endpoint,
          options: Options(
            sendTimeout: const Duration(seconds: 6),
            receiveTimeout: const Duration(seconds: 6),
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
      } catch (e) {
        lastError = e.toString();
        continue;
      }
    }

    onError(lastError);
    return [];
  }
}
