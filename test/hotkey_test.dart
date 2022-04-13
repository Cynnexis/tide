import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tide/widget/hotkey.dart';

void main() {
  testWidgets('Hotkey Golden file', (final WidgetTester tester) async {
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
                  const TextSpan(text: 'Press '),
                  WidgetSpan(
                    child: Hotkey(
                      key: const Key('hotkey_f1'),
                      shortcut: 'F1',
                      onPressed: () {
                        wasClicked = true;
                      },
                    ),
                  ),
                  const TextSpan(text: ' for help.'),
                ],
              ),
              key: const Key('text.rich'),
            ),
          ),
        ),
      ),
    );

    final Finder hotkeyHelpFinder = find.byKey(const Key('hotkey_f1'));
    expect(hotkeyHelpFinder, findsOneWidget);
    await expectLater(
        hotkeyHelpFinder, matchesGoldenFile('golden-images/hotkey_f1.png'));

    expect(wasClicked, isFalse);
    await tester.tap(hotkeyHelpFinder);
    expect(wasClicked, isTrue);
  });
}
