import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';
import 'package:tide/constants.dart';
import 'package:tide/page/settings_page.dart';
import 'package:tide/theme.dart';
import 'package:tide/widget/breathing_bubble.dart';

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
                // Display the [BreathingBubble] widget if [_isBreathing] is true
                if (_isBreathing) {
                  return const BreathingBubble();
                } else {
                  // Else, display the "Start" button
                  return ClipOval(
                    child: Material(
                      color: Colors.white, // Button color
                      child: InkWell(
                        splashColor: Colors.grey, // Splash color
                        onTap: () => setState(() => _isBreathing = true),
                        child: SizedBox(
                          width: _animation.value,
                          height: _animation.value,
                          child: const Center(
                            child: Text(
                              "Start",
                              style: TextStyle(
                                color: TideTheme.primaryColor,
                                fontFamily: TideTheme.homeFontFamily,
                                fontSize: 26,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
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
    );
  }
}
