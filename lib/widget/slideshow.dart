import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

/// Widget presenting all given [children] in the given order.
///
/// This class uses [AnimatedSwitcher] to show all [children]. If the children
/// have the same type, don't forget to add a [Key].
class Slideshow extends StatefulWidget {
  //region ATTRIBUTES

  /// The list of widget to display one after the other in the slideshow.
  ///
  /// When all children have been shown, it will come back to the beginning.
  final List<Widget> children;

  /// The duration to apply for all children.
  ///
  /// This variable can either be a [Duration] that will be applied to all
  /// [children], or a `Iterable<Duration>`.
  final dynamic childrenDurations;

  /// The duration of the transition from one element from [children] to the
  /// next.
  ///
  /// This duration is applied to the given child when that property is set to
  /// a new child. The same duration is used when fading out, unless
  /// [reverseTransitionDuration] is set. Changing [transitionDuration] will not
  /// affect the durations of transitions already in progress.
  final Duration transitionDuration;

  /// The duration of the transition from one element from [children] to the
  /// next.
  ///
  /// This duration is applied to the given child when that property is set to
  /// a new child. Changing [reverseTransitionDuration] will not affect the
  /// durations of transitions already in progress.
  ///
  /// If not set, then the value of [transitionDuration] is used by default.
  final Duration? reverseTransitionDuration;

  /// The animation curve to use when transitioning in a new child.
  ///
  /// This curve is applied to the given child when that property is set to a
  /// new child. Changing [switchInCurve] will not affect the curve of a
  /// transition already in progress.
  ///
  /// The [switchOutCurve] is used when fading out, except that if [children] is
  /// changed while the current child is in the middle of fading in,
  /// [switchInCurve] will be run in reverse from that point instead of jumping
  /// to the corresponding point on [switchOutCurve].
  final Curve switchInCurve;

  /// The animation curve to use when transitioning a previous child out.
  ///
  /// This curve is applied to the child when the child is faded in (or when
  /// the widget is created, for the first child). Changing [switchOutCurve]
  /// will not affect the curves of already-visible widgets, it only affects the
  /// curves of future children.
  ///
  /// If [children] is changed while the current child is in the middle of
  /// fading in, [switchInCurve] will be run in reverse from that point instead
  /// of jumping to the corresponding point on [switchOutCurve].
  final Curve switchOutCurve;

  /// A function that wraps a new child with an animation that transitions
  /// the child in when the animation runs in the forward direction and out
  /// when the animation runs in the reverse direction. This is only called
  /// when a new child is set (not for each build), or when a new
  /// [transitionBuilder] is set. If a new [transitionBuilder] is set, then
  /// the transition is rebuilt for the current child and all previous children
  /// using the new [transitionBuilder]. The function must not return null.
  ///
  /// The default is [AnimatedSwitcher.defaultTransitionBuilder].
  ///
  /// The animation provided to the builder has the [duration] and
  /// [switchInCurve] or [switchOutCurve] applied as provided when the
  /// corresponding child was first provided.
  ///
  /// See also:
  ///
  ///  * [AnimatedSwitcherTransitionBuilder] for more information about
  ///    how a transition builder should function.
  final AnimatedSwitcherTransitionBuilder transitionBuilder;

  /// A function that wraps all of the children that are transitioning out, and
  /// the child that's transitioning in, with a widget that lays all of them
  /// out. This is called every time this widget is built. The function must not
  /// return null.
  ///
  /// The default is [AnimatedSwitcher.defaultLayoutBuilder].
  ///
  /// See also:
  ///
  ///  * [AnimatedSwitcherLayoutBuilder] for more information about
  ///    how a layout builder should function.
  final AnimatedSwitcherLayoutBuilder layoutBuilder;

  //endregion

  Slideshow({
    Key? key,
    required this.children,
    required this.childrenDurations,
    this.transitionDuration = const Duration(seconds: 1),
    this.reverseTransitionDuration,
    this.switchInCurve = Curves.linear,
    this.switchOutCurve = Curves.linear,
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.layoutBuilder = AnimatedSwitcher.defaultLayoutBuilder,
  }) : super(key: key) {
    assert(children.isNotEmpty, 'children cannot be empty.');
    assert(
        childrenDurations is Duration ||
            childrenDurations is Iterable<Duration>,
        'Expected childrenDurations to be a Duration or an Iterable<Duration>, '
        'got "${childrenDurations.runtimeType}".');

    checkDuration(childrenDurations);
  }

  @override
  SlideshowState createState() => SlideshowState();

  /// Check that the [duration] is fitted for the slideshow.
  ///
  /// [duration] can be an instance of [Duration] or `Iterable<Duration>`.
  static void checkDuration(final dynamic duration) {
    if (duration is Duration) {
      // Check value
      if (duration.inMicroseconds <= 0) {
        throw StateError('Expected widget.childrenDurations to be strictly '
            'positive number, got $duration.');
      }
    } else if (duration is Iterable<Duration>) {
      // Check no negative or null value
      for (final Duration d in duration) {
        checkDuration(d);
      }
    } else {
      throw ArgumentError('Expected duration to be a Duration or an '
          'Iterable<Duration>, got "${duration.runtimeType}".');
    }
  }
}

class SlideshowState extends State<Slideshow> {
  //region ATTRIBUTES

  int currentIndex = 0;

  Timer? timer;

  //endregion

  //region PROPERTIES

  /// Return the current child according to [currentIndex].
  Widget get child => widget.children[currentIndex];

  Iterable<Duration> get childrenDurations {
    if (widget.childrenDurations is Duration) {
      return List<Duration>.filled(
        widget.children.length,
        widget.childrenDurations,
        growable: false,
      );
    } else if (widget.childrenDurations is Iterable<Duration>) {
      return widget.childrenDurations;
    } else {
      throw StateError('Expected widget.childrenDurations to be a Duration or '
          'an Iterable<Duration>, got '
          '"${widget.childrenDurations.runtimeType}".');
    }
  }

  Duration get childDuration {
    if (widget.childrenDurations is Duration) {
      return widget.childrenDurations;
    } else {
      return childrenDurations.elementAt(currentIndex);
    }
  }

  //endregion

  @override
  void initState() {
    super.initState();

    timer ??= createTimer();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer?.cancel();
      timer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timer ??= createTimer();

    return AnimatedSwitcher(
      child: child,
      duration: widget.transitionDuration,
      reverseDuration: widget.reverseTransitionDuration,
      switchInCurve: widget.switchInCurve,
      switchOutCurve: widget.switchOutCurve,
      transitionBuilder: widget.transitionBuilder,
      layoutBuilder: widget.layoutBuilder,
    );
  }

  Timer createTimer() => Timer(
        childDuration + widget.transitionDuration,
        timerCallback,
      );

  /// Timer callback.
  ///
  /// This function calls [setState].
  void timerCallback() {
    // Process the next child
    setState(() {
      currentIndex = (currentIndex + 1) % widget.children.length;
      if (kDebugMode) {
        dev.log(
          '${widget.toStringShort()} shows element $currentIndex (0-indexed) over ${widget.children.length}: $child',
          time: DateTime.now(),
          level: Level.FINE.value,
          name: 'Slideshow{${widget.toStringShort()}}',
          zone: Zone.current,
        );
      }
    });

    // Program next timer
    timer = createTimer();
  }
}
