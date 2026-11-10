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
      // webview_flutter_web works with standard WebViewController
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
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

  void reload() {
    _webViewController?.reload();
  }
}

