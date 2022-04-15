import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tide/settings.dart';
import 'package:tide/widget/breathing_bubble.dart';

import 'utils.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Use fake SharedPreferences because of https://github.com/flutter/flutter/issues/97100
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('BreathingBubble Golden file', (final WidgetTester tester) async {
    // Load app settings
    await TideSettings.instance;

    final BreathingBubbleController bubbleController =
        BreathingBubbleController();

    await tester.pumpWidget(
      Directionality(
        key: const Key('directionality'),
        textDirection: TextDirection.ltr,
        child: Center(
          key: const Key('center'),
          child: BreathingBubble(
            key: const Key('breathing_bubble'),
            controller: bubbleController,
            holdBreathText: 'Hold',
            breathInText: 'Breath In',
            breathOutText: 'Breath Out',
          ),
        ),
      ),
    );

    final Finder breathingBubbleFinder =
        find.byKey(const Key('breathing_bubble'));
    expect(breathingBubbleFinder, findsOneWidget);
    expect(bubbleController.status, equals(BreathingBubbleStatus.playing));
    await expectLater(breathingBubbleFinder,
        matchesGoldenFilePlatform('breathing_bubble_1.png'));

    // Wait for expansion animation to finish and go to hold
    await tester.pump(TideSettings.instanceSync.breathingDuration);
    await expectLater(breathingBubbleFinder,
        matchesGoldenFilePlatform('breathing_bubble_2.png'));
  });
}
