import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tide/widget/timer_form.dart';

import 'utils.dart';

void main() {
  testWidgets('TimerForm Golden file', (final WidgetTester tester) async {
    final TimerFormController timerController = TimerFormController();

    await tester.pumpWidget(
      provideLocalizations(
        child: TimerForm(
          key: const Key('timer_form'),
          controller: timerController,
          shortMinuteText: 'm',
          shortSecondText: 's',
        ),
      ),
    );

    // Set initial value
    timerController.duration = const Duration(minutes: 5, seconds: 26);
    expect(timerController.duration,
        equals(const Duration(minutes: 5, seconds: 26)));

    final Finder timerFormFinder = find.byKey(const Key('timer_form'));
    expect(timerFormFinder, findsOneWidget);
    await expectLater(
        timerFormFinder, matchesGoldenFile('golden-images/timer_form.png'));

    // Find widgets
    final Finder minutesDropdownFinder =
        find.byKey(const Key('timer_form_dropdown_button_minutes'));
    final Finder t11mFinder = find.byKey(const Key('timer_form_11m'));
    final Finder secondsDropdownFinder =
        find.byKey(const Key('timer_form_dropdown_button_seconds'));
    final Finder t31sFinder = find.byKey(const Key('timer_form_31s'));
    expect(minutesDropdownFinder, findsOneWidget);
    expect(t11mFinder, findsOneWidget);
    expect(secondsDropdownFinder, findsOneWidget);
    expect(t31sFinder, findsOneWidget);
  });
}
