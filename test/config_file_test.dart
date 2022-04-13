import 'package:flutter_test/flutter_test.dart';
import 'package:mutex/mutex.dart';
import 'package:tide/utility/config_file.dart';

const String minimalYamlConfiguration = '''
---
maintainer_email: john.doe@corp.org
webapp:
  uri:
    scheme: https
    host: www.example.com
...
''';

const String extendedYamlConfiguration = '''
---
docker:
  android_sdk_version: "32"
  android_build_tools_version: "30.0.2"
  flutter_version: "stable"
  apt_ubuntu_mirror_url: "http://archive.ubuntu.com/"
  flutter_web_renderer: "auto"
  google_search_meta_ownership_content: "my-id"
webapp:
  uri:
    scheme: https
    userInfo: 'username'
    host: www.example.com
    port: 8080
    #path: /test/tide/
    pathSegments:
      - test
      - tide
      - ''
    #query: test=true&flutter=yes
    queryParameters:
      test: true
      flutter: yes
    fragment: my-anchor
maintainer_email: john.doe@corp.org
...
''';

/// In this tests, only one test is allowed at a time
void main() {
  ConfigFile? configFileInstance;
  final Mutex groupSync = Mutex();

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    // Prevent two tests to run in parallel
    await groupSync.acquire();
  });

  tearDown(() {
    // Release lock once test is finished
    groupSync.release();
  });

  tearDownAll(() {
    // Clear singleton for other tests
    ConfigFile.removeInstance();
  });

  test('Asset configuration', () async {
    configFileInstance =
        await ConfigFile.load(configuration: minimalYamlConfiguration);

    expect(configFileInstance, isNotNull);
    expect(configFileInstance!.maintainerEmail, isNotEmpty);
    expect(configFileInstance!.web.uri.toString(), isNotEmpty);

    ConfigFile.removeInstance();
  });

  test('Minimal configuration', () async {
    configFileInstance =
        await ConfigFile.load(configuration: minimalYamlConfiguration);

    expect(configFileInstance, isNotNull);
    expect(configFileInstance!.maintainerEmail, equals('john.doe@corp.org'));
    expect(configFileInstance!.web.uri.toString(),
        equals('https://www.example.com'));

    ConfigFile.removeInstance();
  });

  test('Extended configuration', () async {
    configFileInstance =
        await ConfigFile.load(configuration: extendedYamlConfiguration);

    expect(configFileInstance, isNotNull);
    expect(configFileInstance!.maintainerEmail, equals('john.doe@corp.org'));
    expect(configFileInstance!.web.uri.toString(),
        equals('https://username@www.example.com:8080/test/tide/?test=true&flutter=yes#my-anchor'));

    ConfigFile.removeInstance();
  });
}
