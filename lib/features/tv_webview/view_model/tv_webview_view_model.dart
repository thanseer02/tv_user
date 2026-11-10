import 'package:base_project/providers/view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TvWebViewViewModel extends ViewModel {
  WebViewController? _webViewController;
  WebViewController? get webViewController => _webViewController;

  bool _isPageLoading = true;
  bool get isPageLoading => _isPageLoading;

  int _loadingProgress = 0;
  int get loadingProgress => _loadingProgress;

  String? _currentUrl;
  String? get currentUrl => _currentUrl;

  void initializeController(String initialUrl) {
    _currentUrl = initialUrl;

    if (kIsWeb) {
      final controller = WebViewController()
        ..loadRequest(Uri.parse(initialUrl));
      _webViewController = controller;
      _isPageLoading = false;
      notifyListeners();
      return;
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            _loadingProgress = progress;
            notifyListeners();
          },
          onPageStarted: (String url) {
            _isPageLoading = true;
            _currentUrl = url;
            notifyListeners();
          },
          onPageFinished: (String url) {
            _isPageLoading = false;
            _currentUrl = url;
            notifyListeners();
          },
          onWebResourceError: (WebResourceError error) {
            _isPageLoading = false;
            notifyListeners();
          },
        ),
      )
      ..loadRequest(Uri.parse(initialUrl));

    _webViewController = controller;
    notifyListeners();
  }

  /// Scrolls the webpage up using the TV remote D-Pad Up
  void scrollUp([int pixels = 180]) {
    _webViewController?.runJavaScript(
      'window.scrollBy({top: -$pixels, behavior: "smooth"});',
    );
  }

  /// Scrolls the webpage down using the TV remote D-Pad Down
  void scrollDown([int pixels = 180]) {
    _webViewController?.runJavaScript(
      'window.scrollBy({top: $pixels, behavior: "smooth"});',
    );
  }

  /// Scrolls the webpage left using the TV remote D-Pad Left
  void scrollLeft([int pixels = 150]) {
    _webViewController?.runJavaScript(
      'window.scrollBy({left: -$pixels, behavior: "smooth"});',
    );
  }

  /// Scrolls the webpage right using the TV remote D-Pad Right
  void scrollRight([int pixels = 150]) {
    _webViewController?.runJavaScript(
      'window.scrollBy({left: $pixels, behavior: "smooth"});',
    );
  }

  /// Simulates clicking the currently focused web element or triggers page interaction
  void simulateClick() {
    _webViewController?.runJavaScript('''
      if (document.activeElement && typeof document.activeElement.click === "function") {
        document.activeElement.click();
      }
    ''');
  }

  void reload() {
    if (_currentUrl != null && _currentUrl!.isNotEmpty) {
      if (kIsWeb) {
        _webViewController?.loadRequest(Uri.parse(_currentUrl!));
      } else {
        _webViewController?.reload();
      }
    }
  }
}
