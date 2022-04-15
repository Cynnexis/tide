import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_api/src/expect/async_matcher.dart';
import 'package:universal_io/io.dart';

/// Wrap the given [child] in utility widgets to provide locations down the
/// widget tree.
Widget provideLocalizations({
  required Widget child,
  final Key? materialAppKey,
  final Key? materialKey,
  final Key? directionalityKey,
}) {
  return MaterialApp(
    key: materialAppKey,
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const <Locale>[
      Locale('en', ''),
    ],
    home: Material(
      key: materialKey,
      child: Directionality(
        key: directionalityKey,
        textDirection: TextDirection.ltr,
        child: child,
      ),
    ),
  );
}

/// Get the golden file path from the given [filename] and depending of the
/// current platform (that you can override with optional parameter [platform]).
///
/// The supported value for [platform] are:
/// * android
/// * fuchsia
/// * ios
/// * linux
/// * macos
/// * web
/// * windows
String getGoldenFilepath(final String filename, {final String? platform}) {
  // Create a variable that hold the value to use. It is either [platform] (the
  // argument overrides everything), "web" if running on web, or the operating
  // system given by [Platform].
  final String platformToUse =
      platform ?? (kIsWeb ? "web" : Platform.operatingSystem);
  switch (platformToUse) {
    case "android":
    case "fuchsia":
    case "ios":
    case "linux":
    case "macos":
    case "web":
    case "windows":
      return 'golden-images/$platformToUse/$filename';
    default:
      String errorMessage = 'The platform "$platformToUse" is invalid.';
      if (platform != null) {
        throw ArgumentError(errorMessage);
      } else {
        throw OSError(errorMessage);
      }
  }
}

/// Matcher same as [matchesGoldenFile], but with a platform balancer.
///
/// All tests should avoid using [matchesGoldenFile] and pass through this
/// function instead.
///
/// Because the golden file matching is platform-dependent (see Flutter issue
/// #36667 https://github.com/flutter/flutter/issues/36667), it is required to
/// use different golden images per platforms. This function detects the current
/// platform, and automatically fetch the associated golden image.
AsyncMatcher matchesGoldenFilePlatform(
  final String key, {
  int? version,
  final String? platform,
}) {
  // TODO(Cynnexis): As the Flutter issue #36667 (https://github.com/flutter/flutter/issues/36667) suggests, the Flutter version should also be taken into consideration. See https://stackoverflow.com/questions/45999941/how-can-i-get-flutter-version-from-code
  return matchesGoldenFile(
    getGoldenFilepath(key, platform: platform),
    version: version,
  );
}
