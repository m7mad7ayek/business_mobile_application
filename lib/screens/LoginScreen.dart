import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedeliver_business/common/LoadingButton.dart';
import 'package:wedeliver_business/localization/language_constant.dart';
import 'package:wedeliver_business/router/paths/OrderListPath.dart';
import 'package:wedeliver_business/router/paths/SignupPath.dart';
import 'package:wedeliver_business/screens/OrderListScreen.dart';
import 'package:wedeliver_business/services/api.dart';
import 'package:wedeliver_business/state/appState.dart';
import 'package:package_info/package_info.dart';

class LoginScreen extends StatefulWidget {
  AppState _appState;

  LoginScreen(this._appState);

  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController usernameController =
  //TextEditingController(text: '');
   TextEditingController(text: 'yshurrab@hotmail.com');
  TextEditingController passwordController =
  // TextEditingController(text: '');

   TextEditingController(text: '12345666');

  bool _loading = false;
  bool _obscureText = true;
  var focusNode = FocusNode();

  Future<dynamic> login(String username, String password) async {
    // await new Future.delayed(const Duration(seconds: 1));
    this.setState(() {
      _loading = true;
    });

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    String platform = "";
    String platformVersion = "";
    if (Platform.isIOS) {
      platform = "ios";
    } else if (Platform.isAndroid) {
      platform = "android";
    }

    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      platformVersion = androidInfo.version.release;
    }

    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      platformVersion = iosInfo.systemVersion;
    }

    var params = {
      'email': username,
      'password': password,
      "app_version": version,
      "platform": platform,
      "platform_version": platformVersion,
      "app": "business app"
    };

    var result = await call(url: '/auth/login', data: params, method: 'POST');

    this.setState(() {
      _loading = false;
    });

    return result;
  }

  void _showToast(BuildContext context, String msg) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(msg),
        /*action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),*/
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(getTranslated(context, 'login')),
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                  TextFormField(
                  autofocus: true,
                  focusNode: focusNode,
                  controller: usernameController,
                  decoration: InputDecoration(
                      hintText: getTranslated(context, 'email_mobile'),
                      prefixIcon: const Icon(Icons.person)),
                  validator: (String value) {
                    if (value == null || value.isEmpty) {
                      return getTranslated(context, 'login_msj');
                    }
                    return null;
                  },
                ),
                TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: getTranslated(context, 'password'),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                          icon: Icon(_obscureText
                              ? Icons.visibility_off
                              : Icons.remove_red_eye),
                          onPressed: () {
                            this.setState(() {
                              _obscureText = !_obscureText;
                            });
                          }),
                    ),
                    obscureText: _obscureText,
                    validator: (String value) {
                      if (value == null || value.isEmpty) {
                        return getTranslated(context, 'password_msj');
                      }
                      return null;
                    }),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LoadingButton(
                          label: getTranslated(context, "login"),
                          loading: _loading,
                          onPressed: (value) {
                            if (_formKey.currentState.validate()) {
                              print(1);
                              FocusScopeNode currentFocus = FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                              String username = usernameController.text;
                              String password = passwordController.text;
                              var response;
                              runZonedGuarded(() async {
                                response = await login(username, password);
                                final prefs = await SharedPreferences.getInstance();

                                prefs.setString('user', jsonEncode(
                                    response['data']));
                                prefs.setString('token', response['token']);

                                widget._appState.route = OrderListPath();
                                print('test $response');
                              }, (Object error, StackTrace stack) {
/* usernameController.text = '';
                                              passwordController.text = '';*/
                                this.setState(() {
                                  _loading = false;
                                });
                                FocusScope.of(context).requestFocus(focusNode);
                                _showToast(context, error.toString());
                              });
                            }
                          },
                        ),
                        TextButton(
                            onPressed: () {
                              widget._appState.route = SignupPath();
// widget.goTo('signup');
                            },
                            child: Text(getTranslated(context, 'signup'))),
                      ]))
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Validate returns true if the form is valid, or false otherwise.
                  //     if (_formKey.currentState.validate()) {
                  //       // If the form is valid, display a snackbar. In the real world,
                  //       // you'd often call a server or save the information in a database.
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         const SnackBar(content: Text('Processing Data')),
                  //       );
                  //     }
                  //   },
                  //   child: const Text('Submit'),
                  // ),
                  ],
                ),
              ),
            ),
          )
    );

  }
}

// SingleChildScrollView(
// child: Form(
// autovalidateMode: AutovalidateMode.always,
// key: _formKey,
// child: Flexible(
// child: Column(
// children: [
// Padding(
// padding: const EdgeInsets.all(16.0),
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// TextFormField(
// autofocus: true,
// focusNode: focusNode,
// controller: usernameController,
// decoration: InputDecoration(
// hintText: getTranslated(context, 'email_mobile'),
// prefixIcon: const Icon(Icons.person)),
// validator: (String value) {
// if (value == null || value.isEmpty) {
// return getTranslated(context, 'login_msj');
// }
// return null;
// },
// ),
// TextFormField(
// controller: passwordController,
// decoration: InputDecoration(
// hintText: getTranslated(context, 'password'),
// prefixIcon: Icon(Icons.lock),
// suffixIcon: IconButton(
// icon: Icon(_obscureText
// ? Icons.visibility_off
//     : Icons.remove_red_eye),
// onPressed: () {
// this.setState(() {
// _obscureText = !_obscureText;
// });
// }),
// ),
// obscureText: _obscureText,
// validator: (String value) {
// if (value == null || value.isEmpty) {
// return getTranslated(context, 'password_msj');
// }
// return null;
// },
// ),
// Padding(
// padding: const EdgeInsets.symmetric(vertical: 16.0),
// child: Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// children: [
// LoadingButton(
// label: getTranslated(context, "login"),
// loading: _loading,
// onPressed: (value) {
// if (_formKey.currentState.validate()) {
// print(1);
// FocusScopeNode currentFocus =
// FocusScope.of(context);
// if (!currentFocus.hasPrimaryFocus) {
// currentFocus.unfocus();
// }
// String username = usernameController.text;
// String password = passwordController.text;
// var response;
// runZonedGuarded(() async {
// response = await login(username, password);
// final prefs =
// await SharedPreferences.getInstance();
//
// prefs.setString(
// 'user', jsonEncode(response['data']));
// prefs.setString('token', response['token']);
//
// widget._appState.route = OrderListPath();
// print('test $response');
// }, (Object error, StackTrace stack) {
// /* usernameController.text = '';
//                                           passwordController.text = '';*/
// this.setState(() {
// _loading = false;
// });
// FocusScope.of(context)
//     .requestFocus(focusNode);
// _showToast(context, error.toString());
// });
// }
// },
// ),
// TextButton(
// onPressed: () {
// widget._appState.route = SignupPath();
// // widget.goTo('signup');
// },
// child: Text(getTranslated(context, 'signup')))
// ],
// ),
// )
// ],
// ),
// )
// ],
// ),
// ),
// ),
// ),
