import 'package:base_project/configs/app_configs.dart';
import 'package:base_project/utils/connection_failed_screen.dart';
import 'package:base_project/utils/enums.dart';
import 'package:base_project/utils/exceptions.dart';
import 'package:base_project/utils/extensions.dart';
import 'package:base_project/utils/sp_keys.dart' as sp_keys;
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A mixin providing foundational network support, SharedPreferences header caching,
/// Dio error intercepting, and HTTP response validation.
///
/// Mixed into [WebAPIService] to standardize request execution and error handling.
mixin WebAPIMixin {
  /// Known error message tokens indicating an invalid or expired user session.
  static const Set<String> _invalidSessionTokens = {
    'invalid session',
    'invalid session.',
    'not a valid session',
    'not a valid session.',
  };

  /// Retrieves the saved authentication token from [SharedPreferences].
  ///
  /// The token is persisted under [sp_keys.keyToken].
  /// Returns `null` if no token is saved or an error occurs.
  Future<String?> getTokenFromSharedPref() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(sp_keys.keyToken);
  }

  /// Retrieves the user-selected language code from [SharedPreferences].
  ///
  /// The language code is persisted under [sp_keys.keyLanguageCode].
  /// Returns `null` if not configured.
  Future<String?> getLanguageSharedPref() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(sp_keys.keyLanguageCode);
  }

  /// Retrieves the tenant identification code from [SharedPreferences].
  ///
  /// The tenant code is persisted under [sp_keys.keyTenantCode].
  /// Returns `null` if not configured.
  Future<String?> getTenantCodeSharedPref() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(sp_keys.keyTenantCode);
  }

  /// Processes and standardizes errors originating from Dio HTTP calls.
  ///
  /// - Directs connection dropout errors to [ConnectionFailedScreen].
  /// - Inspects bad responses (4xx, 5xx) for unauthenticated or session expiration tokens.
  /// - Maps the error to a structured [APIException] for upstream catching.
  ///
  /// Parameters:
  /// - [error]: The caught [DioException].
  /// - [apiName]: The descriptive identifier or endpoint name of the calling API.
  /// - [apiFunction]: Optional callback allowing the user to retry the failed call.
  void onDioError(
    DioException error,
    String apiName, {
    Function? apiFunction,
  }) {
    String? message;

    switch (error.type) {
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.unknown:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
        message = EnumErrorMessage.checkInternet.message;
        _navigateToConnectionFailedIfAbsent(apiFunction);
        break;

      case DioExceptionType.badResponse:
        _handleBadResponse(error, apiName);
        break;

      case DioExceptionType.cancel:
        message = EnumErrorMessage.requestCancelled.message;
        break;

      case DioExceptionType.badCertificate:
        message = EnumErrorMessage.untrustedCertificate.message;
        break;

      case DioExceptionType.transformTimeout:
        break;
    }

    final String fallback = EnumErrorMessage.unknownNetworkError.message;
    final String finalMessage = message ?? '$apiName:${error.message ?? fallback}';
    throw APIException(
      enumProperty: EnumAPIExceptions.httpStatusError,
      message: finalMessage,
      otherData: [error.response?.data],
    );
  }

  /// Inspects a [DioExceptionType.badResponse] for detailed error payloads or authentication errors.
  void _handleBadResponse(DioException error, String apiName) {
    final dynamic responseData = error.response?.data;
    if (responseData == null) {
      final String fallback = EnumErrorMessage.emptyServerResponse.message;
      throw APIException(
        enumProperty: EnumAPIExceptions.httpStatusError,
        message: '$apiName:${error.message ?? fallback}',
        otherData: [error.error],
      );
    }

    if (responseData is! Map) return;

    // Check uppercase or lowercase 'Message' / 'message'
    final dynamic rawMsg = responseData['Message'] ?? responseData['message'];
    if (rawMsg != null) {
      final String msgStr = rawMsg.toString();
      if (msgStr.toLowerCase() == 'unauthenticated') {
        throw APIException(
          enumProperty: EnumAPIExceptions.invalidToken,
          message: EnumErrorMessage.tokenExpired.message,
          data: error.response,
        );
      }

      throw APIException(
        enumProperty: EnumAPIExceptions.dataSuccessFalse,
        message: msgStr,
        data: error.response,
      );
    }

    // Check status description for session invalidation
    final dynamic statusDesc = responseData['StatusDesc'];
    if (statusDesc != null) {
      final String descStr = statusDesc.toString().toLowerCase().trim();
      if (_invalidSessionTokens.contains(descStr)) {
        throw APIException(
          enumProperty: EnumAPIExceptions.invalidToken,
          message: statusDesc.toString(),
          data: error.response,
        );
      }
    }
  }

  /// Pushes [ConnectionFailedScreen] if not already present on top of the navigation stack.
  void _navigateToConnectionFailedIfAbsent(Function? retryAction) {
    final BuildContext? context = AppConfig.navKey.currentState?.context;
    if (context == null) return;

    final NavigatorState navigator = Navigator.of(context);
    if (!navigator.isCurrentRoute(ConnectionFailedScreen.routeName)) {
      navigator.pushNamed(
        ConnectionFailedScreen.routeName,
        arguments: ConnectionFailedScreenParams(
          failedAPI: retryAction,
          autoRetry: true,
        ),
      );
    }
  }

  /// Validates the format and internal status code of a raw Dio [Response].
  ///
  /// - Asserts that the response is non-null and is a [Map].
  /// - Inspects application-level status codes (such as `500` or `422`).
  /// - Automatically pops [ConnectionFailedScreen] if the request successfully completes.
  ///
  /// Returns the parsed [Map] containing the API response data.
  Future<Map<dynamic, dynamic>> validateResStatusData(
    Response<dynamic> response,
  ) async {
    final dynamic data = response.data;

    if (data == null) {
      throw APIException(
        enumProperty: EnumAPIExceptions.apiResultEmpty,
        message: EnumErrorMessage.emptyServerResponse.message,
      );
    }

    if (data is! Map) {
      throw APIException(
        enumProperty: EnumAPIExceptions.invalidResultType,
        message: EnumErrorMessage.invalidResultType.message,
      );
    }

    if (data.containsKey('status')) {
      final String statusCode = data['status']?.toString() ?? '';
      if (statusCode == '500') {
        final String message = _extractStatusMessage(
          data,
          fallback: EnumErrorMessage.serverError.message,
        );
        throw APIException(
          enumProperty: EnumAPIExceptions.dataSuccessFalse,
          message: message,
        );
      }

      if (statusCode == '422') {
        final String message = _extractStatusMessage(
          data,
          fallback: EnumErrorMessage.validationError.message,
        );
        throw APIException(
          enumProperty: EnumAPIExceptions.dataSuccessFalse,
          message: message,
        );
      }
    }

    // Dismiss connection failed screen if visible
    final BuildContext? context = AppConfig.navKey.currentState?.context;
    if (context != null) {
      final NavigatorState navigator = Navigator.of(context);
      if (navigator.isCurrentRoute(ConnectionFailedScreen.routeName)) {
        navigator.pop();
      }
    }

    return data;
  }

  /// Helper to extract an API response message or return a fallback.
  String _extractStatusMessage(Map<dynamic, dynamic> data, {required String fallback}) {
    if (data.containsKey('message')) {
      final String? msg = data['message']?.toString();
      if (msg != null && msg.isNotEmpty) {
        return msg;
      }
    }
    return fallback;
  }
}
