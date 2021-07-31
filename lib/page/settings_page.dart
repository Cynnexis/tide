import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:logging/logging.dart';
import 'package:tide/settings.dart';
import 'package:tide/utility/iso_lang_mapping.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = "/settings";

  const SettingsPage({Key? key}) : super(key: key);

  @override
  State createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();

    Future<void>.microtask(() async {
      (await TideSettings.instance).addListener(_updateState);
    });
  }

  @override
  void dispose() {
    TideSettings.instanceSync.removeListener(_updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TideSettings>(
      future: TideSettings.instance,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          throw snapshot.error!;
        } else if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return SettingsScreen(
          title: TideLocalizations.of(context)!.settings,
          children: <Widget>[
            SettingsGroup(
              title: TideLocalizations.of(context)!.breathingExerciseSetting,
              children: <Widget>[
                SliderSettingsTile(
                  title: TideLocalizations.of(context)!.breathingDurationSetting,
                  subtitle:
                  TideLocalizations.of(context)!.breathingDurationSettingExplanation(TideSettings.instanceSync.breathingDuration),
                  settingKey: "breathingDurationSeconds",
                  min: 1,
                  max: 20,
                  step: 0.5,
                  defaultValue: TideSettings
                          .instanceSync.breathingDuration.inMilliseconds /
                      1000,
                  leading: const Icon(Icons.timer),
                  onChange: (value) => setState(() => TideSettings.instanceSync.breathingDuration =
                        Duration(milliseconds: (value * 1000).floor())),
                ),
                SliderSettingsTile(
                  title: TideLocalizations.of(context)!.holdingDurationSetting,
                  subtitle:
                  TideLocalizations.of(context)!.holdingDurationSettingExplanation(TideSettings.instanceSync.holdingBreathDuration),
                  settingKey: "holdingBreathDurationSeconds",
                  min: 1,
                  max: 20,
                  step: 0.5,
                  defaultValue: TideSettings
                          .instanceSync.holdingBreathDuration.inMilliseconds /
                      1000.0,
                  leading: const Icon(Icons.timelapse_rounded),
                  onChange: (value) => setState(() => TideSettings.instanceSync.holdingBreathDuration =
                      Duration(milliseconds: (value * 1000).floor())),
                ),
              ],
            ),
            SettingsGroup(
              title: TideLocalizations.of(context)!.interfaceSettings,
              children: <Widget>[
                DropDownSettingsTile<int>(
                  title: TideLocalizations.of(context)!.langSetting,
                  subtitle:
                      TideLocalizations.of(context)!.langSettingExplanation,
                  settingKey: "langSettings",
                  selected: TideSettings.instanceSync.lang != null
                      ? TideLocalizations.supportedLocales
                          .indexOf(TideSettings.instanceSync.lang!)
                      : -1,
                  values: <int, String>{
                    -1: TideLocalizations.of(context)!.systemLanguage,
                    for (int i = 0;
                        i < TideLocalizations.supportedLocales.length;
                        i++)
                      i: getLanguageFromCode(
                          TideLocalizations.supportedLocales[i].languageCode),
                  },
                  onChange: (int langIndex) {
                    setState(() => onLanguageListChanged(context, langIndex));
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// [TideSettings] listener callback.
  ///
  /// Please do **NOT** use this method to refresh the widget tree.
  void _updateState() => setState(() {});

  /// Callback to register the new language the user chose.
  ///
  /// This function needs a [context] and a [langIndex] that indicates the index
  /// of the new language to use in the [TideLocalizations.supportedLocales]
  /// list.
  void onLanguageListChanged(BuildContext context, int langIndex) {
    /// Log a warning saying that [locale] is not supported.
    void logLocaleWarning(Locale? locale, [Zone? zone]) {
      dev.log(
        "WARNING: The current locale \"$locale\" is "
        "not supported by TideLocalizations.\nSupported "
        "locales: "
        "${TideLocalizations.supportedLocales.join(', ')}",
        time: DateTime.now(),
        level: Level.WARNING.value,
        name: "onLanguageListChanged",
        zone: zone,
      );
    }

    // If a specific locale is selected, set it as default
    if (0 <= langIndex &&
        langIndex < TideLocalizations.supportedLocales.length) {
      TideSettings.instanceSync.setLang(
          context, TideLocalizations.supportedLocales[langIndex], langIndex);
      if (TideLocalizations.delegate
          .isSupported(TideSettings.instanceSync.lang!)) {
        TideLocalizations.delegate.load(TideSettings.instanceSync.lang!);
      } else {
        logLocaleWarning(TideSettings.instanceSync.lang, Zone.current);
      }
    }
    // If "System language" is selected, the default locale is set as default
    else {
      TideSettings.instanceSync.setLang(context, null);
      Locale? currentLocale = Localizations.maybeLocaleOf(context);
      if (currentLocale != null &&
          TideLocalizations.delegate.isSupported(currentLocale)) {
        TideLocalizations.delegate.load(currentLocale);
      } else {
        logLocaleWarning(currentLocale, Zone.current);
      }
    }

    if (kDebugMode) {
      dev.log("New locale: ${TideSettings.instanceSync.lang}",
          time: DateTime.now(),
          level: Level.FINER.value,
          name: "onLanguageListChanged",
          zone: Zone.current);
    }
  }
}
