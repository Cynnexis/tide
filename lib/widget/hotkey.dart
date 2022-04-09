import 'package:flutter/material.dart';

/// Widget representing a hotkey (or keyboard shortcut).
///
/// It is a text representing a keyboard key (such as "Q", "3", "Ctrl" or "⌘"
/// surrounded by borders to represent the actual key.
class Hotkey extends StatelessWidget {
  final String shortcut;
  final TextStyle? style;
  final EdgeInsets textPadding;
  final VoidCallback? onPressed;

  const Hotkey({
    Key? key,
    required this.shortcut,
    this.style,
    this.textPadding = const EdgeInsets.symmetric(
      vertical: 0.5,
      horizontal: 3.0,
    ),
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color textColor = style?.color ??
        Theme.of(context).textTheme.bodyText1?.color ??
        Colors.white;
    final String? fontFamily = style?.fontFamily;
    final double fontSize = style?.fontSize ?? 10.0;

    final TextStyle defaultStyle = TextStyle(
      color: textColor,
      fontFamily: fontFamily,
      fontSize: fontSize,
    );

    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(2.0)),
          border: Border.all(color: textColor, width: 1.0),
        ),
        child: Padding(
          padding: textPadding,
          child: Text(
            shortcut,
            style: style?.merge(defaultStyle) ?? defaultStyle,
          ),
        ),
      ),
    );
  }
}
