import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';

/// [ListTile] showing an error.
class ErrorTile extends ListTile {
  /// Constructor for [ErrorTile].
  ///
  /// It is the same as the constructor for [ListTile], but with dynamic [title]
  /// and [subtitle] (for String and Widget), a default [leading] icon, a
  /// required [context], and the required [error] (nullable).
  ErrorTile({
    final Key? key,
    required final BuildContext context,
    required final Object? error,
    final Widget? leading = const Icon(Icons.error),
    final dynamic title,
    final dynamic subtitle,
    final Widget? trailing,
    final bool isThreeLine = false,
    final bool? dense,
    final VisualDensity? visualDensity,
    final ShapeBorder? shape,
    final Color? selectedColor,
    final Color? iconColor,
    final Color? textColor,
    final ListTileStyle? style,
    final EdgeInsetsGeometry? contentPadding,
    final bool enabled = true,
    final GestureTapCallback? onTap,
    final GestureLongPressCallback? onLongPress,
    final MouseCursor? mouseCursor,
    final bool selected = false,
    final Color? focusColor,
    final Color? hoverColor,
    final FocusNode? focusNode,
    final bool autofocus = false,
    final Color? tileColor,
    final Color? selectedTileColor,
    final bool? enableFeedback,
    final double? horizontalTitleGap,
    final double? minVerticalPadding,
    final double? minLeadingWidth,
  }) : super(
          key: key,
          leading: leading,
          title: _buildTitle(context, title),
          subtitle: _buildSubtitle(subtitle, error),
          trailing: trailing,
          isThreeLine: isThreeLine,
          dense: dense,
          visualDensity: visualDensity,
          shape: shape,
          selectedColor: selectedColor,
          iconColor: iconColor,
          textColor: textColor,
          style: style,
          contentPadding: contentPadding,
          enabled: enabled,
          onTap: _handleOnTap(
            onTap: onTap,
            context: context,
            title: title,
            error: error,
          ),
          onLongPress: onLongPress,
          mouseCursor: mouseCursor,
          selected: selected,
          focusColor: focusColor,
          hoverColor: hoverColor,
          focusNode: focusNode,
          autofocus: autofocus,
          tileColor: tileColor,
          selectedTileColor: selectedTileColor,
          enableFeedback: enableFeedback,
          horizontalTitleGap: horizontalTitleGap,
          minVerticalPadding: minVerticalPadding,
          minLeadingWidth: minLeadingWidth,
        );

  static Widget _buildTitle(final BuildContext context, final dynamic title) {
    if (title is Widget) {
      return title;
    } else if (title is String) {
      return Text(title);
    } else if (title == null) {
      return Text(TideLocalizations.of(context)!.errorOccurred);
    } else {
      throw ArgumentError('Expected title to be a Widget, a String or null, '
          'got "${title.runtimeType}".');
    }
  }

  static Widget? _buildSubtitle(final dynamic subtitle, final Object? error) {
    if (subtitle is Widget) {
      return subtitle;
    } else if (subtitle is String) {
      return Text(subtitle);
    } else if (subtitle == null) {
      if (error != null) {
        return Text(errorToString(error, showStackTrace: false));
      } else {
        return null;
      }
    } else {
      throw ArgumentError('Expected subtitle to be a Widget, a String or null, '
          'got "${subtitle.runtimeType}".');
    }
  }

  static GestureTapCallback? _handleOnTap({
    final GestureTapCallback? onTap,
    final BuildContext? context,
    dynamic title,
    final Object? error,
  }) {
    if (onTap != null) {
      return onTap;
    } else if (context != null) {
      return () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: <Widget>[
                  const Icon(Icons.error),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTitle(context, title)),
                ],
              ),
              content: Text(
                errorToString(error),
                style: const TextStyle(fontFamily: 'RobotoMono'),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop<void>(),
                  child: Text(TideLocalizations.of(context)!.ok),
                ),
              ],
            );
          },
        );
      };
    } else {
      return null;
    }
  }

  /// Convert the given [error] to a string.
  ///
  /// If [error] is null, [nullValue] will be returned.
  static String errorToString(
    final Object? error, {
    final bool showStackTrace = kDebugMode,
    final String nullValue = "(null)",
  }) {
    if (error == null) {
      return nullValue;
    } else if (error is Error) {
      return error.toString() +
          (showStackTrace && error.stackTrace != null
              ? '\n${error.stackTrace}'
              : '');
    } else {
      return error.toString();
    }
  }
}
