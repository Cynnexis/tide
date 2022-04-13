import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';

/// Form to request the user minutes and seconds.
class TimerForm extends StatefulWidget {
  final EdgeInsets padding;
  final TimerFormController? controller;
  final String? shortMinuteText;
  final String? shortSecondText;

  const TimerForm({
    Key? key,
    this.padding = EdgeInsets.zero,
    this.controller,
    this.shortMinuteText,
    this.shortSecondText,
  }) : super(key: key);

  @override
  State createState() => TimerFormState();
}

class TimerFormState extends State<TimerForm> {
  /// Static list of integers from 0 to 59 (both included).
  static final List<int> _l0to59 = List<int>.generate(60, (int i) => i);

  /// Horizontal gap between widgets
  static const SizedBox _horizontalGap = SizedBox(width: 20);

  /// The minute field of the timer.
  ///
  /// Please don't use it directly, use its property [minute] instead.
  int _minutes = 5;

  /// The minute field of the timer.
  ///
  /// The value is in the range [0 ; 59].
  int get minutes => _minutes.clamp(0, 59);

  /// The minute field of the timer.
  ///
  /// The given value must be in the range [0 ; 59]. Setting a new value will
  /// trigger the [widget.onChanged] callback.
  set minutes(int m) {
    if (m != _minutes) {
      if (m < 0 || 59 < m) {
        throw ArgumentError("Expected minute to be in [0 ; 59], got $m.");
      }

      _minutes = m;
      onChanged();
    }
  }

  /// The second field of the timer.
  ///
  /// Please don't use it directly, use its property [minute] instead.
  int _seconds = 0;

  /// The second field of the timer.
  ///
  /// The value is in the range [0 ; 59].
  int get seconds => _seconds.clamp(0, 59);

  /// The second field of the timer.
  ///
  /// The given value must be in the range [0 ; 59]. Setting a new value will
  /// trigger the [widget.onChanged] callback.
  set seconds(int s) {
    if (s != _seconds) {
      if (s < 0 || 59 < s) {
        throw ArgumentError("Expected second to be in [0 ; 59], got $s.");
      }

      _seconds = s;
      onChanged();
    }
  }

  /// The fields as [Duration].
  Duration get duration => Duration(minutes: minutes, seconds: seconds);

  /// Set the timer fields according to [d].
  ///
  /// Thus function calls [setState].
  void setDuration(Duration d, {bool notifyChanges = true}) {
    // Total seconds is the duration, clamped between 0 and 3484s (59 * 59, the
    // maximum amount of seconds the timer accepts)
    int totalSeconds = d.inSeconds % 3485;

    setState(() {
      minutes = (totalSeconds / 60.0).floor().clamp(0, 59);
      seconds = totalSeconds - (minutes * 60);
    });

    if (notifyChanges) {
      onChanged();
    }
  }

  @override
  void initState() {
    super.initState();

    // Listen to controller
    widget.controller?.addListener(onControllerChanged);

    // Invoke the callback at the beginning with the default values
    onChanged();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Row(
        key: widget.key != null ? Key('${getWidgetKeyValue()}_row') : null,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          DropdownButton<int>(
            key: widget.key != null
                ? Key('${getWidgetKeyValue()}_dropdown_button_minutes')
                : null,
            items: rangeItems(
              keyPrefix: widget.key != null ? '${getWidgetKeyValue()}_' : '',
              keySuffix: 'm',
            ),
            value: minutes,
            onChanged: (int? newMinutes) {
              setState(() {
                minutes = newMinutes ?? 5;
              });
            },
          ),
          _horizontalGap,
          Text(getShortMinuteText(context)),
          _horizontalGap,
          DropdownButton<int>(
            key: widget.key != null
                ? Key('${getWidgetKeyValue()}_dropdown_button_seconds')
                : null,
            items: rangeItems(
              keyPrefix: widget.key != null ? '${getWidgetKeyValue()}_' : '',
              keySuffix: 's',
            ),
            value: seconds,
            onChanged: (int? newSeconds) {
              setState(() {
                seconds = newSeconds ?? 0;
              });
            },
          ),
          _horizontalGap,
          Text(getShortSecondText(context)),
        ],
      ),
    );
  }

  /// Return a list of [DropdownMenuItem] containing values between 0 and 60.
  List<DropdownMenuItem<int>> rangeItems({
    final double min = 0,
    double max = 60,
    final String keyPrefix = '',
    final String keySuffix = '',
  }) =>
      _l0to59
          .map<DropdownMenuItem<int>>(
            (int i) => DropdownMenuItem<int>(
              key: Key(keyPrefix + i.toString() + keySuffix),
              child: Text(i.toString()),
              value: i,
            ),
          )
          .toList(growable: false);

  String getShortMinuteText(BuildContext context) =>
      widget.shortMinuteText ?? TideLocalizations.of(context)!.shortMinute;

  String getShortSecondText(BuildContext context) =>
      widget.shortSecondText ?? TideLocalizations.of(context)!.shortSecond;

  /// Get the value of the widget key.
  ///
  /// If there is no key, or the key is not a [ValueKey] with type [String],
  /// [defaultValue] is returned.
  String getWidgetKeyValue({final String defaultValue = ''}) {
    if (widget.key == null || widget.key is! ValueKey<String>) {
      return defaultValue;
    } else {
      return (widget.key! as ValueKey<String>).value;
    }
  }

  /// Function to call when a changes must be reported to controller in this
  /// state.
  ///
  /// This function does **NOT** call [setState].
  void onChanged() {
    // Set the new duration in controller, but don't notify listeners (that
    // would notify the state itself)
    widget.controller?._setDuration(duration, notifyChanges: false);
  }

  /// Callback invoked when the controller changed its values.
  ///
  /// This function calls [setState] if a new value is detected.
  void onControllerChanged() {
    if (widget.controller != null && widget.controller!.duration != duration) {
      // Don't notify the controller, it would create an infinite loop
      setDuration(widget.controller!.duration, notifyChanges: false);
    }
  }
}

/// Controller for [TimerForm].
class TimerFormController extends ChangeNotifier {
  /// The duration associated to the [TimerForm].
  Duration _duration = Duration.zero;

  /// Get the current duration of the associated [TimerForm].
  Duration get duration => _duration;

  /// Set the duration of the associated [TimerForm], and notify listeners.
  set duration(Duration d) => _setDuration(d, notifyChanges: true);

  /// Set the duration of the associated [TimerForm].
  ///
  /// [notifyChanges] let you choose whether to notify listeners or not.
  void _setDuration(Duration d, {bool notifyChanges = true}) {
    _duration = d;
    if (notifyChanges) {
      notifyListeners();
    }
  }

  /// Default constructor for the controller associated to a
  /// [TimerForm] widget.
  ///
  /// Save an instance of [TimerFormController] in your widget state, and pass
  /// it to your [TimerForm]. Use your [TimerFormController] instance to get or
  /// set the [duration].
  TimerFormController();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerFormController &&
          runtimeType == other.runtimeType &&
          _duration == other._duration;

  @override
  int get hashCode => _duration.hashCode;

  @override
  String toString() {
    return 'TimerFormController{_duration: $_duration}';
  }
}
