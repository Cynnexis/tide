import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';
import 'package:logging/logging.dart';
import 'package:tide/page/settings_page.dart';
import 'package:tide/utility/extension/list_extension.dart';
import 'package:tide/utility/fullscreen/fullscreen.dart';
import 'package:tide/widget/button_span.dart';
import 'package:tide/widget/hotkey.dart';
import 'package:tide/widget/slideshow.dart';

class UserTips extends StatelessWidget {
  final TextStyle? style;

  const UserTips({
    Key? key,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Widget emptyWidget = SizedBox.square(dimension: 1);
    final List<Widget> slides = buildTips(context).intersperseCopy(
      emptyWidget,
      growable: true,
    )..add(emptyWidget);

    return Slideshow(
      children: slides,
      childrenDurations: <Duration>[
        for (int i = 0; i < slides.length; ++i)
          i.isEven
              ? const Duration(seconds: 5)
              : const Duration(milliseconds: 500),
      ],
    );
  }

  List<Widget> buildTips(BuildContext context) {
    // List of widgets that will be returned
    final List<Widget> widgetTips = <Widget>[];

    // Placeholders in the tips are actually meant for [WidgetSpan]s, and not
    // another string. This variable will be used as a default string, complex
    // enough to appear as a placeholder. It will then be used to split the
    // string and add the [WidgetSpan]s instead.
    const String splitPlaceholder = "{{##!PLACEHOLDER!##}}";

    // The default text style for the tips
    final TextStyle? defaultTextStyle = style ??
        Theme.of(context).textTheme.bodyText1?.copyWith(
              fontStyle: FontStyle.italic,
            );

    /// Add a new tip to the list [widgetTips] from a string and a [widget].
    ///
    /// [str] is the tip as a string. If it contains a [splitPlaceholder], it
    /// will be slit and then joined again (without the placeholder), and with
    /// [widget] between (if non-null).
    void addTipWithPlaceholder(
      final String str, {
      final WidgetSpan? widgetPlaceholder,
      final String placeholder = splitPlaceholder,
      final Key? key,
    }) {
      final List<String> parts = str.split(placeholder);

      final List<InlineSpan> spans = <InlineSpan>[];
      for (int i = 0; i < parts.length; i++) {
        spans.add(TextSpan(text: parts[i]));
        if (widgetPlaceholder != null && i + 1 < parts.length) {
          spans.add(widgetPlaceholder);
        }
      }

      final Widget tipWidget = Text.rich(
        TextSpan(
          children: spans,
          style: defaultTextStyle,
        ),
        softWrap: true,
        overflow: TextOverflow.fade,
      );

      widgetTips.add(buildTipTile(tipWidget, key: key));
    }

    // Add the fullscreen tip only in web
    if (kIsWeb) {
      final String rawFullscreenTip =
          TideLocalizations.of(context)!.fullscreenTip(splitPlaceholder);
      addTipWithPlaceholder(
        rawFullscreenTip,
        widgetPlaceholder: WidgetSpan(
          child: Hotkey(
            shortcut: 'F11',
            onPressed: () {
              try {
                toggleFullscreen();
              } catch (error) {
                if (error is! UnsupportedError) {
                  rethrow;
                }

                // If error is an [UnsupportedError], ignore
                if (kDebugMode) {
                  dev.log(
                    'Could not toggle fullscreen.',
                    time: DateTime.now(),
                    level: Level.FINE.value,
                    name: 'UserTips',
                    zone: Zone.current,
                    error: error,
                    stackTrace: error.stackTrace,
                  );
                }
              }
            },
          ),
          alignment: PlaceholderAlignment.middle,
          baseline: TextBaseline.ideographic,
        ),
        key: const Key('fullscreenTip'),
      );
    }

    // Add breathing duration tip
    {
      final String rawBreathingDurationTip =
          TideLocalizations.of(context)!.breathingDurationTip(splitPlaceholder);
      addTipWithPlaceholder(
        rawBreathingDurationTip,
        widgetPlaceholder: ButtonSpan(
          onTap: () {
            Navigator.of(context).pushNamed<void>(SettingsPage.routeName);
          },
          leading: const Icon(Icons.settings),
          child: Text(TideLocalizations.of(context)!.settings),
          alignment: PlaceholderAlignment.middle,
        ),
        key: const Key('breathingDurationTip'),
      );
    }

    // Add "You'll be okay! 🌺" tip
    widgetTips.add(buildTipTile(
      Text(
        TideLocalizations.of(context)!.youWillBeOkayTip,
        style: defaultTextStyle,
      ),
      key: const Key('youWillBeOkayTip'),
    ));

    // Add "You made it there, you can do it! 🌻" tip
    widgetTips.add(buildTipTile(
      Text(
        TideLocalizations.of(context)!.youMadeItThereTip,
        style: defaultTextStyle,
      ),
      key: const Key('youMadeItThereTip'),
    ));

    // Add "Whatever it is, you're strong enough! 💐" tip
    widgetTips.add(buildTipTile(
      Text(
        TideLocalizations.of(context)!.youAreStrongEnough,
        style: defaultTextStyle,
      ),
      key: const Key('youAreStrongEnough'),
    ));

    // Shuffle the tips
    widgetTips.shuffle();

    return widgetTips;
  }

  Widget buildTipTile(final Widget tipWidget, {final Key? key}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: Colors.white.withOpacity(0.1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.lightbulb_outline_rounded),
            const SizedBox(width: 8),
            Flexible(child: tipWidget),
          ],
        ),
      ),
    );
  }
}
