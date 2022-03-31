import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';
import 'package:tide/constants.dart';
import 'package:tide/theme.dart';
import 'package:url_launcher/url_launcher.dart' as url;

void aboutApp(BuildContext context) {
  const double iconSize = 32;

  /// Open the given URL using the associated application (defaults to web
  /// browser).
  Future<void> openUrl(String stringUrl) async {
    if (await url.canLaunch(stringUrl)) {
      await url.launch(stringUrl);
    } else if (kDebugMode) {
      dev.log("Couldn't launch URL: $stringUrl", name: "aboutApp.canLaunch");
    }
  }

  /// Copy the given URL to the clipboard.
  Future<void> copyUrl(String stringUrl) async {
    try {
      await Clipboard.setData(ClipboardData(text: stringUrl));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(TideLocalizations.of(context)!.copiedToClipboard)));
    } catch (e) {
      if (kDebugMode) rethrow;
    }
  }

  showAboutDialog(
    context: context,
    applicationName: TideLocalizations.of(context)!.longAppName,
    applicationIcon: ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        color: Colors.white,
        child: SizedBox(
          width: 60,
          height: 60,
          child: TideTheme.getLogoImage(),
        ),
      ),
    ),
    applicationVersion: appVersion,
    applicationLegalese: '\u{a9} 2021 Tide',
    children: <Widget>[
      Text(TideLocalizations.of(context)!.appDescription),
      ListTile(
        leading: Image(
          image: AssetImage(
              "assets/images/github${TideTheme.getSystemBrightness(context) == Brightness.dark ? "-light" : ''}.png"),
          width: iconSize,
          height: iconSize,
        ),
        title: RichText(
            text: TextSpan(
                text: gitRepoURL,
                style: const TextStyle(
                  color: TideTheme.primaryColor,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => openUrl(gitRepoURL))),
        onLongPress: () => copyUrl(gitRepoURL),
      ),
    ],
  );
}
