import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';
import 'package:tide/page/breathing_exercise_page.dart';
import 'package:tide/theme.dart';
import 'package:tide/widget/app_bar.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
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
      duration: const Duration(seconds: 2, milliseconds: 500),
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
      TideTheme.setSystemUIOverlayStyle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TideAppBar(
        context: context,
        backgroundColor: TideTheme.primaryColor,
      ),
      backgroundColor: TideTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ClipOval(
              child: Material(
                color: Colors.white, // Button color
                child: InkWell(
                  splashColor: Colors.white70, // Splash color
                  onTap: pushBreathingExercisePage,
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
          ],
        ),
      ),
    );
  }

  /// Update the size of the circle according to the animation value.
  ///
  /// Do **NOT** use this method to refresh the widget tree.
  void _updateCircleSize() => setState(() {});

  Future<void> pushBreathingExercisePage() async {
    await Navigator.pushNamed<void>(context, BreathingExercisePage.routeName);
  }
}
