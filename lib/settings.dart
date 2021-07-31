import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';

/// Please use [instance] to initialize if it is not already done the singleton
/// (async getter), or use [instanceSync] if you are sure that the singleton is
/// already initialized and do not want to wait for the instance.
///
/// See also:
/// * [instanceSync]
class TideSettings extends ChangeNotifier {
  static TideSettings? _singleton;
  late final SharedPreferences _sharedPreferences;

  /// Synchronization lock for [instance].
  static final Lock _initLock = Lock();

  //region CONSTRUCTORS

  TideSettings._create(this._sharedPreferences);

  /// Returns the singleton instance as a [Future].
  ///
  /// If the singleton is not initialized, this getter will automatically
  /// initiate it.
  ///
  /// If you are sure that the singleton has been initialized, and it is not
  /// possible to call an asynchronous method, use [instanceSync].
  static Future<TideSettings> get instance async {
    return _initLock.synchronized<TideSettings>(() async {
      if (_singleton == null) {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        _singleton = TideSettings._create(sharedPreferences);
      }
      return _singleton!;
    }, timeout: const Duration(seconds: 5));
  }

  /// Returns the singleton instance.
  ///
  /// If the singleton is not initialized, a [StateError] is thrown. You can
  /// see if the instance is initialized or not with [isInitialized]. If you
  /// are unsure, or you want to initialize it, use [instance] (async getter).
  static TideSettings get instanceSync {
    if (!isInitialized) {
      throw StateError("TideSettings is not initialized");
    }

    return _singleton!;
  }

  /// Indicates if the singleton is initialized or not.
  ///
  /// To initialized the singleton, please call [instance].
  static bool get isInitialized => _singleton != null;

  //endregion

  //region SETTINGS

  Locale? get lang {
    try {
      String? result = getString("lang", '');
      if (result == null || result.isEmpty) return null;
      List<String> parts = result.split('_');
      if (parts.length == 1) {
        return Locale(parts.first);
      } else {
        return Locale(parts.first, parts.last);
      }
    } on NoSuchMethodError {
      return null;
    }
  }

  void setLang(BuildContext context, Locale? locale, [int? index]) {
    _sharedPreferences.setString("lang", locale?.toString() ?? '');
    if (index != null) _sharedPreferences.setInt("langSettings", index);
    Provider.of<ValueNotifier<Locale?>>(context, listen: false).value = locale;
    if (locale != null) TideLocalizations.delegate.load(lang!);
    notifyListeners();
  }

  //endregion

  //region SHARED PREFERENCES

  /// Reads a value of any type from persistent storage.
  dynamic get(String key, [dynamic defaultValue]) {
    try {
      return _sharedPreferences.get(key) ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Reads a value from persistent storage, returning the default value if not
  /// found
  bool? getBool(String key, [bool? defaultValue]) {
    try {
      return _sharedPreferences.getBool(key) ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Reads a value from persistent storage, returning the default value if not
  /// found
  int? getInt(String key, [int? defaultValue]) {
    try {
      return _sharedPreferences.getInt(key) ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Reads a value from persistent storage, returning the default value if not
  /// found
  double? getDouble(String key, [double? defaultValue]) {
    try {
      return _sharedPreferences.getDouble(key) ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Reads a value from persistent storage, returning the default value if not
  /// found
  String? getString(String key, [String? defaultValue]) {
    try {
      return _sharedPreferences.getString(key) ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  //endregion
}
