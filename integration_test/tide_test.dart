import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:tide/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;

  // TODO(Cynnexis): Find a more elegant solution to warn the app that it is performing tests
  if (!const bool.fromEnvironment('FLUTTER_TEST')) {
    throw FlutterError('Please pass --dart-define=FLUTTER_TEST=true when '
        'launching the integration tests.');
  }

  group('Basic exploration', () {
    testWidgets('See about dialog', (final WidgetTester tester) async {
      // Run the application
      app.main(<String>['--locale', 'en']);
      await tester.pump(const Duration(seconds: 5));

      // Click on app icon
      final Finder appIcon = find.byKey(const Key('tide_app_bar_about_button'));
      expect(appIcon, findsOneWidget);
      await tester.tap(appIcon);
      await tester.pump(const Duration(seconds: 1));

      // Assert that dialog box is shown
      final Finder dialogBoxAppIcon =
          find.byKey(const Key('about_dialog_app_icon'));
      expect(dialogBoxAppIcon, findsOneWidget);

      // Open licenses view
      final Finder viewLicensesButton = find.text('VIEW LICENSES');
      expect(viewLicensesButton, findsWidgets);
      await tester.tap(viewLicensesButton.first);
      await tester.pump(const Duration(seconds: 1));

      // Close licenses view
      final Finder backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsWidgets);
      await tester.tap(backButton.first);
      await tester.pump(const Duration(seconds: 1));

      // Close dialog box
      final Finder closeDialogButton = find.text('CLOSE');
      expect(closeDialogButton, findsWidgets);
      await tester.tap(closeDialogButton.first);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Start exercise', (final WidgetTester tester) async {
      // Run the application
      app.main(<String>['--locale', 'en']);
      await tester.pump(const Duration(seconds: 5));

      // Click on "start"
      final Finder startButton =
          find.byKey(const Key('tide_home_start_button_round_button'));
      expect(startButton, findsOneWidget);
      await tester.tap(startButton);
      // ... Breath a little bit, little tester... Life's stressful...
      await tester.pump(const Duration(seconds: 5));

      // Assert that the breathing bubble is here
      final Finder breathingBubble =
          find.byKey(const Key('tide_breathing_bubble'));
      expect(breathingBubble, findsOneWidget);

      /*
      // TODO(Cynnexis): The tester cannot click on dropdown. Timer test is thus commented.

      // Click on the timer
      final Finder timerButton =
          find.byKey(const Key('tide_breathing_ex_start_timer'));
      expect(timerButton, findsOneWidget);
      await tester.tap(timerButton);
      await tester.pump(const Duration(seconds: 1));

      // Assert that the dialog box is shown
      final Finder timerDialogBox =
          find.byKey(const Key('breathing_ex_timer_dialog_box'));
      expect(timerDialogBox, findsOneWidget);

      // Find dropdown
      final Finder minutesDropdown = find.byKey(const Key('tide_breathing_ex_'
          'timer_form_dropdown_button_minutes'));
      final Finder secondsDropdown = find.byKey(const Key('tide_breathing_ex_'
          'timer_form_dropdown_button_seconds'));
      expect(minutesDropdown, findsOneWidget);
      expect(secondsDropdown, findsOneWidget);

      // Select 5 min and 0 sec

      // Search for 5min item
      await tester.tap(minutesDropdown);
      await tester.pump(const Duration(seconds: 1));
      final Finder t5min = find.descendant(of: find.byKey(const Key('tide_breathing_ex_timer_form_'
          '5m')).first, matching: find.text('5'));
      // scroll doesn't work with dropdown: Bad state: Too many elements
      //await tester.scrollUntilVisible(t5min.first, 10, maxScrolls: 200);
      await tester.tap(t5min.first);
      await tester.pump(const Duration(seconds: 1));

      // Search for 0sec item
      await tester.tap(secondsDropdown);
      await tester.pump(const Duration(seconds: 1));
      final Finder t0sec = find.byKey(const Key('tide_breathing_ex_timer_form_'
          '0s'));
      // scroll doesn't work with dropdown: Bad state: Too many elements
      //await tester.scrollUntilVisible(t0sec.first, 10, maxScrolls: 200);
      await tester.tap(t0sec.first);
      await tester.pump(const Duration(seconds: 1));

      // Click ok button
      final Finder timerOkButton = find.byKey(const Key('tide_breathing_ex_'
          'timer_form_ok_button'));
      await tester.tap(timerOkButton);
      await tester.pump(const Duration(seconds: 1));

      // Check timer is set
      final Finder remainingTimeText =
          find.byKey(const Key('tide_breathing_ex_remaining_time_text'));
      expect(remainingTimeText, findsOneWidget);

      // Disable timer
      final Finder stopTimerButton =
          find.byKey(const Key('tide_breathing_ex_stop_timer'));
      await tester.tap(stopTimerButton);
      await tester.pump(const Duration(seconds: 1));

      // Put timer to 0 min 5 sec
      await tester.tap(timerButton);
      await tester.pump(const Duration(seconds: 1));
      expect(timerDialogBox, findsOneWidget);
      expect(minutesDropdown, findsOneWidget);
      expect(secondsDropdown, findsOneWidget);

      // Search for 5min item
      await tester.tap(minutesDropdown);
      await tester.pump(const Duration(seconds: 1));
      final Finder t0min = find.byKey(const Key('tide_breathing_ex_timer_form_'
          '0m'));
      // scroll doesn't work with dropdown: Bad state: Too many elements
      //await tester.scrollUntilVisible(t0min.first, -10, maxScrolls: 200);
      await tester.tap(t0min.first);
      await tester.pump(const Duration(seconds: 1));

      // Search for 0sec item
      await tester.tap(secondsDropdown);
      await tester.pump(const Duration(seconds: 1));
      final Finder t5sec = find.byKey(const Key('tide_breathing_ex_timer_form_'
          '5s'));
      // scroll doesn't work with dropdown: Bad state: Too many elements
      //await tester.scrollUntilVisible(t5sec.first, -10, maxScrolls: 200);
      await tester.tap(t5sec.first);
      await tester.pump(const Duration(seconds: 1));

      // Wait for timer to finish
      await tester.pump(const Duration(seconds: 10));

      // Detect alert dialog box
      final Finder timerFinishDialog = find.byKey(const Key('tide_breathing_ex_'
          'timer_finished_dialog'));
      expect(timerFinishDialog, findsOneWidget);

      // Close dialog
      final Finder timerFinishedDialogOkButton = find.byKey(const Key('tide_'
          'breathing_ex_timer_finished_dialog_ok_button'));
      await tester.tap(timerFinishedDialogOkButton);
      await tester.pump(const Duration(seconds: 1));
      */

      // Back to home screen
      final Finder backButton = find.byKey(const Key(kIsWeb
          ? 'tide_app_bar_back_button'
          : 'tide_breathing_ex_back_button'));
      await tester.tap(backButton);
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
