import 'dart:async';
import 'dart:io' as io;
import 'dart:developer' as dev;

import 'package:args/args.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tide/constants.dart';
import 'package:tide/page/home_page.dart';
import 'package:tide/page/settings_page.dart';
import 'package:tide/settings.dart';
import 'package:tide/theme.dart';
import 'package:tide/utility/extension/locale_parser.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';

void main([List<String> args = const <String>[]]) async {
  Locale? defaultLocale;

  // Parse arguments
  ArgParser parser = ArgParser(allowTrailingOptions: false);
  parser.addFlag(
    "help",
    abbr: 'h',
    help: "Print this usage information and quit.",
    defaultsTo: false,
    negatable: false,
    callback: (bool needsHelp) {
      if (needsHelp) {
        // ignore: avoid_print
        print(appName + "\n" + parser.usage);
        io.exit(0);
      }
    },
  );
  parser.addFlag(
    "version",
    help: "Print the version of the program and quit.",
    defaultsTo: false,
    negatable: false,
    callback: (bool needsVersion) {
      if (needsVersion) {
        // ignore: avoid_print
        print("$appName version $appVersion");
        io.exit(0);
      }
    },
  );
  parser.addOption(
    "locale",
    help: "The locale of the application. Defaults to the last saved locale "
        "chose by the user, or the system locale if the latter is not set.",
    defaultsTo: null,
    // Set random seed
    callback: (String? rawLocale) {
      // Parse rawLocale
      if (rawLocale != null) {
        final ArgumentError error =
            ArgumentError("The given locale '$rawLocale' is not valid.");
        if (rawLocale.isEmpty) throw error;

        Locale? locale = Locale(rawLocale).parse();
        if (locale == null) throw error;

        defaultLocale = locale;
      }
    },
  );
  parser.parse(args);

  WidgetsFlutterBinding.ensureInitialized();

  // Load for the settings
  await Settings.init(cacheProvider: SharePreferenceCache());
  await TideSettings.instance;

  runApp(TideApp(defaultLocale: defaultLocale));
}

class TideApp extends StatefulWidget {
  /// The default application locale. If `null`, it will default to the last
  /// saved locale chose by the user, or the system locale if the latter is not
  /// set.
  final Locale? defaultLocale;

  const TideApp({Key? key, this.defaultLocale}) : super(key: key);

  @override
  State createState() => _TideAppState();
}

class _TideAppState extends State<TideApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ValueNotifier<Locale?>>.value(
          value: ValueNotifier<Locale?>(
              widget.defaultLocale ?? TideSettings.instanceSync.lang),
        )
      ],
      child: Consumer<ValueNotifier<Locale?>>(
          builder: (context, defaultLocale, child) {
        return MaterialApp(
          title: appName,
          localizationsDelegates: TideLocalizations.localizationsDelegates,
          supportedLocales: TideLocalizations.supportedLocales,
          locale: defaultLocale.value,
          theme: TideTheme.light,
          darkTheme: TideTheme.dark,
          initialRoute: '/',
          routes: <String, Widget Function(BuildContext)>{
            HomePage.routeName: (context) => const HomePage(),
          },
          onGenerateRoute: (RouteSettings settings) {
            if (kDebugMode) {
              dev.log(
                settings.name ?? '(null)',
                time: DateTime.now(),
                level: Level.FINE.value,
                name: "route",
                zone: Zone.current,
              );
            }

            switch (settings.name) {
              case HomePage.routeName:
              case '/home':
              case '/index':
                return MaterialPageRoute(
                    builder: (context) => const HomePage(), settings: settings);
              case SettingsPage.routeName:
                return MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                    settings: settings);
            }
          },
          debugShowCheckedModeBanner: false,
        );
      }),
    );
  }
}
