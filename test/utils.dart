import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Wrap the given [child] in utility widgets to provide locations down the
/// widget tree.
Widget provideLocalizations({
  required Widget child,
  final Key? materialAppKey,
  final Key? materialKey,
  final Key? directionalityKey,
}) {
  return MaterialApp(
    key: materialAppKey,
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const <Locale>[
      Locale('en', ''),
    ],
    home: Material(
      key: materialKey,
      child: Directionality(
        key: directionalityKey,
        textDirection: TextDirection.ltr,
        child: child,
      ),
    ),
  );
}
