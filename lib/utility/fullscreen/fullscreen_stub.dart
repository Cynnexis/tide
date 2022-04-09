import 'package:tide/utility/fullscreen/fullscreen.dart';

final UnimplementedError _error = UnimplementedError('Cannot enter or exit '
    'fullscreen mode without dart:io or dart:html');

/// Enter in fullscreen mode.
///
/// This function is just a template used by Dart conditional imports. Please
/// **do NOT call this function directly**, instead call [enterFullscreen] from
/// `package:tide/utility/fullscreen/fullscreen.dart`, or use the following
/// snippet:
///
/// ```dart
/// import 'package:tide/utility/fullscreen/fullscreen_stub.dart'
///   if (dart.library.html) 'package:tide/utility/fullscreen/fullscreen_web.dart'
///   if (dart.library.io) 'package:tide/utility/fullscreen/fullscreen_io.dart';
///
/// enterFullscreen();
/// ```
Future<void> enterDeviceFullscreen() => throw _error;

/// Exit fullscreen mode.
///
/// This function is just a template used by Dart conditional imports. Please
/// **do NOT call this function directly**, instead call [exitFullscreen] from
/// `package:tide/utility/fullscreen/fullscreen.dart`, or use the following
/// snippet:
///
/// ```dart
/// import 'package:tide/utility/fullscreen/fullscreen_stub.dart'
///   if (dart.library.html) 'package:tide/utility/fullscreen/fullscreen_web.dart'
///   if (dart.library.io) 'package:tide/utility/fullscreen/fullscreen_io.dart';
///
/// exitFullscreen();
/// ```
Future<void> exitDeviceFullscreen() => throw _error;

/// Indicates if the application is in fullscreen mode or not.
///
/// This function is just a template used by Dart conditional imports. Please
/// **do NOT call this function directly**, instead call [isFullscreen] from
/// `package:tide/utility/fullscreen/fullscreen.dart`, or use the following
/// snippet:
///
/// ```dart
/// import 'package:tide/utility/fullscreen/fullscreen_stub.dart'
///   if (dart.library.html) 'package:tide/utility/fullscreen/fullscreen_web.dart'
///   if (dart.library.io) 'package:tide/utility/fullscreen/fullscreen_io.dart';
///
/// isDeviceFullscreen();
/// ```
bool get isDeviceFullscreen => throw _error;
