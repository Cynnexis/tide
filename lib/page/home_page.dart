import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/tide_localizations.dart';
import 'package:tide/constants.dart';
import 'package:tide/page/settings_page.dart';
import 'package:tide/theme.dart';
import 'package:tide/widget/breathing_bubble.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    didChangePlatformBrightness();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      TideTheme.setSystemUIOverlayStyle(
          brightness: WidgetsBinding.instance!.window.platformBrightness);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => aboutApp(context),
          icon: TideTheme.getLogoImage(imageProvider: TideTheme.logo),
          tooltip: TideLocalizations.of(context)!.appName,
        ),
        title: Text(TideLocalizations.of(context)!.appName),
        actions: <Widget>[
          IconButton(
            onPressed: () => pushSettings(),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            BreathingBubble(),
          ],
        ),
      ),
    );
  }

  void pushSettings() async {
    await Navigator.pushNamed(context, SettingsPage.routeName);
    setState(() {});
  }

  void aboutApp(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: TideLocalizations.of(context)!.appName,
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
    );
  }
}
