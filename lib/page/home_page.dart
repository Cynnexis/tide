import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';
import 'package:tide/page/breathing_exercise_page.dart';
import 'package:tide/theme.dart';
import 'package:tide/utility/fullscreen/fullscreen.dart';
import 'package:tide/widget/animated_breathing.dart';
import 'package:tide/widget/app_bar.dart';
import 'package:tide/widget/round_button.dart';
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
                  key: const Key('tide_home_description'),
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
                  key: const Key('tide_home_start_button_flexible'),
                  child: AnimatedBreathing(
                    controller: _startAnimationController,
                    builder: (
                      BuildContext context,
                      final double scale,
                      final Animation<double> animation,
                    ) {
                      return RoundButton(
                        key: const Key('tide_home_start_button_round_button'),
                        clipOvalKey:
                            const Key('tide_home_start_button_clip_oval'),
                        materialKey:
                            const Key('tide_home_start_button_material'),
                        inkWellKey:
                            const Key('tide_home_start_button_ink_well'),
                        backgroundColor: Colors.white,
                        splashColor: Colors.white70,
                        onTap: pushBreathingExercisePage,
                        child: SizedBox.square(
                          key: const Key('tide_home_start_button_sized_box'),
                          dimension: scale,
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
                      );
                    },
                  ),
                ),
                Flexible(
                  key: const Key('tide_home_tips_flexible'),
                  child: LayoutBuilder(
                    builder: (
                      BuildContext context,
                      final BoxConstraints constraints,
                    ) {
                      return SizedBox.fromSize(
                        size: constraints.biggest,
                        child: const UserTips(key: Key('tide_home_tips')),
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
