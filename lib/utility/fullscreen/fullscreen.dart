import 'package:tide/utility/fullscreen/fullscreen_stub.dart'
    if (dart.library.html) 'package:tide/utility/fullscreen/fullscreen_web.dart'
    if (dart.library.io) 'package:tide/utility/fullscreen/fullscreen_io.dart';

/// Enter in fullscreen mode.
///
/// By default, the function won't allow fullscreen if the environment variable
/// `FLUTTER_TEST` is set to `true`. You can change that behavior by setting
/// [force] to `true`.
Future<void> enterFullscreen({bool force = false}) {
  if (!force && const bool.fromEnvironment('FLUTTER_TEST')) {
    return Future<void>.value();
  }
  return enterDeviceFullscreen();
}

/// Exit fullscreen mode.
///
/// By default, the function won't allow fullscreen if the environment variable
/// `FLUTTER_TEST` is set to `true`. You can change that behavior by setting
/// [force] to `true`.
Future<void> exitFullscreen({bool force = false}) {
  if (!force && const bool.fromEnvironment('FLUTTER_TEST')) {
    return Future<void>.value();
  }
  return exitDeviceFullscreen();
}

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
