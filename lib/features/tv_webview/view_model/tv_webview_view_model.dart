import 'package:base_project/providers/view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

/// ViewModel responsible for TV WebView state and navigation.
///
/// Follows project guidelines:
/// - Inherits from [ViewModel].
/// - Exposes reactive properties for loading, errors, and history.
/// - Configures platform-specific settings for Android TV without artificial JS key spoofing.
class TvWebViewViewModel extends ViewModel {
  WebViewController? _webViewController;
  WebViewController? get webViewController => _webViewController;

  bool _isPageLoading = true;
  bool get isPageLoading => _isPageLoading;

  int _loadingProgress = 0;
  int get loadingProgress => _loadingProgress;

  String? _currentUrl;
  String? get currentUrl => _currentUrl;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _canGoBack = false;
  bool get canGoBack => _canGoBack;

  bool _isDisposed = false;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  /// Initializes the WebViewController.
  /// Configures Android TV specifics: Hybrid Composition widget support,
  /// media playback without user gestures, and history state updates.
  void initializeController(String initialUrl) {
    _currentUrl = initialUrl;
    _errorMessage = null;

    if (kIsWeb) {
      final controller = WebViewController()
        ..loadRequest(Uri.parse(initialUrl));
      _webViewController = controller;
      _isPageLoading = false;
      notifyListeners();
      return;
    }

    final PlatformWebViewControllerCreationParams params =
        defaultTargetPlatform == TargetPlatform.android
            ? AndroidWebViewControllerCreationParams()
            : const PlatformWebViewControllerCreationParams();

    final controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            _loadingProgress = progress;
            notifyListeners();
          },
          onPageStarted: (String url) {
            debugPrint('[TvWebView] Page started loading: $url');
            _isPageLoading = true;
            _currentUrl = url;
            _errorMessage = null;
            notifyListeners();
          },
          onPageFinished: (String url) async {
            debugPrint('[TvWebView] Page finished loading: $url');
            _isPageLoading = false;
            _currentUrl = url;
            await _updateHistoryState();
            notifyListeners();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint(
              '[TvWebView] Resource error (${error.errorCode}): ${error.description} for ${error.url}',
            );
            _isPageLoading = false;
            _errorMessage = error.description;
            notifyListeners();
          },
        ),
      );

    // Platform-specific configuration for Android
    if (controller.platform is AndroidWebViewController) {
      final androidController = controller.platform as AndroidWebViewController;
      // Allow media to play automatically on Android TV without touch gestures
      androidController.setMediaPlaybackRequiresUserGesture(false);
      // Support mixed content if external websites load HTTP assets over HTTPS
      androidController.setMixedContentMode(MixedContentMode.alwaysAllow);
    }

    controller.loadRequest(Uri.parse(initialUrl));

    _webViewController = controller;
    notifyListeners();
  }

  /// Queries the underlying controller history to check if backward navigation is possible.
  Future<bool> canGoBackInHistory() async {
    final controller = _webViewController;
    if (controller == null) {
      return false;
    }
    final canGo = await controller.canGoBack();
    _canGoBack = canGo;
    return canGo;
  }

  /// Navigates back in the WebView history.
  Future<void> goBackInHistory() async {
    final controller = _webViewController;
    if (controller != null && await controller.canGoBack()) {
      debugPrint('[TvWebView] Navigating backward in WebView history');
      await controller.goBack();
      await _updateHistoryState();
      notifyListeners();
    }
  }

  /// Reloads current webpage
  void reload() {
    _errorMessage = null;
    if (_currentUrl != null && _currentUrl!.isNotEmpty) {
      if (kIsWeb) {
        _webViewController?.loadRequest(Uri.parse(_currentUrl!));
      } else {
        _webViewController?.reload();
      }
    }
  }

  Future<void> _updateHistoryState() async {
    final controller = _webViewController;
    if (controller != null) {
      _canGoBack = await controller.canGoBack();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
