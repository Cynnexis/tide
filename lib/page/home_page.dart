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
  /// Set minimum diameter of the starting button
  static const double _minStartButtonDiameter = 200;

  /// Set maximum diameter of the starting button
  static const double _maxStartButtonDiameter = 230;

  /// Set animation duration
  static const Duration _animationDuration =
      Duration(seconds: 2, milliseconds: 500);

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
      duration: _animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: _minStartButtonDiameter,
      end: _maxStartButtonDiameter,
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
      body: SafeArea(
        minimum: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // const Text("Click on the button below to start your breathing exercise. You can change the exercise settings by clicking on"),
              Flexible(
                child: Text(
                  TideLocalizations.of(context)!.homeDescription,
                  textAlign: TextAlign.center,
                ),
              ),
              Flexible(
                child: SizedBox(
                  width: _maxStartButtonDiameter,
                  height: _maxStartButtonDiameter,
                  child: UnconstrainedBox(
                    child: ClipOval(
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
                  ),
                ),
              ),
              // Balance the layout with an empty widget
              const Flexible(
                child: SizedBox(
                  width: 1,
                  height: 1,
                ),
              ),
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

  Future<void> pushBreathingExercisePage() async {
    await Navigator.pushNamed<void>(context, BreathingExercisePage.routeName);
  }
}
