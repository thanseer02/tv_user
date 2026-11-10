import 'package:base_project/features/tv_webview/view_model/tv_webview_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TvWebViewViewModel Tests', () {
    late TvWebViewViewModel viewModel;

    setUp(() {
      viewModel = TvWebViewViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('Initial state reflects loading, empty URL, and no history', () {
      expect(viewModel.isPageLoading, isTrue);
      expect(viewModel.loadingProgress, 0);
      expect(viewModel.currentUrl, isNull);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.canGoBack, isFalse);
    });

    test('canGoBackInHistory returns false when controller is null', () async {
      final canGo = await viewModel.canGoBackInHistory();
      expect(canGo, isFalse);
    });
  });
}
