import 'package:flutter_test/flutter_test.dart';
import 'package:tide/utility/assets.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('Test assets paths loading', () async {
    final List<String> assetsPaths = await loadAssetsPaths();
    expect(assetsPaths, isNotEmpty);
  });

  test('Test assets exist', () async {
    final List<String> assetsPaths = await loadAssetsPaths();
    for (final String assetPath in assetsPaths) {
      expect(await assetExists(assetPath), isTrue);
    }
  });

  test('Test invalid assets', () async {
    expect(await assetExists('asset/invalid-asset'), isFalse);
    expect(await assetExists('asset/licenses/invalid-filename.txt'), isFalse);
    expect(await assetExists('asset/invalid-folder/invalid-filename.txt'),
        isFalse);
    expect(await assetExists(''), isFalse);
    expect(await assetExists('🌹'), isFalse);
  });
}
