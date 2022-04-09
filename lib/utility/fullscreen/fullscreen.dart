import 'package:tide/utility/fullscreen/fullscreen_stub.dart'
    if (dart.library.html) 'package:tide/utility/fullscreen/fullscreen_web.dart'
    if (dart.library.io) 'package:tide/utility/fullscreen/fullscreen_io.dart';

/// Enter in fullscreen mode.
Future<void> enterFullscreen() => enterDeviceFullscreen();

/// Exit fullscreen mode.
Future<void> exitFullscreen() => exitDeviceFullscreen();

/// Indicates if the application is in fullscreen mode or not.
///
/// Throws an [UnsupportedError] is the platform doesn't support that operation.
bool get isFullscreen => isDeviceFullscreen;

/// Toggle fullscreen mode.
///
/// Throws an [UnsupportedError] is the platform doesn't support that operation.
Future<void> toggleFullscreen() async {
  if (isFullscreen) {
    await exitFullscreen();
  } else {
    await enterFullscreen();
  }
}
