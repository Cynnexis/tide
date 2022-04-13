import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';
import 'package:intl/intl.dart';
import 'package:tide/constants.dart';
import 'package:tide/theme.dart';
import 'package:tide/utility/config_file.dart';
import 'package:tide/widget/error_tile.dart';
import 'package:url_launcher/url_launcher.dart' as url;

/// Default icon size
const double _iconSize = 32;

/// Style for URLs.
const TextStyle urlStyle = TextStyle(
  color: TideTheme.primaryColor,
  decoration: TextDecoration.underline,
);

/// Date formatter to get the current year (for copyright)
final DateFormat yearFormatter = DateFormat('yyyy');

/// Copy the given URL to the clipboard.
Future<void> copyUrl(BuildContext context, String stringUrl) async {
  try {
    await Clipboard.setData(ClipboardData(text: stringUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(TideLocalizations.of(context)!.copiedToClipboard),
      ),
    );
  } catch (e) {
    if (kDebugMode) rethrow;
  }
}

/// Open the given URL using the associated application (defaults to web
/// browser).
Future<void> openUrl(String stringUrl) async {
  if (await url.canLaunch(stringUrl)) {
    await url.launch(stringUrl);
  } else if (kDebugMode) {
    dev.log("Couldn't launch URL: $stringUrl", name: "aboutApp.canLaunch");
  }
}

/// Show an about-the-app dialog box.
void aboutApp(BuildContext context) {
  showAboutDialog(
    context: context,
    applicationName: TideLocalizations.of(context)!.longAppName,
    applicationIcon: ClipRRect(
      key: const Key('about_dialog_app_icon_clip_rect'),
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        key: const Key('about_dialog_app_icon_container'),
        color: Colors.white,
        child: SizedBox(
          key: const Key('about_dialog_app_icon_sized_box'),
          width: 60,
          height: 60,
          child: TideTheme.getLogoImage(
            key: const Key('about_dialog_app_icon'),
          ),
        ),
      ),
    ),
    applicationVersion: appVersion,
    applicationLegalese: '\u{a9} ${yearFormatter.format(DateTime.now())} Tide',
    children: <Widget>[
      Text(TideLocalizations.of(context)!.appDescription),
      _buildTile(
        context,
        "assets/images/github${TideTheme.getSystemBrightness(context) == Brightness.dark ? "-light" : ''}.png",
        "GitHub",
        gitRepoURL,
      ),
      FutureBuilder<ConfigFile>(
        future: ConfigFile.load(context: context),
        builder: (BuildContext context, AsyncSnapshot<ConfigFile> snapshot) {
          if (snapshot.hasError) {
            return ErrorTile(
              context: context,
              error: snapshot.error,
              title:
                  TideLocalizations.of(context)!.errorOccurredParseConfigFile,
            );
          } else if (!snapshot.hasData) {
            return ListTile(
              leading: const CircularProgressIndicator(),
              title: Text(TideLocalizations.of(context)!.loading),
            );
          }

          return _buildTile(
            context,
            const Icon(Icons.description),
            "Documentation",
            snapshot.data!.web.uri.resolve("docs").toString(),
          );
        },
      ),
    ],
  );
}

/// Build the list tile.
Widget _buildTile(
  BuildContext context,
  dynamic image,
  String title,
  String url,
) {
  return ListTile(
    leading: _buildTileLeading(image),
    title: Text(title),
    subtitle: RichText(
      text: TextSpan(
        text: url,
        style: urlStyle,
        recognizer: TapGestureRecognizer()..onTap = () => openUrl(url),
      ),
    ),
    onLongPress: () => copyUrl(context, url),
  );
}

/// Build the widget for [ListTile.leading].
Widget _buildTileLeading(
  dynamic image, {
  final double iconSize = _iconSize,
}) {
  if (image is Widget) {
    return image;
  } else if (image is String) {
    image = AssetImage(image);
  }

  if (image is! AssetImage && image is! ImageProvider) {
    throw ArgumentError('Expected "image" to be a Widget, String or an '
        'ImageProvider, got "${image.runtimeType}".');
  }

  return Image(
    image: image,
    width: iconSize,
    height: iconSize,
  );
}
