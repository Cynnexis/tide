import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tide/utility/assets.dart';
import 'package:yaml/yaml.dart';

/// Singleton containing all data related to the application configuration file.
class ConfigFile {
  //region CONSTANTS

  static const List<String> _defaultConfigFilePaths = <String>[
    "tide.yaml",
    "tide.yml",
  ];

  //endregion

  //region STATIC ATTRIBUTES

  /// Singleton instance for [ConfigFile].
  static ConfigFile? _instance;

  /// Mutex for [load].
  static final Lock _instanceLock = Lock();

  //endregion

  //region ATTRIBUTES

  /// The web configuration.
  ConfigWeb web;

  /// The email of the maintainer of this project.
  String maintainerEmail;

  //endregion

  //region PROPERTIES

  static ConfigFile get instance => _instance!;

  //endregion

  //region CONSTRUCTORS

  ConfigFile._internal({
    required this.web,
    required this.maintainerEmail,
  });

  /// Returns the configuration file as a [ConfigFile] instance.
  ///
  /// If the configuration has already been loaded, it will be immediately be
  /// returned. Otherwise, it will be imported.
  ///
  /// If you need to get the instance of this singleton without asynchronous
  /// operation, and you are sure that the configuration has already been
  /// loaded, please use [instance] instead, but otherwise, this function is
  /// recommended over the getter.
  ///
  /// To load the configuration, you have two options:
  ///
  /// * **Load from the assets:** This is the default behavior. If a [context]
  /// is passed, it will be used to call [DefaultAssetBundle]. If not,
  /// [rootBundle] will be used instead.
  /// * **Load it from a given configuration:** Use [configuration] to load a
  /// Yaml document, or if it is not a Yaml document, a file from the assets.
  /// In the latter case, you may pass a [context].
  ///
  /// Note that this function is thread-safe.
  static Future<ConfigFile> load(
      {BuildContext? context, String? configuration}) async {
    return await _instanceLock.synchronized<ConfigFile>(() async {
      if (_instance == null) {
        // The object that will contain the configuration content, as a mapping
        dynamic configDynamicYaml;
        if (configuration == null) {
          // Automatically detect the configuration file and load it from the assets
          final String configContent = await readConfigFile(context: context);
          configDynamicYaml = loadYaml(configContent);
        } else {
          // Try to parse the given configuration, it it fails, assume it is a path
          try {
            configDynamicYaml = loadYaml(configuration);
          } catch (err) {
            // Only capture [YamlException] and [ArgumentError]
            if (err is! YamlException && err is! ArgumentError) {
              rethrow;
            }

            // Assume [configuration] is a path
            final String configContent = await readConfigFile(
                configAssetPath: configuration, context: context);
            configDynamicYaml = loadYaml(configContent);
          }
        }

        // Check that the [configDynamicYaml] is a mapping
        if (configDynamicYaml! is Map<String, dynamic>) {
          throw StateError(
              'Expected the YAML configuration to be a mapping, got "${configDynamicYaml.runtimeType}".');
        }

        final YamlMap configYaml = configDynamicYaml as YamlMap;

        final YamlMap mapWebUri = configYaml['webapp']['uri'];

        final Uri webAppUri = Uri(
          /* String? */ scheme: mapWebUri['scheme'],
          /* String? */ userInfo: mapWebUri['userInfo'],
          /* String? */ host: mapWebUri['host'],
          /* int? */ port: mapWebUri['port'],
          /* String? */ path: mapWebUri['path'],
          /* Iterable<String>? */ pathSegments:
              mapWebUri['pathSegments'] != null
                  ? <String>[
                      for (final dynamic p
                          in (mapWebUri['pathSegments'] as Iterable<dynamic>))
                        p.toString(),
                    ]
                  : null,
          /* String? */ query: mapWebUri['query'],
          /* Map<String, dynamic /*String|Iterable<String>*/ >? */ queryParameters:
              mapWebUri['queryParameters'] != null
                  ? <String, dynamic>{
                      for (final MapEntry<dynamic, dynamic> entry
                          in (mapWebUri['queryParameters'] as YamlMap).entries)
                        entry.key as String: entry.value is Iterable<dynamic>
                            ? entry.value
                                .cast<String>((dynamic e) => e.toString())
                                .toList(growable: false)
                            : entry.value.toString(),
                    }
                  : null,
          /* String? */ fragment: mapWebUri['fragment'],
        );

        _instance = ConfigFile._internal(
          web: ConfigWeb(
            uri: webAppUri,
          ),
          maintainerEmail: configYaml['maintainer_email'],
        );
      }

      return _instance!;
    });
  }

  //endregion

  /// Remove the instance of this singleton.
  ///
  /// This is only available for testing.
  @visibleForTesting
  static void removeInstance() {
    _instance = null;
  }

  /// Read the configuration file located at [configAssetPath].
  ///
  /// If [configAssetPath] is not given, it will automatically be detected with
  /// [detectConfigFilePath].
  ///
  /// If a [context] is passed, it will be used to call [DefaultAssetBundle]. If
  /// not, [rootBundle] will be used instead.
  @visibleForTesting
  static Future<String> readConfigFile({
    String? configAssetPath,
    BuildContext? context,
  }) async {
    return await (context == null ? rootBundle : DefaultAssetBundle.of(context))
        .loadString(configAssetPath ?? await detectConfigFilePath());
  }

  /// Detect the configuration file in the list of asset using the fallback list
  /// [_defaultConfigFilePaths].
  ///
  /// It will return the path to the asset (and not the content). If not found,
  /// a [StateError] is thrown.
  ///
  /// If a [context] is passed, it will be used to call [DefaultAssetBundle]. If
  /// not, [rootBundle] will be used instead.
  @visibleForTesting
  static Future<String> detectConfigFilePath({BuildContext? context}) async {
    List<String> assetPaths = await loadAssetsPaths(context: context);
    for (final String path in _defaultConfigFilePaths) {
      if (assetPaths.contains(path)) {
        return path;
      }
    }

    throw StateError(
        'No configuration file detected. The application tried to locate the file using the following fallback list:\n${_defaultConfigFilePaths.join('\n  * ')}\nPlease make sure that the configuration file is in pubspec.yaml.');
  }
}

/// Class containing all data related to the property ".web" in the
/// configuration file.
class ConfigWeb {
  final Uri uri;

  ConfigWeb({
    required this.uri,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigWeb &&
          runtimeType == other.runtimeType &&
          uri == other.uri;

  @override
  int get hashCode => uri.hashCode;

  @override
  String toString() {
    return 'ConfigWeb{uri: $uri}';
  }
}
