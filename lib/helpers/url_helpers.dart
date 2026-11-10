import 'dart:io';
import 'package:flutter/foundation.dart';

class UrlHelpers {
  /// Resolves the host for the local backend API based on platform.
  /// - Web / desktop: `http://localhost:8000/api/v1/urls/public`
  /// - Android TV Physical Device on same Wi-Fi: `http://192.168.100.188:8000/api/v1/urls/public`
  /// - Android Emulator: `http://10.0.2.2:8000/api/v1/urls/public`
  static String get publicTvUrls {
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1/urls/public';
    }

    try {
      if (Platform.isAndroid) {
        // Use LAN IP so physical Android TVs / FireTVs on the local network can reach your Mac server
        return 'http://192.168.100.188:8000/api/v1/urls/public';
      }
    } catch (_) {}

    return 'http://localhost:8000/api/v1/urls/public';
  }

  /// Alternative fallback for Android Emulator if LAN IP is unreachable
  static String get emulatorTvUrls => 'http://10.0.2.2:8000/api/v1/urls/public';
}
