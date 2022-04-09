import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';
import 'package:tide/page/settings_page.dart';
import 'package:tide/theme.dart';
import 'package:tide/utility/about_app_dialog.dart';

class TideAppBar extends AppBar {
  TideAppBar({
    Key? key,
    required BuildContext context,
    bool showSettings = true,
    bool showBackButton = false,
    VoidCallback? onBackButtonPushed,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    Widget? title,
    double titleOpacity = 1.0,
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
    TextStyle? toolbarTextStyle,
    TextStyle? titleTextStyle,
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
    SystemUiOverlayStyle? systemOverlayStyle,
  }) : super(
          key: key,
          leading: leading ??
              _buildLeading(
                context: context,
                showBackButton: showBackButton,
                onBackButtonPushed: onBackButtonPushed,
              ),
          automaticallyImplyLeading: automaticallyImplyLeading,
          title: title ??
              Opacity(
                opacity: titleOpacity,
                child: Text(
                  TideLocalizations.of(context)!.appName,
                  style: const TextStyle(
                    fontFamily: TideTheme.homeFontFamily,
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
              ),
          actions: actions ??
              (showSettings
                  ? <Widget>[
                      IconButton(
                        onPressed: () => pushSettings(context),
                        icon: const Icon(Icons.settings),
                      ),
                    ]
                  : null),
          flexibleSpace: flexibleSpace,
          bottom: bottom,
          elevation: elevation,
          shadowColor: shadowColor,
          shape: shape,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          systemOverlayStyle:
              systemOverlayStyle ?? TideTheme.getSystemOverlayStyle(),
          iconTheme: iconTheme,
          actionsIconTheme: actionsIconTheme,
          titleTextStyle: titleTextStyle ??
              textTheme?.titleMedium?.apply(color: Colors.white),
          toolbarTextStyle: toolbarTextStyle ??
              textTheme?.labelMedium?.apply(color: Colors.white),
          primary: primary,
          centerTitle: centerTitle,
          excludeHeaderSemantics: excludeHeaderSemantics,
          titleSpacing: titleSpacing,
          toolbarOpacity: toolbarOpacity,
          bottomOpacity: bottomOpacity,
          toolbarHeight: toolbarHeight,
          leadingWidth: leadingWidth,
        );

  static Widget _buildLeading({
    required BuildContext context,
    bool showBackButton = false,
    VoidCallback? onBackButtonPushed,
  }) {
    if (showBackButton) {
      return IconButton(
        onPressed: onBackButtonPushed ??
            () {
              Navigator.of(context).pop<void>();
            },
        icon: const Icon(Icons.arrow_back),
        tooltip: TideLocalizations.of(context)!.goBack,
      );
    } else {
      return IconButton(
        onPressed: () => aboutApp(context),
        icon: TideTheme.getLogoImage(imageProvider: TideTheme.logo),
        tooltip: TideLocalizations.of(context)!.appName,
      );
    }
  }

  static Future<void> pushSettings(BuildContext context) async {
    await Navigator.of(context).pushNamed<void>(SettingsPage.routeName);
  }
}
