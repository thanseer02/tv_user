import 'package:base_project/features/tv_portal/model/tv_portal_item_model.dart';
import 'package:base_project/services/web_api_services.dart';

extension TvPortalRepository on WebAPIService {
  Future<List<TvPortalItemModel>> fetchTvPortalUrls({
    required Function(String error) onError,
    required Function(List<TvPortalItemModel> urls) onSuccess,
  }) async {
    try {
      // Default curated list of TV-optimized URLs / portals / dashboards
      final List<Map<String, dynamic>> rawData = [
        {
          'id': '1',
          'title': 'Google News',
          'description': 'Latest headlines, world news, business, and technology.',
          'url': 'https://news.google.com',
          'icon_name': 'newspaper',
        },
        {
          'id': '2',
          'title': 'Flutter Official Website',
          'description': 'Multi-platform development portal, docs and showcase.',
          'url': 'https://flutter.dev',
          'icon_name': 'flutter',
        },
        {
          'id': '3',
          'title': 'BBC World News',
          'description': 'International breaking news and live broadcast coverage.',
          'url': 'https://www.bbc.com/news',
          'icon_name': 'public',
        },
        {
          'id': '4',
          'title': 'NASA Astronomy Picture of the Day',
          'description': 'Daily cosmos imagery, deep space missions, and discoveries.',
          'url': 'https://apod.nasa.gov/apod/astropix.html',
          'icon_name': 'satellite',
        },
        {
          'id': '5',
          'title': 'Wikipedia Portal',
          'description': 'Free encyclopedia with featured articles and media.',
          'url': 'https://en.wikipedia.org',
          'icon_name': 'menu_book',
        },
        {
          'id': '6',
          'title': 'Weather Radar Live',
          'description': 'Interactive global weather satellite and forecast maps.',
          'url': 'https://weather.com',
          'icon_name': 'cloud',
        },
      ];

      final items =
          rawData.map((json) => TvPortalItemModel.fromJson(json)).toList();
      onSuccess(items);
      return items;
    } catch (e) {
      onError(e.toString());
      return [];
    }
  }
}
