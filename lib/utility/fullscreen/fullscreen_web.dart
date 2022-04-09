// Ignore warning about importing web libraries because of conditional imports
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

/// Enter in fullscreen mode.
Future<void> enterDeviceFullscreen() async {
  if (document.fullscreenEnabled ?? true) {
    document.documentElement?.requestFullscreen();
  }
}

/// Exit fullscreen mode.
Future<void> exitDeviceFullscreen() async {
  document.exitFullscreen();
}

/// Indicates if the application is in fullscreen mode or not.
bool get isDeviceFullscreen {
  return document.fullscreenElement != null;
}
