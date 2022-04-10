import 'package:flutter/material.dart';
import 'package:tide/widget/rounded_material.dart';

/// Button that can be placed in a [TextSpan] or [RichText].
class ButtonSpan extends WidgetSpan {
  ButtonSpan({
    required final Widget child,
    final VoidCallback? onTap,
    final Widget? leading,
    final Color? backgroundColor,
    final PlaceholderAlignment alignment = PlaceholderAlignment.bottom,
    final TextBaseline? baseline,
    final TextStyle? style,
  }) : super(
          child: RoundedMaterial(
            onTap: onTap,
            backgroundColor: backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: leading != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        leading,
                        child,
                      ],
                    )
                  : child,
            ),
          ),
          alignment: PlaceholderAlignment.middle,
        );
}
