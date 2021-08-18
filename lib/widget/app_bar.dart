import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tide/page/settings_page.dart';
import 'package:tide/theme.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';
import 'package:tide/utility/about_app_dialog.dart';

class TideAppBar extends AppBar {
  TideAppBar({
    Key? key,
    required BuildContext context,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    Widget? title,
    List<Widget>? actions,
    Widget? flexibleSpace,
    PreferredSizeWidget? bottom,
    double? elevation = 0.0,
    Color? shadowColor,
    ShapeBorder? shape,
    Color? backgroundColor,
    Color? foregroundColor,
    Brightness? brightness,
    IconThemeData? iconTheme = const IconThemeData(color: Colors.white),
    IconThemeData? actionsIconTheme,
    TextTheme? textTheme,
    bool primary = true,
    bool? centerTitle = true,
    bool excludeHeaderSemantics = false,
    double? titleSpacing,
    double toolbarOpacity = 1.0,
    double bottomOpacity = 1.0,
    double? toolbarHeight,
    double? leadingWidth,
    bool? backwardsCompatibility,
    TextStyle? toolbarTextStyle,
    TextStyle? titleTextStyle,
    SystemUiOverlayStyle? systemOverlayStyle,
  }) : super(
          key: key,
          leading: leading ??
              IconButton(
                onPressed: () => aboutApp(context),
                icon: TideTheme.getLogoImage(imageProvider: TideTheme.logo),
                tooltip: TideLocalizations.of(context)!.appName,
              ),
          automaticallyImplyLeading: automaticallyImplyLeading,
          title: title ??
              Text(
                TideLocalizations.of(context)!.appName,
                style: const TextStyle(
                    fontFamily: TideTheme.homeFontFamily, fontSize: 26),
              ),
          actions: actions ??
              <Widget>[
                IconButton(
                  onPressed: () => pushSettings(context),
                  icon: const Icon(Icons.settings),
                ),
              ],
          flexibleSpace: flexibleSpace,
          bottom: bottom,
          elevation: elevation,
          shadowColor: shadowColor,
          shape: shape,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          brightness: brightness,
          iconTheme: iconTheme,
          actionsIconTheme: actionsIconTheme,
          textTheme: textTheme ??
              TideTheme.light.appBarTheme.textTheme
                  ?.apply(bodyColor: Colors.white) ??
              TideTheme.light.primaryTextTheme.apply(bodyColor: Colors.white),
          primary: primary,
          centerTitle: centerTitle,
          excludeHeaderSemantics: excludeHeaderSemantics,
          titleSpacing: titleSpacing,
          toolbarOpacity: toolbarOpacity,
          bottomOpacity: bottomOpacity,
          toolbarHeight: toolbarHeight,
          leadingWidth: leadingWidth,
          backwardsCompatibility: backwardsCompatibility,
          toolbarTextStyle: toolbarTextStyle,
          titleTextStyle: titleTextStyle,
          systemOverlayStyle: systemOverlayStyle,
        );

  static void pushSettings(BuildContext context) async {
    await Navigator.pushNamed(context, SettingsPage.routeName);
  }
}
