import 'dart:math';

import 'package:flutter/material.dart';

typedef AnimationBuilder<T> = Widget Function(
  BuildContext context,
  double scale,
  Animation<T> animation,
);

/// Animation widget that allow you to change the size of a widget using a
/// breathing animation.
///
/// Example:
///
/// ```
/// AnimatedBreathing(
///   controller: _animationController,
///   builder: (
///     BuildContext context,
///     final double scale,
///     final Animation<double> animation,
///   ) {
///     return Container(
///       width: scale,
///       height: scale,
///       decoration: BoxDecoration(
///         color: Colors.white,
///         shape: BoxShape.circle,
///         border: Border.all(color: Colors.white),
///       ),
///     );
///   },
/// );
/// ```
class AnimatedBreathing extends StatefulWidget {
  /// The animation controller, to make the user control the animation.
  ///
  /// It will be associated to an animation after the first frame is built.
  final AnimationController controller;

  /// The builder callback.
  ///
  /// It takes as argument a [BuildContext] and an [Animation] (with the type
  /// parameter [double]). You can build your widget and use the
  /// [Animation.value] to change the size of your object.
  final AnimationBuilder<double> builder;

  /// The factor to apply when the widget is small.
  ///
  /// It must be a number between 0.0 and 1.0.
  final double smallFactor;

  /// The factor to apply when the widget is big.
  ///
  /// It must be a number between 0.0 and 1.0.
  final double bigFactor;

  /// The animation curve.
  final Curve curve;

  /// Default constructor for [AnimatedBreathing].
  const AnimatedBreathing({
    Key? key,
    required this.controller,
    required this.builder,
    this.smallFactor = 0.85,
    this.bigFactor = 1.0,
    this.curve = Curves.easeInOut,
  })  : assert(0.0 <= smallFactor && smallFactor <= 1.0),
        assert(0.0 <= bigFactor && bigFactor <= 1.0),
        assert(smallFactor <= bigFactor),
        super(key: key);

  @override
  AnimatedBreathingState createState() => AnimatedBreathingState();
}

@visibleForTesting
class AnimatedBreathingState extends State<AnimatedBreathing> {
  Animation<double>? _animation;

  @override
  Widget build(BuildContext context) {
    _animation ??= Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.controller,
      curve: widget.curve,
    ));

    return LayoutBuilder(
      builder: (BuildContext context, final BoxConstraints constraints) {
        // Compute button animation size

        // Get the smallest dimension of the available space
        final double smallestMaxDimension =
            min(constraints.maxWidth, constraints.maxHeight);
        // Compute the min and max diameter according to available space
        final double minDiameter = smallestMaxDimension * widget.smallFactor;
        final double maxDiameter = smallestMaxDimension * widget.bigFactor;
        assert(
          minDiameter <= maxDiameter,
          'Expected minDiameter <= maxDiameter, got '
          'minDiameter=$minDiameter, maxDiameter=$maxDiameter.',
        );
        // Current animation value, between 0 and 1
        final double time = _animation!.value;
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
            child: widget.builder(context, animatedDiameter, _animation!),
          ),
        );
      },
    );
  }
}
