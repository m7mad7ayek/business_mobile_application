import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wedeliver_business/router/RouteDelegate.dart';
import 'package:wedeliver_business/router/RouteInformationParser.dart';
import 'package:wedeliver_business/services/helpers.dart';
import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:package_info/package_info.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'localization/demo_localization.dart';
import 'localization/language_constant.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureApp();
  runApp(App());
}

class App extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    _AppState state = context.findAncestorStateOfType<_AppState>();
    state.setLocale(newLocale);
  }

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  Locale _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }
  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  static const APP_STORE_URL =
      'https://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?id=com.wesync.wedeliver_business&mt=8';
  static const PLAY_STORE_URL =
      'https://play.google.com/store/apps/details?id=com.wesync.wedeliver_business';

  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  OrderRouteDelegate _orderRouteDelegate = OrderRouteDelegate();
  OrderRouteInformationParser _informationParser =
      OrderRouteInformationParser();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this._locale == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800])),
        ),
      );
    } else {
    return FutureBuilder(
      future: versionCheck(),
      builder: (context, snapshot) {
        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(child: Center(child: Loading()));
        } else {
          if (snapshot.hasError) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
                home: Scaffold(
                    body: Center(
                      child: Text('Error: ${snapshot.error}'),
                    )));
          } else {
            try {
              var isForce = snapshot.data;
              if (isForce) {
                return Container(child: Center(child: ForceUpdateDialog2()));
              } else {
                return  MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: Scaffold(
                        resizeToAvoidBottomInset: false,
                        body: MaterialApp.router(
                          debugShowCheckedModeBanner: false,
                          title: 'weDeliver',
                          theme: ThemeData(
                            // This is the theme of your application.
                            buttonTheme: ButtonThemeData(
                              //  buttonColor: Colors.deepPurple,     //  <-- dark color
                              textTheme: ButtonTextTheme.primary,
                              //  <-- this auto selects the right color
                            ),
                            primarySwatch:
                            buildMaterialColor(Color.fromRGBO(248, 172, 0, 1.0)),
                          ),
                          locale: _locale,
                  supportedLocales: [
                    Locale("en", "US"),
                    Locale("ar", "SA"),
                  ],
                  localizationsDelegates: [
                    DemoLocalization.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  localeResolutionCallback: (locale, supportedLocales) {
                    for (var supportedLocale in supportedLocales) {
                      if (supportedLocale.languageCode == locale.languageCode &&
                          supportedLocale.countryCode == locale.countryCode) {
                        return supportedLocale;
                      }
                    }
                    return supportedLocales.first;
                  },
                  routeInformationParser: _informationParser,
                  routerDelegate: _orderRouteDelegate,
                )));
              }
            } catch (e) {
              print(e);
              return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Scaffold(
                      body: Center(
                        child: Text('Error: ${e.toString()}'),
                      )));
            }
          }
        }

        //  Otherwise, show something whilst waiting for initialization to complete
      },
    );
  }
  }

  Future<bool> versionCheck() async {
    // await Firebase.initializeApp();
    //Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();
    int currentVersion = int.parse(info.buildNumber);
    try {
    //Get Latest version info from firebase config
    final RemoteConfig remoteConfig = RemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(seconds: 60),
      minimumFetchInterval: Duration(seconds: 0),
    ));

      // Using default duration to force fetching from remote server.
      // await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      bool updated = await remoteConfig.fetchAndActivate();
      if (updated) {
        // the config has been updated, new parameter values are available.
      } else {
        // the config values were previously updated.
      }
      String x = remoteConfig.getString('force_update2');
      int newVersion = int.parse(remoteConfig.getString('force_update2'));
      print("New Version: " + x);
      return Future.value(newVersion > currentVersion);
      return Future.value(1 > currentVersion);
    } catch (exception) {
      print(exception.toString());
      // Fetch throttled.
      return Future.value(false);
    }
  }

  Widget ForceUpdateDialog2() { //TODO
    String title = "New Update Available";
    String message =
        "There is a newer version of app available please update it now.";
    String btnLabel = "Update Now";
    String btnLabelCancel = "Later";

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          child: Center(
            child: Platform.isIOS
                ? new CupertinoAlertDialog(
                    title: Text(title),
                    content: Text(message),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(btnLabel),
                        onPressed: () => _launchURL(APP_STORE_URL),
                      ),
                    ],
                  )
                : new AlertDialog(
                    title: Text(title),
                    content: Text(message),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(btnLabel),
                        onPressed: () => _launchURL(PLAY_STORE_URL),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget Loading() {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Center(
      child: Text("Waiting..."),
    )));
  }

  Widget SomethingWentWrong() {
    return Container(
      child: Text("Some Thing Went wrong!"),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }



}
