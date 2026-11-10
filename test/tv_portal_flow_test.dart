import 'package:flutter_test/flutter_test.dart';
import 'package:base_project/features/tv_portal/model/tv_portal_item_model.dart';
import 'package:base_project/features/tv_webview/view/tv_webview_screen.dart';

void main() {
  group('TV Portal Model and Screen Params Tests', () {
    test('TvPortalItemModel parses API payload correctly', () {
      final json = {
        "id": "url_1794296533119",
        "title": "one",
        "name": "one",
        "url": "https://www.1flex.org/",
        "address": "https://www.1flex.org/",
        "category": "General",
        "description": "",
        "notes": "",
        "environment": "production",
        "status": "active",
        "refreshInterval": 0,
        "createdAt": "2026-11-10T07:42:13.118717+00:00",
        "updatedAt": "2026-11-10T07:42:13.118717+00:00"
      };

      final model = TvPortalItemModel.fromJson(json);

      expect(model.id, 'url_1794296533119');
      expect(model.displayTitle, 'one');
      expect(model.displayUrl, 'https://www.1flex.org/');
      expect(model.displayDescription, 'Category: General');
      expect(model.status, 'active');
    });

    test('TvWebViewScreenParams holds parameters properly', () {
      const params = TvWebViewScreenParams(
        title: 'Test Portal',
        url: 'https://example.com',
      );

      expect(params.title, 'Test Portal');
      expect(params.url, 'https://example.com');
    });
  });
}
