import 'package:flutter/material.dart';
import 'package:tide/theme.dart';
import 'package:tide/widget/app_bar.dart';
import 'package:tide/widget/breathing_bubble.dart';

class BreathingExercisePage extends StatefulWidget {
  static const String routeName = "breathing-exercise";
  static const Duration transitionDuration = Duration(seconds: 2);

  static Widget transitionsBuilder(BuildContext context,
      Animation<double> anim1, Animation<double> anim2, Widget child) {
    return FadeTransition(
      opacity: anim1.drive(Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeInOut))),
      child: child,
    );
  }

  const BreathingExercisePage({Key? key}) : super(key: key);

  @override
  State createState() => _BreathingExercisePageState();
}

class _BreathingExercisePageState extends State<BreathingExercisePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TideAppBar(
        context: context,
      ),
      backgroundColor: TideTheme.primaryColor,
      body: const Center(
        child: BreathingBubble(),
      ),
    );
  }
}
