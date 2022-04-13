import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tide/widget/round_button.dart';

void main() {
  testWidgets('RoundButton Golden file', (final WidgetTester tester) async {
    /// Check if the button was clicked
    bool wasClicked = false;

    await tester.pumpWidget(
      Directionality(
        key: const Key('directionality'),
        textDirection: TextDirection.ltr,
        child: LayoutBuilder(
            builder: (BuildContext context, final BoxConstraints constraints) {
          final double maxDimension =
              max(constraints.biggest.width, constraints.biggest.height);

          return SizedBox.square(
            dimension: maxDimension,
            child: RoundButton(
              key: const Key('round_button'),
              backgroundColor: Colors.white,
              onTap: () {
                wasClicked = true;
              },
              child: const Center(
                child: Padding(
                  key: Key('padding'),
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Click me!',
                    key: Key('text'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );

    final Finder roundButtonFinder = find.byKey(const Key('round_button'));
    expect(roundButtonFinder, findsOneWidget);
    await expectLater(
        roundButtonFinder, matchesGoldenFile('golden-images/round_button.png'));

    expect(wasClicked, isFalse);
    await tester.tap(roundButtonFinder);
    expect(wasClicked, isTrue);
  });
}
