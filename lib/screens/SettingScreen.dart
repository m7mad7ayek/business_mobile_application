import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedeliver_business/classes/Language.dart';
import 'package:wedeliver_business/localization/language_constant.dart';
import 'package:wedeliver_business/router/paths/LoginPath.dart';
import 'package:wedeliver_business/services/api.dart';
import 'package:wedeliver_business/state/appState.dart';

import '../main.dart';

class SettingScreen extends StatefulWidget {
  AppState _appState;

  SettingScreen(this._appState);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    App.setLocale(context, _locale);
  }

  Future changeLanguage(String language) async {
    var changeLanguage = await call(
      url: '/settings/set_language',
      method: 'POST',
      data: {'language': language},
    );

    return changeLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'settings')),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(getTranslated(context, "change_language")),
            leading: Icon(Icons.language),
            onTap: () async {
              String title = getTranslated(context, "change_language");
              // String btnLabel = "Change";
              // String btnLabelCancel = "Cancel";

              final x = Platform.isIOS
                  ? new CupertinoAlertDialog(
                      title: Text(title),
                      actions: <Widget>[
                        FlatButton(
                          child: Text(Language.languageList()[0].name),
                          onPressed: () => {
                            changeLanguage(
                                    Language.languageList()[0].languageCode)
                                .then((value) =>
                                    _changeLanguage(Language.languageList()[0]))
                          },
                        ),
                        FlatButton(
                          child: Text(Language.languageList()[1].name),
                          onPressed: () => {
                            changeLanguage(
                                    Language.languageList()[1].languageCode)
                                .then((value) =>
                                    _changeLanguage(Language.languageList()[1]))
                          },
                        ),
                      ],
                    )
                  : new AlertDialog(
                      title: Text(title),
                      actions: <Widget>[
                        FlatButton(
                            child: Text(Language.languageList()[0].name),
                            onPressed: () => {
                                  changeLanguage(Language.languageList()[0]
                                          .languageCode)
                                      .then((value) => _changeLanguage(
                                          Language.languageList()[0]))
                                }),
                        FlatButton(
                            child: Text(Language.languageList()[1].name),
                            onPressed: () => {
                                  changeLanguage(Language.languageList()[1]
                                          .languageCode)
                                      .then((value) => _changeLanguage(
                                          Language.languageList()[1]))
                                })
                      ],
                    );

              // await the dialog
              await showDialog(builder: (context) => x, context: context);

              // Doesn't run
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(getTranslated(context, "logout")),
            leading: Icon(Icons.login),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.remove('user');
              prefs.remove('token');
              widget._appState.route = LoginPath();
            },
          ),

        ],
      ),
    );
  }
}

// Container(
// child: DropdownButton<Language>(
// iconSize: 30,
// hint: Text(getTranslated(context, 'settings')),
// onChanged: (Language language) {
// _changeLanguage(language);
// },
// items: Language.languageList()
// .map<DropdownMenuItem<Language>>(
// (e) => DropdownMenuItem<Language>(
// value: e,
// child: Row(
// mainAxisAlignment: MainAxisAlignment.spaceAround,
// children: <Widget>[
// Text(
// e.flag,
// style: TextStyle(fontSize: 30),
// ),
// Text(e.name)
// ],
// ),
// ),
// )
// .toList(),
// )),
