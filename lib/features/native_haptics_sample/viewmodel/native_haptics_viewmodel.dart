import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_haptics/native_haptics.dart';

class NativeHapticsViewModel extends ChangeNotifier {
  final NativeHaptics _haptics = NativeHaptics();
  String _platformVersion = 'Checking platform...';
  String _lastAction = 'Tap a button to trigger haptic feedback.';

  String get platformVersion => _platformVersion;
  String get lastAction => _lastAction;
  NativeHaptics get haptics => _haptics;

  NativeHapticsViewModel() {
    _loadPlatformVersion();
  }

  Future<void> _loadPlatformVersion() async {
    try {
      final platformVersion = await _haptics.getPlatformVersion();
      _platformVersion = platformVersion ?? 'Unknown platform';
    } on PlatformException {
      _platformVersion = 'Unable to read platform version';
    }
    notifyListeners();
  }

  Future<void> play(
    String label,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      _lastAction = '$label played';
    } on PlatformException catch (error) {
      _lastAction = '$label failed: ${error.message ?? error.code}';
    } catch (error) {
      _lastAction = '$label failed: $error';
    }
    notifyListeners();
  }
}
