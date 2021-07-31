import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';
import 'package:tide/settings.dart';
import 'package:tide/theme.dart';

/// Widget that represents a circle that grow and shrink to represents the
/// diaphragm movements.
class BreathingBubble extends StatefulWidget {
  final BreathingBubbleController? controller;

  const BreathingBubble({Key? key, this.controller}) : super(key: key);

  @override
  State createState() => _BreathingBubbleState();
}

class _BreathingBubbleState extends State<BreathingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;

  @override
  void initState() {
    super.initState();
    TideSettings.instanceSync.addListener(_updateAnimationController);

    _animationController = AnimationController(
      duration: TideSettings.instanceSync.breathingDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 100,
      end: 200,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.controller != null) {
      widget.controller!.addListener(_breathingBubbleControllerListener);
    }

    _animationController.addListener(_updateCircleSize);
    _animationController.addStatusListener(_animationControllerStatusListener);
    _animationController.forward();
  }

  @override
  void dispose() {
    TideSettings.instanceSync.removeListener(_updateAnimationController);
    _animationController.dispose();
    if (widget.controller != null) {
      widget.controller!.removeListener(_breathingBubbleControllerListener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: _animation.value,
            height: _animation.value,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white),
            ),
          ),
          Builder(builder: (context) {
            // Dynamically generate the text
            String text = '';
            switch (_animationStatus) {
              case AnimationStatus.dismissed:
              case AnimationStatus.completed:
                text = TideLocalizations.of(context)!.holdBreath;
                break;
              case AnimationStatus.forward:
                text = TideLocalizations.of(context)!.breathIn;
                break;
              case AnimationStatus.reverse:
                text = TideLocalizations.of(context)!.breathOut;
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
                  fontSize: 18,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Method that changes the animation status according to [widget.controller]
  /// status.
  void _breathingBubbleControllerListener() {
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
            case AnimationStatus.dismissed:
            case AnimationStatus.forward:
              _animationController.forward();
              break;
            case AnimationStatus.completed:
            case AnimationStatus.reverse:
              _animationController.reverse();
              break;
          }
          break;
        // If the status is now "pause", the animation is stopped
        case BreathingBubbleStatus.paused:
          _animationController.stop(canceled: false);
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
        Future.delayed(TideSettings.instanceSync.holdingBreathDuration, () {
          if (widget.controller == null ||
              widget.controller!.status == BreathingBubbleStatus.playing) {
            _animationController.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        Future.delayed(TideSettings.instanceSync.holdingBreathDuration, () {
          if (widget.controller == null ||
              widget.controller!.status == BreathingBubbleStatus.playing) {
            _animationController.forward();
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
    _animationController.duration = TideSettings.instanceSync.breathingDuration;
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
