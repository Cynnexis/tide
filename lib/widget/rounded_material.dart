import 'package:flutter/material.dart';

class RoundedMaterial extends StatelessWidget {
  final Widget child;
  final BorderRadiusGeometry borderRadius;
  final Color? backgroundColor;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapDownCallback? onTapDown;
  final GestureTapCancelCallback? onTapCancel;
  final ValueChanged<bool>? onHighlightChanged;
  final ValueChanged<bool>? onHover;
  final MouseCursor? mouseCursor;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final MaterialStateProperty<Color?>? overlayColor;
  final Color? splashColor;
  final InteractiveInkFeatureFactory? splashFactory;
  final double? radius;
  final ShapeBorder? customBorder;
  final bool? enableFeedback;
  final bool excludeFromSemantics;

  const RoundedMaterial({
    Key? key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.backgroundColor,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onTapDown,
    this.onTapCancel,
    this.onHighlightChanged,
    this.onHover,
    this.mouseCursor,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.overlayColor,
    this.splashColor,
    this.splashFactory,
    this.radius,
    this.customBorder,
    this.enableFeedback = true,
    this.excludeFromSemantics = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.white.withOpacity(0.1),
      borderRadius: borderRadius,
      child: InkWell(
        child: child,
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        onTapDown: onTapDown,
        onTapCancel: onTapCancel,
        onHighlightChanged: onHighlightChanged,
        onHover: onHover,
        mouseCursor: mouseCursor,
        focusColor: focusColor,
        hoverColor: hoverColor,
        highlightColor: highlightColor,
        overlayColor: overlayColor,
        splashColor: splashColor,
        splashFactory: splashFactory,
        radius: radius,
        customBorder: customBorder,
        enableFeedback: enableFeedback,
        excludeFromSemantics: excludeFromSemantics,
      ),
    );
  }
}
