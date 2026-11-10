import 'dart:async';

import 'package:base_project/models/app_error_model.dart';
import 'package:base_project/utils/enums.dart';
import 'package:flutter/foundation.dart';
import '/utils/exceptions.dart';
import '_base.dart';

/// Callback signature for handling exceptions thrown during API calls.
typedef HandleAPIException = void Function({
  required APIException ex,
  required OnShowError onShowError,
  VoidCallback? onInvalidToken,
});

/// A mixin that provides loading/progress state management for classes extending [BaseProvider].
///
/// Features:
/// - Reactive [_isLoading] property that triggers [notifyListeners].
/// - [Completer]-backed [progressCompleter] to synchronize or await ongoing progress.
/// - Conveniences like [showLoading], [hideLoading], [callWithInProgress], and [callSmallDelay].
mixin MixinProgressProvider on BaseProvider {
  Completer<bool>? _completer;

  /// Returns the current [Completer] representing the active progress state, or `null` if none.
  Completer<bool>? get progressCompleter => _completer;

  bool _isLoading = false;

  /// Returns `true` if a background or asynchronous task is currently in progress.
  bool get isLoading => _isLoading;

  /// Updates the progress state and notifies listening UI consumers.
  ///
  /// When setting to `true`, a new [Completer] is initialized if necessary.
  /// When setting to `false`, any uncompleted [progressCompleter] is resolved with `true`.
  set isLoading(bool value) {
    if (_isLoading == value) return;

    _isLoading = value;
    notifyListeners();

    try {
      if (value) {
        _completer ??= Completer<bool>();
        if (_completer!.isCompleted) {
          _completer = Completer<bool>();
        }
      } else {
        if (_completer != null && !_completer!.isCompleted) {
          _completer!.complete(true);
        }
      }
    } catch (ex) {
      debugPrint('Error updating progress completer: $ex');
    }
  }

  /// Sets [isLoading] to `true`.
  void showLoading() => isLoading = true;

  /// Sets [isLoading] to `false`.
  void hideLoading() => isLoading = false;

  /// Wraps the execution of [methodToCall] with automatic progress management.
  ///
  /// Sets [isLoading] to `true` before starting, and ensures [isLoading] is set
  /// back to `false` in a `finally` block when [methodToCall] completes or throws.
  Future<T> callWithInProgress<T>({required Future<T> methodToCall}) async {
    showLoading();
    try {
      return await methodToCall;
    } finally {
      hideLoading();
    }
  }

  /// Simulates a short delay (defaults to 1500ms) with active loading state.
  ///
  /// Useful for skeleton loading demonstrations, debug pauses, or smooth splash transitions.
  Future<void> callSmallDelay({int delayInMillis = 1500}) async {
    showLoading();
    try {
      await Future<void>.delayed(Duration(milliseconds: delayInMillis));
    } finally {
      hideLoading();
    }
  }
}

/// A mixin that provides standardized API exception handling and session management.
///
/// Designed to be mixed into providers and services (such as `WebAPIService` or [BaseProvider] subclasses)
/// to convert raw [APIException] instances into structured [AppError] callbacks.
mixin MixinAPIProvider {
  /// Known error message tokens that indicate an expired or invalid user session.
  static const Set<String> _invalidSessionTokens = {
    'invalid session',
    'invalid session.',
    'not a valid session',
    'not a valid session.',
    'invalid login details',
  };

  /// Dispatches and maps a caught [APIException] to appropriate user-facing errors
  /// or triggers token invalidation routines.
  ///
  /// - [ex]: The caught [APIException] instance.
  /// - [onShowError]: UI callback invoked to present the resulting [AppError].
  /// - [onInvalidToken]: Optional callback to execute on unauthenticated/invalid session.
  ///   Defaults to this mixin's [onInvalidToken] implementation if omitted.
  void handleAPIException({
    required APIException ex,
    required OnShowError onShowError,
    VoidCallback? onInvalidToken,
  }) {
    debugPrint('APIException caught: $ex');
    final VoidCallback invalidTokenHandler = onInvalidToken ?? this.onInvalidToken;

    switch (ex.enumProperty) {
      case EnumAPIExceptions.apiResultEmpty:
        onShowError(
          AppError<APIException>(
            message: EnumErrorMessage.emptyServerData.message,
            response: ex,
          ),
        );
        break;

      case EnumAPIExceptions.dataFieldEmpty:
        // Optional placeholder: ignored or handled via silent fallback
        break;

      case EnumAPIExceptions.dataSuccessFalse:
        _handleDataSuccessFalse(
          ex: ex,
          onShowError: onShowError,
          onInvalidToken: invalidTokenHandler,
        );
        break;

      case EnumAPIExceptions.httpStatusError:
        _handleHttpStatusError(
          ex: ex,
          onShowError: onShowError,
        );
        break;

      case EnumAPIExceptions.invalidToken:
        invalidTokenHandler();
        break;

      case EnumAPIExceptions.emptyTokenFromServer:
        onShowError(
          AppError<APIException>(
            message: EnumErrorMessage.emptyTokenFromServer.message,
            response: ex,
          ),
        );
        break;

      case EnumAPIExceptions.invalidResultType:
        onShowError(
          AppError<APIException>(
            message: ex.message.isNotEmpty
                ? ex.message
                : EnumErrorMessage.invalidResultType.message,
            response: ex,
          ),
        );
        break;
    }
  }

  /// Internal helper to evaluate [EnumAPIExceptions.dataSuccessFalse] scenarios.
  void _handleDataSuccessFalse({
    required APIException ex,
    required OnShowError onShowError,
    required VoidCallback onInvalidToken,
  }) {
    final dynamic rawData = ex.data;
    if (rawData is Map) {
      final dynamic rawMessage = rawData['message'];
      final String? messageStr = rawMessage?.toString().toLowerCase().trim();

      if (messageStr != null && _invalidSessionTokens.contains(messageStr)) {
        onShowError(
          AppError<APIException>(
            message: rawMessage.toString(),
            response: ex,
          ),
        );
        onInvalidToken();
        return;
      }
    }

    final String finalMessage = ex.toStringOtherData() ?? ex.message;
    onShowError(
      AppError<APIException>(
        message: finalMessage,
        response: ex,
      ),
    );
  }

  /// Internal helper to evaluate [EnumAPIExceptions.httpStatusError] scenarios.
  void _handleHttpStatusError({
    required APIException ex,
    required OnShowError onShowError,
  }) {
    if (ex.otherData != null && ex.otherData!.isNotEmpty) {
      for (final dynamic item in ex.otherData!) {
        if (item is Map && item.containsKey('message') && item['message'] != null) {
          onShowError(
            AppError<APIException>(
              message: item['message'].toString(),
              response: ex,
            ),
          );
          return;
        }
      }
    }

    final String details = ex.data != null ? ' ${ex.data}' : '';
    onShowError(
      AppError<APIException>(
        message: '${ex.message}$details'.trim(),
        response: ex,
      ),
    );
  }

  /// Hook invoked when a session token is determined to be expired or invalid.
  ///
  /// Can be overridden in subclasses to perform cleanup, database reset, or navigation to login.
  void onInvalidToken() {
    // Default implementation can be customized or overridden by specific providers
  }
}
