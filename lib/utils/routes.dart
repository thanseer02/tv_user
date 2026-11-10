import 'package:base_project/features/tv_portal/view/tv_url_listing_screen.dart';
import 'package:base_project/features/tv_webview/view/tv_webview_screen.dart';
import 'package:base_project/utils/connection_failed_screen.dart';
import 'package:flutter/material.dart';

Map<String, Widget Function(BuildContext context)> appRoutes() => {
      TvUrlListingScreen.routeName: (context) => const TvUrlListingScreen(),
      TvWebViewScreen.routeName: (context) => const TvWebViewScreen(),
    };

Widget? _getScreen(RouteSettings settings) {
  switch (settings.name) {
    case ConnectionFailedScreen.routeName:
      ConnectionFailedScreenParams params =
          settings.arguments as ConnectionFailedScreenParams;
      return ConnectionFailedScreen(
        param: params,
      );
    case TvWebViewScreen.routeName:
      final params = settings.arguments as TvWebViewScreenParams?;
      return TvWebViewScreen(params: params);
    default:
      return null;
  }
}

RouteFactory onAppGenerateRoute() => (settings) {
      Widget? screen = _getScreen(settings);
      if (screen != null) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => screen,
          transitionsBuilder: (_, a, __, c) {
            return FadeTransition(opacity: a, child: c);
          },
        );
      }
      return null;
    };
