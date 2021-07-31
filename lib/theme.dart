import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TideTheme {
  static const MaterialColor primarySwatch = Colors.cyan;
  static const Color primaryColor = Color(0xFF00ACC1); // Colors.cyan[600]
  static const Color accentColor = Colors.lightBlueAccent;

  static const Color defaultDarkBackgroundColor = Color(0xFF2E2E2E);
  static const Color defaultLightBackgroundColor = Color(0xFFFAFAFA);

  static ThemeData getTheme([Brightness brightness = Brightness.light]) {
    ThemeData themeData = ThemeData(
      primarySwatch: primarySwatch,
      primaryColor: primaryColor,
      brightness: brightness,
    );
    themeData = themeData.copyWith(
        colorScheme: themeData.colorScheme.copyWith(secondary: accentColor));
    return themeData;
  }

  static Color defaultBackgroundColor(BuildContext context) =>
      getSystemBrightness(context) == Brightness.dark
          ? defaultDarkBackgroundColor
          : defaultLightBackgroundColor;

  /// Return the logo of the application.
  ///
  /// See [getLogoImage] to get the logo as a widget.
  static ImageProvider get logo => const AssetImage("assets/images/tide.png");

  /// Return the logo foreground of the application.
  ///
  /// See [getLogoImage] to get the logo as a widget.
  static ImageProvider get logoForeground => const AssetImage("assets/images/tide_foreground.png");

  /// Return the logo background of the application.
  ///
  /// See [getLogoImage] to get the logo as a widget.
  static ImageProvider get logoBackground => const AssetImage("assets/images/tide_background.png");

  /// Get the logo of the application as a widget.
  ///
  /// The image provider can be given with [imageProvider], but oactually one of
  /// the following is expected: [logo], [logoForeground] or [logoBackground].
  /// Defaults to [logo].
  ///
  /// The image corners can be polished using [borderRadius]. You can set it to
  /// a radius number to be used as a metric for all corners, or give a
  /// [BorderRadius] instance.
  static Widget getLogoImage({ImageProvider? imageProvider, dynamic borderRadius}) {
    Image image = Image(image: imageProvider ?? TideTheme.logo);
    Widget child = image;
    if (borderRadius != null) {
      if (borderRadius is num) {
        child = ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius.toDouble()),
          child: image,
        );
      } else if (borderRadius is BorderRadius) {
        child = ClipRRect(
          borderRadius: borderRadius,
          child: image,
        );
      } else {
        throw StateError("Invalid type for borderRadius: "
            "${borderRadius.runtimeType}");
      }
    }

    return AspectRatio(aspectRatio: 1, child: child);
  }

  static void setSystemUIOverlayStyle(
      {Brightness? brightness, BuildContext? context}) {
    if (brightness == null && context == null) {
      throw ArgumentError("brightness and context cannot be both null.");
    }

    brightness ??= getSystemBrightness(context!);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: primaryColor,
    ));
  }

  static Brightness getSystemBrightness(BuildContext context) =>
      MediaQuery.of(context).platformBrightness;

  static ThemeData getSystem(BuildContext context) =>
      getTheme(getSystemBrightness(context));

  static Color getFontColor(BuildContext context) =>
      getSystemBrightness(context).invert().color;

  static TextStyle getTextStyle(BuildContext context) =>
      TextStyle(color: getFontColor(context));

  static IconThemeData getIconThemeData(BuildContext context) =>
      IconThemeData(color: getFontColor(context));

  static ThemeData get light => getTheme(Brightness.light);

  static ThemeData get dark => getTheme(Brightness.dark);
}

extension BrightnessExtension on Brightness {
  Brightness invert() =>
      this == Brightness.light ? Brightness.dark : Brightness.light;
  Brightness operator ~() => invert();

  Color get color => this == Brightness.light ? Colors.white : Colors.black;

  SystemUiOverlayStyle get systemUiOverlayStyle => this == Brightness.light
      ? SystemUiOverlayStyle.light
      : SystemUiOverlayStyle.dark;
}
