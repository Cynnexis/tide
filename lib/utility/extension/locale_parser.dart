import 'package:flutter/material.dart';

extension LocaleParser on Locale {
  /// Parse the given [rawLocale] into a [Locale].
  ///
  /// If [rawLocale] is null or not given, [languageCode] is taken instead. If
  /// the parsing fails, returns `null`.
  ///
  /// Example:
  ///
  /// ```dart
  /// Locale("en_US").parse(); // Returns Locale("en", "US")
  /// ```
  Locale? parse([String? rawLocale]) {
    rawLocale ??= languageCode;

    try {
      if (rawLocale.isEmpty) return null;
      List<String> parts = rawLocale.split('_');
      if (parts.length == 1) {
        return Locale(parts.first);
      } else {
        return Locale(parts.first, parts.last);
      }
    } on NoSuchMethodError {
      return null;
    }
  }
}
