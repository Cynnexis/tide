import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';
import 'package:tide/constants.dart';
import 'package:tide/page/settings_page.dart';
import 'package:tide/theme.dart';
import 'package:tide/widget/breathing_bubble.dart';
import 'package:url_launcher/url_launcher.dart' as url;

class HomePage extends StatefulWidget {
  static const routeName = '/';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  /// Indicates if the [BreathingBubble] should be displayed on the screen, or
  /// the button "Start" instead.
  ///
  /// `false` indicates to display the button, while `true` will show the
  /// [BreathingBubble] widget.
  bool _isBreathing = false;

  /// [SnackBar] that will be displayed when the user wants to quit the
  /// application.
  SnackBar? _exitSnackBar;

  /// The animation controller for the start button
  late AnimationController _animationController;

  /// The animation for the start button
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    didChangePlatformBrightness();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1, milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 200,
      end: 230,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.addListener(_updateCircleSize);

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _animationController.dispose();
    _animationController.removeListener(_updateCircleSize);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      TideTheme.setSystemUIOverlayStyle(
          brightness: WidgetsBinding.instance!.window.platformBrightness);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create a snack bar for [WillPopScope] if it is not already created
    _exitSnackBar ??= SnackBar(
      // backgroundColor: TideTheme.getSystem(context).backgroundColor,
      backgroundColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      content: Row(
        children: <Widget>[
          Icon(Icons.exit_to_app, color: TideTheme.light.iconTheme.color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              TideLocalizations.of(context)!.exitConfirmation,
              // style: TextStyle(color: TideTheme.getFontColor(context)),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 4),
    );

    return WillPopScope(
      onWillPop: () {
        // If the user was in breathing mode, return to the screen where the "Start" button was shown, and do NOT pop the current route.
        if (_isBreathing) {
          setState(() => _isBreathing = false);
          // Show a Snackbar
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(_exitSnackBar!);
          return Future<bool>.value(false);
        } else {
          // If not in breathing mode, quit
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          return Future<bool>.value(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          textTheme: TideTheme.light.appBarTheme.textTheme
                  ?.apply(bodyColor: Colors.white) ??
              TideTheme.light.primaryTextTheme.apply(bodyColor: Colors.white),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            onPressed: () => aboutApp(context),
            icon: TideTheme.getLogoImage(imageProvider: TideTheme.logo),
            tooltip: TideLocalizations.of(context)!.appName,
          ),
          title: Text(
            TideLocalizations.of(context)!.appName,
            style: const TextStyle(
                fontFamily: TideTheme.homeFontFamily, fontSize: 26),
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              onPressed: () => pushSettings(),
              icon: const Icon(Icons.settings),
            ),
          ],
          elevation: 0,
        ),
        backgroundColor: TideTheme.primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Builder(builder: (context) {
                return AnimatedSwitcher(
                  duration: const Duration(seconds: 2),
                  // Curves inspired from https://github.com/flutter/flutter/issues/26119#issuecomment-451656779 by [marcoms](https://github.com/marcoms)
                  switchInCurve: const Interval(
                    0.3,
                    1,
                    curve: Curves.linear,
                  ),
                  switchOutCurve: const Interval(
                    0.7,
                    1,
                    curve: Curves.linear,
                  ),
                  child: _isBreathing
                      ? const BreathingBubble()
                      : ClipOval(
                          child: Material(
                            color: Colors.white, // Button color
                            child: InkWell(
                              splashColor: Colors.white70, // Splash color
                              onTap: () => setState(() => _isBreathing = true),
                              child: SizedBox(
                                width: _animation.value,
                                height: _animation.value,
                                child: Center(
                                  child: Text(
                                    TideLocalizations.of(context)!.startButton,
                                    style: const TextStyle(
                                      color: TideTheme.primaryColor,
                                      fontFamily: TideTheme.homeFontFamily,
                                      fontSize: 26,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// Update the size of the circle according to the animation value.
  ///
  /// Do **NOT** use this method to refresh the widget tree.
  void _updateCircleSize() => setState(() {});

  void pushSettings() async {
    await Navigator.pushNamed(context, SettingsPage.routeName);
    setState(() {});
  }

  void aboutApp(BuildContext context) {
    const double iconSize = 32;

    /// Open the given URL using the associated application (defaults to web
    /// browser).
    Future<void> openUrl(String stringUrl) async {
      if (await url.canLaunch(stringUrl)) {
        await url.launch(stringUrl);
      } else if (kDebugMode) {
        dev.log("Couldn't launch URL: $stringUrl", name: "aboutApp.canLaunch");
      }
    }

    /// Copy the given URL to the clipboard.
    Future<void> copyUrl(String stringUrl) async {
      try {
        await Clipboard.setData(ClipboardData(text: stringUrl));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(TideLocalizations.of(context)!.copiedToClipboard)));
      } catch (e) {
        if (kDebugMode) rethrow;
      }
    }

    showAboutDialog(
      context: context,
      applicationName: TideLocalizations.of(context)!.appName,
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          color: Colors.white,
          child: SizedBox(
            width: 60,
            height: 60,
            child: TideTheme.getLogoImage(),
          ),
        ),
      ),
      applicationVersion: appVersion,
      children: <Widget>[
        RichText(
            text: const TextSpan(
                text:
                    "Tide is an application that helps reduce panic attacks with a simple breathing exercise.\n\n",
                children: <InlineSpan>[
              TextSpan(
                  text:
                      "It helps users to calm themselves down by timing the breath in and breath out, and imitating the diaphragm dilatation, while being "),
              TextSpan(
                  text: "free with no advertisements",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ".")
            ])),
        ListTile(
          leading: Image(
            image: AssetImage(
                "assets/images/github${TideTheme.getSystemBrightness(context) == Brightness.dark ? "-light" : ''}.png"),
            width: iconSize,
            height: iconSize,
          ),
          title: RichText(
              text: TextSpan(
                  text: gitRepoURL,
                  style: const TextStyle(
                    color: TideTheme.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => openUrl(gitRepoURL))),
          onLongPress: () => copyUrl(gitRepoURL),
        ),
      ],
    );
  }
}
