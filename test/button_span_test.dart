import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tide/widget/button_span.dart';
import 'package:tide/widget/hotkey.dart';

void main() {
  testWidgets('ButtonSpan Golden file', (final WidgetTester tester) async {
    /// Check if the button was clicked
    bool wasClicked = false;

    await tester.pumpWidget(
      Directionality(
        key: const Key('directionality'),
        textDirection: TextDirection.ltr,
        child: Material(
          color: Colors.white,
          child: Center(
            key: const Key('center'),
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  const TextSpan(text: 'Visit the '),
                  ButtonSpan(
                    key: const Key('button_span'),
                    leading: const Icon(Icons.open_in_new),
                    child: const Text('Flutter'),
                    alignment: PlaceholderAlignment.middle,
                    onTap: () {
                      wasClicked = true;
                    },
                  ),
                  const TextSpan(
                      text: ' website to know more about the '
                          'framework.'),
                ],
              ),
              textAlign: TextAlign.center,
              key: const Key('text.rich'),
            ),
          ),
        ),
      ),
    );

    final Finder buttonSpanFinder = find.byKey(const Key('button_span'));
    expect(buttonSpanFinder, findsOneWidget);
    await expectLater(
        buttonSpanFinder, matchesGoldenFile('golden-images/button_span.png'));

    expect(wasClicked, isFalse);
    await tester.tap(buttonSpanFinder);
    expect(wasClicked, isTrue);
  });
}
