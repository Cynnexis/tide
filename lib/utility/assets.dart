import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cache for [loadAssetsPaths].
List<String>? _assetPathsCache;

/// Return a list of all assets, as paths.
///
/// If a [context] is passed, it will be used to call [DefaultAssetBundle]. If
/// not, [rootBundle] will be used instead.
///
/// Source code inspired from https://stackoverflow.com/a/56555070 by
/// Kostya Vyrodov (consulted on March the 3rd, 2022)
Future<List<String>> loadAssetsPaths({BuildContext? context}) async {
  if (_assetPathsCache == null) {
    final String manifestContent =
        await (context == null ? rootBundle : DefaultAssetBundle.of(context))
            .loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    _assetPathsCache = manifestMap.keys.toList(growable: false);
  }

  return _assetPathsCache!;
}

/// Test if the asset located at [assetPath] exists.
///
/// If a [context] is passed, it will be used to call [DefaultAssetBundle]. If
/// not, [rootBundle] will be used instead.
///
/// See also [loadAssetsPaths].
Future<bool> assetExists(String assetPath, {BuildContext? context}) async {
  return (await loadAssetsPaths(context: context)).contains(assetPath);
}
