import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';
import 'package:tide/settings.dart';
import 'package:tide/theme.dart';
import 'package:tide/widget/animated_breathing.dart';
import 'package:tide/widget/round_button.dart';

/// Widget that represents a circle that grow and shrink to represents the
/// diaphragm movements.
class BreathingBubble extends StatefulWidget {
  final BreathingBubbleController? controller;
  final String? holdBreathText;
  final String? breathInText;
  final String? breathOutText;

  const BreathingBubble({
    Key? key,
    this.controller,
    this.holdBreathText,
    this.breathInText,
    this.breathOutText,
  }) : super(key: key);

  @override
  State createState() => _BreathingBubbleState();
}

class _BreathingBubbleState extends State<BreathingBubble>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;

  @override
  void initState() {
    super.initState();
    TideSettings.instanceSync.addListener(_updateAnimationController);

    _animationController = AnimationController(
      duration: TideSettings.instanceSync.breathingDuration,
      vsync: this,
    );

    if (widget.controller != null) {
      widget.controller!.addListener(_breathingBubbleControllerListener);
    }

    _animationController!.addListener(_updateCircleSize);
    _animationController!.addStatusListener(_animationControllerStatusListener);
    _animationController!.forward();
  }

  @override
  void dispose() {
    TideSettings.instanceSync.removeListener(_updateAnimationController);
    if (_animationController != null) {
      _animationController!.removeListener(_updateCircleSize);
      _animationController!
          .removeStatusListener(_animationControllerStatusListener);
      if (_animationController!.isAnimating ||
          _animationController!.status == AnimationStatus.forward ||
          _animationController!.status == AnimationStatus.reverse) {
        _animationController!.stop(canceled: true);
      }
      _animationController!.dispose();
      _animationController = null;
    }
    if (widget.controller != null) {
      widget.controller!.removeListener(_breathingBubbleControllerListener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: AnimatedBreathing(
          controller: _animationController!,
          smallFactor: 0.6,
          bigFactor: 1.0,
          builder: (
            BuildContext context,
            final double scale,
            final Animation<double> animation,
          ) {
            return RoundButton(
              backgroundColor: Colors.white,
              splashColor: Colors.white70,
              child: SizedBox.square(
                dimension: scale,
                child: Center(
                  child: Builder(
                    builder: (BuildContext context) {
                      // Dynamically generate the text
                      String text = '';
                      switch (_animationStatus) {
                        case AnimationStatus.dismissed:
                        case AnimationStatus.completed:
                          text = getHoldBreathText(context);
                          break;
                        case AnimationStatus.forward:
                          text = getBreathInText(context);
                          break;
                        case AnimationStatus.reverse:
                          text = getBreathOutText(context);
                          break;
                      }
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          text,
                          key: ValueKey<String>(text),
                          style: const TextStyle(
                            color: TideTheme.primaryColor,
                            fontFamily: TideTheme.homeFontFamily,
                            fontSize: 26,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String getHoldBreathText(BuildContext context) {
    return widget.holdBreathText ?? TideLocalizations.of(context)!.holdBreath;
  }

  String getBreathInText(BuildContext context) {
    return widget.breathInText ?? TideLocalizations.of(context)!.breathIn;
  }

  String getBreathOutText(BuildContext context) {
    return widget.breathOutText ?? TideLocalizations.of(context)!.breathOut;
  }

  /// Method that changes the animation status according to [widget.controller]
  /// status.
  void _breathingBubbleControllerListener() {
    // If animation controller is disposed, return
    if (_animationController == null) {
      return;
    }

    // Check that the controller is defined
    if (widget.controller != null) {
      // Switch on the status
      if (kDebugMode) {
        dev.log(
          "widget.controller!.status = ${widget.controller!.status}\n_animationStatus = $_animationStatus",
          name: "_breathingBubbleControllerListener",
        );
      }
      switch (widget.controller!.status) {
        // If the status is now "play", resume the animation (either forward or backward according to [_animationStatus])
        case BreathingBubbleStatus.playing:
          switch (_animationStatus) {
            case AnimationStatus.forward:
              _animationController!.forward();
              break;
            case AnimationStatus.reverse:
              _animationController!.reverse();
              break;
            case AnimationStatus.dismissed:
            case AnimationStatus.completed:
              break;
          }
          break;
        // If the status is now "pause", the animation is stopped
        case BreathingBubbleStatus.paused:
          _animationController!.stop(canceled: false);
          break;
      }
    }
  }

  /// Method that changes the animation status according to the given [status]
  /// and the [widget.controller] status.
  void _animationControllerStatusListener(AnimationStatus status) {
    _animationStatus = status;
    if (widget.controller == null ||
        widget.controller!.status == BreathingBubbleStatus.playing) {
      if (status == AnimationStatus.completed) {
        Future<void>.delayed(TideSettings.instanceSync.holdingBreathDuration,
            () {
          if (_animationController != null &&
              (widget.controller == null ||
                  widget.controller!.status == BreathingBubbleStatus.playing)) {
            _animationController?.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        Future<void>.delayed(TideSettings.instanceSync.holdingBreathDuration,
            () {
          if (_animationController != null &&
              (widget.controller == null ||
                  widget.controller!.status == BreathingBubbleStatus.playing)) {
            _animationController?.forward();
          }
        });
      }
    }
  }

  /// Update the size of the circle according to the animation value.
  ///
  /// Do **NOT** use this method to refresh the widget tree.
  void _updateCircleSize() => setState(() {});

  /// Update the animation duration according to the settings.
  void _updateAnimationController() {
    if (_animationController != null) {
      _animationController!.duration =
          TideSettings.instanceSync.breathingDuration;
    }
  }
}

/// Class to control [BreathingBubble] animation.
class BreathingBubbleController extends ChangeNotifier {
  late BreathingBubbleStatus _status = BreathingBubbleStatus.playing;

  BreathingBubbleStatus get status => _status;

  void play() {
    _status = BreathingBubbleStatus.playing;
    notifyListeners();
  }

  void pause() {
    _status = BreathingBubbleStatus.paused;
    notifyListeners();
  }

  void toggle() {
    switch (_status) {
      case BreathingBubbleStatus.playing:
        pause();
        break;
      case BreathingBubbleStatus.paused:
        play();
        break;
    }
  }
}

/// [BreathingBubble] status.
enum BreathingBubbleStatus {
  /// The [BreathingBubble] animation is being played.
  playing,

  /// The [BreathingBubble] animation is paused.
  paused,
}
