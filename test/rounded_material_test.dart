import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tide/widget/rounded_material.dart';

void main() {
  testWidgets('RoundedMaterial Golden file', (final WidgetTester tester) async {
    /// Check if the button was clicked
    bool wasClicked = false;

    await tester.pumpWidget(
      Directionality(
        key: const Key('directionality'),
        textDirection: TextDirection.ltr,
        child: RoundedMaterial(
          key: const Key('rounded_material'),
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          backgroundColor: Colors.white,
          onTap: () {
            wasClicked = true;
          },
          child: const Center(
            child: Padding(
              key: Key('padding'),
              padding: EdgeInsets.all(8.0),
              child: Text(
                '''Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ante metus dictum at tempor commodo ullamcorper. Proin fermentum leo vel orci porta. Ac ut consequat semper viverra nam libero justo laoreet. Lacus vel facilisis volutpat est velit. At risus viverra adipiscing at in tellus. Varius morbi enim nunc faucibus a pellentesque sit amet porttitor. Nulla facilisi nullam vehicula ipsum a arcu cursus vitae congue. Et pharetra pharetra massa massa ultricies mi quis hendrerit. Condimentum lacinia quis vel eros. Lacus vel facilisis volutpat est velit egestas dui. In vitae turpis massa sed elementum tempus. Magna fermentum iaculis eu non. Vel eros donec ac odio tempor orci dapibus ultrices. Tincidunt lobortis feugiat vivamus at augue eget arcu dictum varius. Volutpat ac tincidunt vitae semper.

Placerat in egestas erat imperdiet sed euismod nisi porta lorem. Nullam non nisi est sit. Vestibulum lectus mauris ultrices eros in cursus turpis massa. Amet facilisis magna etiam tempor orci eu. Turpis nunc eget lorem dolor sed viverra. Elementum facilisis leo vel fringilla est ullamcorper. In tellus integer feugiat scelerisque. Porta lorem mollis aliquam ut porttitor. Massa vitae tortor condimentum lacinia quis vel eros. Senectus et netus et malesuada fames. Maecenas volutpat blandit aliquam etiam erat velit scelerisque in. Pharetra vel turpis nunc eget lorem dolor sed viverra ipsum. Aenean pharetra magna ac placerat vestibulum lectus.''',
                key: Key('text'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    final Finder roundedMaterialFinder =
        find.byKey(const Key('rounded_material'));
    expect(roundedMaterialFinder, findsOneWidget);
    await expectLater(roundedMaterialFinder,
        matchesGoldenFile('golden-images/rounded_material.png'));

    expect(wasClicked, isFalse);
    await tester.tap(roundedMaterialFinder);
    expect(wasClicked, isTrue);
  });
}
