import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';
import 'package:logging/logging.dart';
import 'package:quiver/async.dart';
import 'package:tide/theme.dart';
import 'package:tide/widget/app_bar.dart';
import 'package:tide/widget/breathing_bubble.dart';
import 'package:tide/widget/timer_form.dart';

/// Page that contains the breathing exercise.
class BreathingExercisePage extends StatefulWidget {
  static const String routeName = "/breathing-exercise";
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
  /// The timer for the exercise. If `null`, then no timer has been selected by the user.
  CountdownTimer? _countdownTimer;

  /// Stream subscription associated to [_countdownTimer].
  ///
  /// If null, then to timer is set.
  StreamSubscription<CountdownTimer>? _streamTimerSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TideAppBar(
        context: context,
        backgroundColor: TideTheme.primaryColor,
        showSettings: false,
        showBackButton: true,
      ),
      backgroundColor: TideTheme.primaryColor,
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          const BreathingBubble(),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Builder(builder: (BuildContext context) {
                // Display nothing if the timer is not set
                if (_countdownTimer == null) return Container();

                // Else, display the timer current value
                return StreamBuilder<CountdownTimer>(
                  stream: _countdownTimer,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<CountdownTimer> snapshot,
                  ) {
                    // Error handling
                    if (snapshot.hasError) {
                      // If an error has been caught, throw it in debug mode, else print it and ignore it.
                      if (kDebugMode) {
                        throw snapshot.error!;
                      } else {
                        dev.log(
                          "Error: ${snapshot.error!}",
                          time: DateTime.now(),
                          level: Level.SEVERE.value,
                          name: "StreamBuilder<CountdownTimer>",
                          zone: Zone.current,
                          error: snapshot.error,
                          stackTrace:
                              snapshot.error != null && snapshot.error is Error
                                  ? (snapshot.error! as Error).stackTrace
                                  : null,
                        );
                        return Container();
                      }
                    }

                    // No error: check the value
                    // If no data, don't print anything
                    if (!snapshot.hasData) return Container();

                    // Else, print the countdown value
                    return Text(timerToString(snapshot.data!.remaining));
                  },
                );
              }),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  AnimatedSwitcher(
                    duration: const Duration(seconds: 1),
                    child: _countdownTimer == null
                        ? IconButton(
                            icon: const Icon(Icons.timer),
                            onPressed: () => _showTimerDialog(context),
                            tooltip: TideLocalizations.of(context)!
                                .tapToActivateTimer,
                          )
                        : IconButton(
                            icon: const Icon(Icons.stop),
                            onPressed: clearCountdownTimer,
                            tooltip: TideLocalizations.of(context)!.stopTimer,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showTimerDialog(BuildContext context) async {
    TimerFormController timerController = TimerFormController();

    await showDialog<Duration>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(TideLocalizations.of(context)!.setATimer),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TimerForm(
              controller: timerController,
            ),
            Text(TideLocalizations.of(context)!.timerDescription),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop<Duration>(timerController.duration),
            child: Text(TideLocalizations.of(context)!.ok),
          ),
        ],
        alignment: Alignment.center,
      ),
    );

    setCountdownTimer(timerController.duration);
  }

  /// Cancel [_countdownTimer] and set it to `null` so the garbage collector can
  /// remove it.
  ///
  /// This method calls [setState].
  void clearCountdownTimer() {
    _streamTimerSubscription?.cancel();
    _countdownTimer?.cancel();
    setState(() {
      _countdownTimer = null;
    });
  }

  /// Set [_countdownTimer] to a new value according to the given [duration].
  ///
  /// This method calls [clearCountdownTimer] and [setState].
  void setCountdownTimer(Duration duration) {
    clearCountdownTimer();

    setState(() {
      _countdownTimer = CountdownTimer(
        duration,
        const Duration(milliseconds: 100),
      );
      _streamTimerSubscription = _countdownTimer!.listen(null);
      _streamTimerSubscription!.onDone(onTimerCompleted);
    });
  }

  /// Callback for when the timer is done.
  void onTimerCompleted() {
    // TODO(Cynnexis): Make vibration and alarm sound
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text(TideLocalizations.of(context)!.timerDone),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              clearCountdownTimer();
              // Pop the dialog
              Navigator.of(context).pop<void>();
              // Pop the page to return to home
              Navigator.of(context).pop<void>();
            },
            child: Text(TideLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
    clearCountdownTimer();
  }

  /// Convert the given [timer] to a string representing the number of remaining
  /// minutes and seconds.
  ///
  /// The parameter [timer] can be either a [Duration] or a [CountdownTimer] (in
  /// which case, the remaining duration is taken). If the [timer] has an
  /// invalid type, throw an [ArgumentError].
  String timerToString(dynamic timer) {
    if (timer is CountdownTimer) {
      timer = timer.remaining;
    }

    if (timer is! Duration) {
      throw ArgumentError("Expected timer to be a Duration or a "
          "CountdownTimer, got '${timer.runtimeType}'");
    }

    int seconds = timer.inSeconds;
    if (seconds < 60) {
      return TideLocalizations.of(context)!.formatSeconds(seconds);
    } else {
      return TideLocalizations.of(context)!.formatMinutesSeconds(
          timer.inMinutes % 60, timer.inSeconds - timer.inMinutes * 60);
    }
  }
}
