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
      builder: (BuildContext context, AsyncSnapshot<TideSettings> snapshot) {
        if (snapshot.hasError) {
          throw snapshot.error!;
        } else if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(TideLocalizations.of(context)!.settings),
            actions: <Widget>[
              PopupMenuButton<_SettingsPopupEntry>(
                onSelected: (_SettingsPopupEntry entry) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(TideLocalizations.of(context)!
                            .resetToDefaultValues),
                        content: Text(TideLocalizations.of(context)!
                            .resetSettingConfirmation),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop<void>();
                            },
                            child: Text(TideLocalizations.of(context)!.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                TideSettings.instanceSync.breathingDuration =
                                    TideSettings.defaultBreathingDuration;
                                TideSettings
                                        .instanceSync.holdingBreathDuration =
                                    TideSettings.defaultHoldingBreathDuration;
                                TideSettings.instanceSync
                                    .setLang(context, null, index: 0);
                              });
                              Navigator.of(context).pop<void>();
                            },
                            child: Text(TideLocalizations.of(context)!.reset),
                          ),
                        ],
                      );
                    },
                  );
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<_SettingsPopupEntry>>[
                    PopupMenuItem<_SettingsPopupEntry>(
                      value: _SettingsPopupEntry.resetToDefaultValues,
                      child: Text(
                          TideLocalizations.of(context)!.resetToDefaultValues),
                    ),
                  ];
                },
              ),
            ],
          ),
          body: ListView(
            shrinkWrap: true,
            children: <Widget>[
              SettingsGroup(
                title: TideLocalizations.of(context)!.breathingExerciseSetting,
                children: <Widget>[
                  buildSlideTile(
                    context,
                    title:
                        TideLocalizations.of(context)!.breathingDurationSetting,
                    subtitle: TideLocalizations.of(context)!
                        .breathingDurationSettingExplanation(durationToSeconds(
                            TideSettings.instanceSync.breathingDuration)),
                    value: TideSettings
                            .instanceSync.breathingDuration.inMilliseconds /
                        1000,
                    min: 1,
                    max: 20,
                    leading: const Icon(Icons.timer),
                    onReset: () {
                      setState(() {
                        TideSettings.instanceSync.breathingDuration =
                            TideSettings.defaultBreathingDuration;
                      });
                    },
                    onChanged: (final double value) => setState(() =>
                        TideSettings.instanceSync.breathingDuration =
                            Duration(milliseconds: (value * 1000).floor())),
                  ),
                  buildSlideTile(
                    context,
                    title:
                        TideLocalizations.of(context)!.holdingDurationSetting,
                    subtitle: TideLocalizations.of(context)!
                        .holdingDurationSettingExplanation(durationToSeconds(
                            TideSettings.instanceSync.holdingBreathDuration)),
                    value: TideSettings
                            .instanceSync.holdingBreathDuration.inMilliseconds /
                        1000,
                    min: 1,
                    max: 20,
                    leading: const Icon(Icons.timelapse_rounded),
                    onReset: () {
                      setState(() {
                        TideSettings.instanceSync.holdingBreathDuration =
                            TideSettings.defaultHoldingBreathDuration;
                      });
                    },
                    onChanged: (final double value) => setState(() {
                      TideSettings.instanceSync.holdingBreathDuration =
                          Duration(milliseconds: (value * 1000).floor());
                    }),
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
          ),
        );
      },
    );
  }

  /// Build a reset button as an [IconButton].
  Widget buildResetButton(
    BuildContext context, {
    required final VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.repeat),
      tooltip: TideLocalizations.of(context)!.reset,
    );
  }

  Widget buildSlideTile(
    BuildContext context, {
    required final String title,
    required final String subtitle,
    required final double value,
    required final double min,
    required final double max,
    final double precision = 0.5,
    final Widget? leading,
    final Widget? trailing,
    final VoidCallback? onReset,
    final ValueChanged<double>? onChanged,
  }) {
    assert(trailing == null || onReset == null,
        'Cannot have both trailing and onReset non-null:\ntrailing: $trailing\nonReset: $onReset');

    return ListTile(
      leading: leading,
      trailing: trailing ??
          (onReset != null
              ? buildResetButton(context, onPressed: onReset)
              : null),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(subtitle),
          Slider(
            value: value,
            onChanged: onChanged,
            min: min,
            max: max,
            divisions: ((max - min) * (1.0 / precision)).floor(),
          ),
        ],
      ),
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
        context,
        TideLocalizations.supportedLocales[langIndex],
        index: langIndex,
      );
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

  String durationToSeconds(Duration duration) {
    String content = '';
    if (duration.isNegative) {
      content = '-';
    }

    int seconds = (duration.inMilliseconds / 1000.0).floor();
    content += "$seconds";

    int milliseconds = duration.inMilliseconds - seconds * 1000;
    if (milliseconds > 0) {
      String ms = "$milliseconds";
      // Remove trailing 0
      ms = ms.replaceFirst(RegExp("0+\$"), '');
      content += ".$ms";
    }

    content += 's';
    return content;
  }
}

enum _SettingsPopupEntry {
  resetToDefaultValues,
}
