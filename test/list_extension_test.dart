// Import the test package and Counter class
import 'package:test/test.dart';
import 'package:tide/utility/extension/list_extension.dart';

void main() {
  test('Test intersperseCopy', () {
    const List<int> list1 = <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    expect(
        list1.intersperseCopy(0),
        orderedEquals(<int>[
          0,
          0,
          1,
          0,
          2,
          0,
          3,
          0,
          4,
          0,
          5,
          0,
          6,
          0,
          7,
          0,
          8,
          0,
          9,
          0,
          10,
        ]));
  });

  test('Test intersperse', () {
    final List<String> list2 = <String>[
      'Butter',
      'Milk',
      'Sugar',
      'Flour',
      'Chocolate chips',
      'Banana',
    ];
    list2.intersperse('\n');
    expect(list2.join(),
        equals('Butter\nMilk\nSugar\nFlour\nChocolate chips\nBanana'));
  });
}
