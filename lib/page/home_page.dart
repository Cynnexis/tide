import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';
import 'package:tide/page/breathing_exercise_page.dart';
import 'package:tide/theme.dart';
import 'package:tide/utility/fullscreen/fullscreen.dart';
import 'package:tide/widget/app_bar.dart';
import 'package:tide/widget/user_tips.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  //region ATTRIBUTES

  /// The animation controller for this page opacity
  late AnimationController _pageOpacityAnimationController;

  /// The animation for this page opacity
  late Animation<double> _pageOpacityAnimation;

  /// Set animation duration
  static const Duration _startAnimationDuration =
      Duration(seconds: 2, milliseconds: 500);

  /// The animation controller for the start button
  late AnimationController _startAnimationController;

  /// The animation for the start button
  late Animation<double> _startAnimation;

  //endregion

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    didChangePlatformBrightness();

    _pageOpacityAnimationController = AnimationController(
      duration: BreathingExercisePage.transitionDuration,
      vsync: this,
    );
    _pageOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _pageOpacityAnimationController,
      curve: Curves.ease,
    ));
    _pageOpacityAnimationController.addListener(_updateTitleOpacity);

    _startAnimationController = AnimationController(
      duration: _startAnimationDuration,
      vsync: this,
    );

    _startAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _startAnimationController,
      curve: Curves.easeInOut,
    ));
    _startAnimationController.addListener(_updateCircleSize);

    _startAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _pageOpacityAnimationController.dispose();
    _pageOpacityAnimationController.removeListener(_updateTitleOpacity);
    _startAnimationController.dispose();
    _startAnimationController.removeListener(_updateCircleSize);
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: FadeTransition(
          opacity: _pageOpacityAnimation,
          child: TideAppBar(
            context: context,
            backgroundColor: TideTheme.primaryColor,
          ),
        ),
      ),
      backgroundColor: TideTheme.primaryColor,
      body: FadeTransition(
        opacity: _pageOpacityAnimation,
        child: SafeArea(
          minimum: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: LayoutBuilder(
                    builder: (
                      BuildContext context,
                      final BoxConstraints constraints,
                    ) {
                      return SizedBox.fromSize(
                        size: constraints.biggest,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              TideLocalizations.of(context)!.homeDescription,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: TideTheme.homeFontFamily,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Flexible(
                  child: LayoutBuilder(
                    builder: (
                      BuildContext context,
                      final BoxConstraints constraints,
                    ) {
                      // Compute button animation size

                      // Get the smallest dimension of the available space
                      final double smallestMaxDimension =
                          min(constraints.maxWidth, constraints.maxHeight);
                      // Compute the min and max diameter according to available space
                      final double minDiameter = smallestMaxDimension * 0.85;
                      final double maxDiameter = smallestMaxDimension * 1.0;
                      assert(
                        minDiameter < maxDiameter,
                        'Expected minDiameter < maxDiameter, got '
                        'minDiameter=$minDiameter, maxDiameter=$maxDiameter.',
                      );
                      // Current animation value, between 0 and 1
                      final double time = _startAnimation.value;
                      assert(
                        0.0 <= time && time <= 1.0,
                        'Expected time to be between 0.0 and 1.0, got $time.',
                      );
                      // Compute the current diameter of the button
                      final double animatedDiameter =
                          minDiameter + (maxDiameter - minDiameter) * time;
                      assert(
                        animatedDiameter <= smallestMaxDimension,
                        'Expected the size of the button to be less or equal to '
                        'the available space, but got button '
                        'size=$animatedDiameter and available '
                        'space=${smallestMaxDimension}px.',
                      );

                      return SizedBox.fromSize(
                        size: constraints.biggest,
                        child: UnconstrainedBox(
                          child: ClipOval(
                            child: Material(
                              color: Colors.white, // Button color
                              child: InkWell(
                                splashColor: Colors.white70, // Splash color
                                onTap: pushBreathingExercisePage,
                                child: SizedBox.square(
                                  dimension: animatedDiameter,
                                  child: Center(
                                    child: Text(
                                      TideLocalizations.of(context)!
                                          .startButton,
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
                      );
                    },
                  ),
                ),
                Flexible(
                  child: LayoutBuilder(
                    builder: (
                      BuildContext context,
                      final BoxConstraints constraints,
                    ) {
                      return SizedBox.fromSize(
                        size: constraints.biggest,
                        child: const UserTips(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Update the size of the circle according to the animation value.
  ///
  /// Do **NOT** use this method to refresh the widget tree.
  void _updateCircleSize() => setState(() {});

  /// Update the opacity of the title according to the animation value.
  ///
  /// Do **NOT** use this method to refresh the widget tree.
  void _updateTitleOpacity() => setState(() {});

  Future<void> pushBreathingExercisePage() async {
    // Start title opacity animation
    await _pageOpacityAnimationController.forward().orCancel;

    await Navigator.pushNamed<void>(context, BreathingExercisePage.routeName);
    await exitFullscreen();

    await _pageOpacityAnimationController.reverse().orCancel;
  }
}
