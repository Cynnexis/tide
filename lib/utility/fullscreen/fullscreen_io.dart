import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:universal_io/io.dart' as io;

final bool _canUseFullscreen =
    !kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS);

/// Enter in fullscreen mode.
Future<void> enterDeviceFullscreen() async {
  if (_canUseFullscreen) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }
}

/// Exit fullscreen mode.
Future<void> exitDeviceFullscreen() async {
  if (_canUseFullscreen) {
    await SystemChrome.restoreSystemUIOverlays();
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }
}

/// Indicates if the application is in fullscreen mode or not.
///
/// In IO devices, it is not possible to get the current fullscreen mode. This
/// function throws an [UnsupportedError].
bool get isDeviceFullscreen {
  throw UnsupportedError('In IO devices, it is not possible to get the current '
      'fullscreen mode');
}
