import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:package_info/package_info.dart';
import 'package:wedeliver_business/common/LoadingButton.dart';
import 'package:wedeliver_business/localization/language_constant.dart';
import 'package:wedeliver_business/router/paths/TermAndConditionsPath.dart';
import 'package:wedeliver_business/screens/TermsAndConditionsScreen.dart';
import 'package:wedeliver_business/services/api.dart';
import 'package:wedeliver_business/services/constants.dart';
import 'package:wedeliver_business/state/appState.dart';

class SignupScreen extends StatefulWidget {
  AppState _appState;

  SignupScreen(this._appState);

  @override
  _SignupScreen createState() => _SignupScreen();
}

class InputField {
  TextEditingController controller = TextEditingController();
  bool enabled = true;
  bool loading = false;
  bool show = true;
  bool hasError = false;

  dynamic value;
  List<dynamic> options = [];

  InputField();

  InputField.hidden() : show = false;

  InputField.value(this.value);
}

class _SignupScreen extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController fullNameArController = TextEditingController(text: '');
  TextEditingController fullNameEnController = TextEditingController(text: '');
  TextEditingController userFullNameController =
      TextEditingController(text: '');
  TextEditingController userMobileController = TextEditingController(text: '');
  TextEditingController userEmailController = TextEditingController(text: '');
  TextEditingController addressLineController = TextEditingController(text: '');
  TextEditingController locationManagerMobileNumberController =
      TextEditingController(text: '');
  bool _registeringBusiness = false;
  bool _acceptTermsAndConditions = false;

  Timer bounceTime;

  var form = {
    'area': InputField.hidden(),
    'cr_number': InputField.hidden(),
    'city': InputField(),
    'business_type': InputField(),
  };

  InputDecoration customInputDecoration({labelText, showSuffixIcon = false}) {
    return InputDecoration(
      border: InputBorder.none,
      labelText: labelText,
      filled: true,
      suffixIconConstraints: BoxConstraints(maxHeight: 15, maxWidth: 15),
      suffixIcon: showSuffixIcon
          ? SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            )
          : SizedBox.shrink(),
      fillColor: Colors.grey[250],
      contentPadding: const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
        // borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget header({String label, String infoMessage}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              if (infoMessage != null)
                Tooltip(
                  padding: EdgeInsets.all(8),
                  waitDuration: Duration(milliseconds: 10),
                  message: infoMessage,
                  child: Icon(Icons.info_outline),
                ),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }

  String validateMobileNumber(String value) {
    String pattern;
    String message;

    if (['Personal Project', 'Registered Company']
        .contains(form['business_type'].value)) {
      pattern = saudiMobileNumberPattern;
      message = getTranslated(context, 'correct_sa_num_msj');
    } else {
      pattern = globalMobileNumberPattern;
      message = getTranslated(context, 'correct_g_num_msj');
    }

    RegExp regExp = new RegExp(
      pattern,
      caseSensitive: false,
      multiLine: false,
    );
    bool hasMatch = regExp.hasMatch(value);
    if (!hasMatch) {
      return message;
    }
    return null;
  }

  Future bounceTimer({int milliseconds = 500}) {
    Completer c = new Completer();
    if (bounceTime != null) {
      bounceTime.cancel();
    }
    bounceTime = Timer(Duration(milliseconds: milliseconds), () {
      c.complete();
    });
    return c.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'signup')),
      ),
      body: SingleChildScrollView(
        child: Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              runSpacing: 16,
              children: [
                header(
                  label: getTranslated(context, 'business_details'),
                ),
                TextFormField(
                  autofocus: true,
                  controller: fullNameArController,
                  decoration: customInputDecoration(
                    labelText: getTranslated(context, 'full_name_ar'),
                  ),
                  validator: (String value) {
                    if (value == null || value.isEmpty) {
                      return getTranslated(context, 'full_name_ar_msj');
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: fullNameEnController,
                  decoration: customInputDecoration(
                    labelText: getTranslated(context, 'full_name_eg'),
                  ),
                  validator: (String value) {
                    if (value == null || value.isEmpty) {
                      return getTranslated(context, 'full_name_en_msj');
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  // value: 'hi',
                  decoration: customInputDecoration(
                      labelText: getTranslated(context, 'business_type')),
                  validator: (String value) {
                    if (value == null || value.isEmpty) {
                      return getTranslated(context, 'business_type_msj');
                    }
                    return null;
                  },
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  iconSize: 16,
                  elevation: 16,
                  style: TextStyle(fontSize: 17, color: Colors.black),
                  // underline: SizedBox.shrink(),
                  onChanged: (String value) {
                    form['business_type'].value = value;
                    setState(() {
                      form['cr_number'].show =
                          (value == 'Registered Company' ? true : false);
                    });
                  },
                  items: [
                    'Personal Project',
                    'Registered Company',
                    'Business outside Saudi'
                  ]
                      .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ))
                      .toList(),
                ),
                if (form['cr_number'].show == true)
                  TextFormField(
                    controller: form['cr_number'].controller,
                    decoration: customInputDecoration(
                      labelText: getTranslated(context, 'cr_number'),
                    ),
                    validator: (String value) {
                      if (value == null || value.isEmpty) {
                        return getTranslated(context, 'cr_number_msj');
                      }
                      return null;
                    },
                  ),
                header(
                    label: getTranslated(context, 'primary_user'),
                    infoMessage: getTranslated(context, 'primary_user_msj')),
                TextFormField(
                  controller: userFullNameController,
                  decoration: customInputDecoration(
                    labelText: getTranslated(context, 'full_name'),
                  ),
                  validator: (String value) {
                    if (value == null || value.isEmpty) {
                      return getTranslated(context, 'full_name_msj');
                    }
                    return null;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: userMobileController,
                  decoration: customInputDecoration(
                    labelText: getTranslated(context, 'mobile'),
                  ),
                  validator: (String value) {
                    if (value == null || value.isEmpty) {
                      return getTranslated(context, 'mobile_msj');
                    }

                    return validateMobileNumber(value);
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: userEmailController,
                  decoration: customInputDecoration(
                    labelText: getTranslated(context, 'email'),
                  ),
                  validator: (String value) {
                    if (value == null || value.isEmpty) {
                      return getTranslated(context, 'email_msj_1');
                    }

                    RegExp regex = new RegExp(emailPattern);
                    if (!regex.hasMatch(value) || value == null) {
                      return getTranslated(context, 'email_msj_2');
                    }

                    return null;
                  },
                ),
                header(
                    label: getTranslated(context, 'address'),
                    infoMessage: getTranslated(context, 'address_msj')),
                Column(
                  children: [
                    TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: form['city'].controller,
                        decoration: customInputDecoration(
                          labelText: getTranslated(context, 'city'),
                        ),
                      ),
                      debounceDuration: Duration(milliseconds: 500),
                      hideOnLoading: true,
                      hideOnEmpty: true,
                      suggestionsCallback: (query) async {
                        var result = [];

                        if (query.isEmpty || query.length < 3) {
                          print('Query needs to be at least 3 chars');
                          return Future.value([]);
                        }

                        result = await call(
                          url: '/location/get_all_abstract_cities',
                          method: 'GET',
                          data: {'search_txt': query},
                        );
                        return result;
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion['name']),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        form['city'].controller.text = suggestion['name'];
                        form['city'].value = suggestion['id'];

                        setState(() {
                          form['area'].show = true;
                        });
                      },
                    ),
                    Container(
                      constraints: BoxConstraints(
                          maxHeight: form['city'].hasError ? 23 : 0),
                      child: TextFormField(
                        readOnly: true,
                        controller: form['city'].controller,
                        style: TextStyle(color: Colors.transparent),
                        decoration: InputDecoration(border: InputBorder.none),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            form['city'].hasError = true;
                            return getTranslated(context, 'city_msj');
                          }
                          form['city'].hasError = false;
                          return null;
                        },
                      ),
                    )
                  ],
                ),
                if (form['area'].show == true)
                  Column(
                    children: [
                      TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: form['area'].controller,
                          decoration: customInputDecoration(
                            labelText: getTranslated(context, 'area'),
                          ),
                        ),
                        debounceDuration: Duration(milliseconds: 500),
                        hideOnLoading: true,
                        hideOnEmpty: true,
                        suggestionsCallback: (pattern) async {
                          var result = [];
                          if (pattern.isEmpty || pattern.length < 3) {
                            print('Query needs to be at least 3 chars');
                            return Future.value([]);
                          }

                          result = await call(
                            url: '/location/get_all_abstract_areas',
                            method: 'GET',
                            data: {
                              'search_text': pattern,
                              'city_id': form['city'].value,
                            },
                          );
                          return result;
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion['name']),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          form['area'].controller.text = suggestion['name'];
                          form['area'].value = suggestion['id'];
                        },
                      ),
                      Container(
                        constraints: BoxConstraints(
                            maxHeight: form['area'].hasError ? 23 : 0),
                        child: TextFormField(
                          readOnly: true,
                          controller: form['area'].controller,
                          style: TextStyle(color: Colors.transparent),
                          decoration: InputDecoration(border: InputBorder.none),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              form['area'].hasError = true;
                              return getTranslated(context, 'area_msj');
                            }
                            form['area'].hasError = false;
                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                TextFormField(
                  keyboardType: TextInputType.streetAddress,
                  controller: addressLineController,
                  decoration: customInputDecoration(
                    labelText: getTranslated(context, 'address_line'),
                  ),
                  validator: (String value) {
                    if (value == null || value.isEmpty) {
                      return getTranslated(context, 'address_line_msj');
                    }
                    return null;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: locationManagerMobileNumberController,
                  decoration: customInputDecoration(
                    labelText:
                        getTranslated(context, 'mobile_location_manager'),
                  ),
                  validator: (String value) {
                    if (value == null || value.isEmpty) {
                      return getTranslated(
                          context, 'mobile_location_manager_msj');
                    }
                    return validateMobileNumber(value);
                  },
                ),
                Divider(),
                CheckboxListTile(
                  title: Row(
                    children: [
                      Text(getTranslated(context, 'accept')),
                      TextButton(
                          onPressed: () {
                            widget._appState.route = TermsAndConditionsPath();
                          },
                          child: Text(
                            getTranslated(context, 'terms_conditions'),
                            style: TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.underline),
                          ))
                    ],
                  ),
                  value: _acceptTermsAndConditions,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (newValue) {
                    this.setState(() {
                      _acceptTermsAndConditions = newValue;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                LoadingButton(
                  label: getTranslated(context, 'register'),
                  loading: _registeringBusiness,
                  onPressed: (value) {
                    if (_formKey.currentState.validate()) {
                      if (!_acceptTermsAndConditions) {
                        final scaffold = ScaffoldMessenger.of(context);
                        scaffold.showSnackBar(
                          SnackBar(
                            content: Text(
                                getTranslated(context, 'terms_conditions_msj')),
                          ),
                        );
                        return;
                      }

                      print(1);
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      var response;
                      runZonedGuarded(() async {
                        this.setState(() {
                          _registeringBusiness = true;
                        });

                        PackageInfo packageInfo =
                            await PackageInfo.fromPlatform();

                        String version = packageInfo.version;
                        String platform = "";
                        String platformVersion = "";
                        if (Platform.isIOS) {
                          platform = "ios";
                        } else if (Platform.isAndroid) {
                          platform = "android";
                        }

                        if (Platform.isAndroid) {
                          var androidInfo =
                              await DeviceInfoPlugin().androidInfo;
                          platformVersion = androidInfo.version.release;
                        }

                        if (Platform.isIOS) {
                          var iosInfo = await DeviceInfoPlugin().iosInfo;
                          platformVersion = iosInfo.systemVersion;
                        }

                        var params = {
                          'full_name_ar': fullNameArController.text,
                          'full_name_en': fullNameEnController.text,
                          'business_type': form['business_type'].value,
                          'first_user_full_name': userFullNameController.text,
                          'first_user_mobile': userMobileController.text,
                          'first_user_email': userEmailController.text,
                          'first_branch_address_line':
                              addressLineController.text,
                          'first_branch_mobile':
                              locationManagerMobileNumberController.text,
                          'accept_terms_and_conditions': true,
                          'cr_number': form['cr_number'].controller.text,
                          'first_branch_area_id': form['area'].value,
                          'first_branch_city_id': form['city'].value,
                          "app_version": version,
                          "platform": platform,
                          "platform_version": platformVersion,
                          "app": "business app"
                        };

                        var response = await call(
                          url: '/business/one_click_create_business',
                          data: params,
                          method: 'POST',
                        );

                        this.setState(() {
                          _registeringBusiness = false;
                        });

                        // widget.onAuthed(response);
                        print('test $response');
                      }, (Object error, StackTrace stack) {
                        /* usernameController.text = '';
                                        passwordController.text = '';*/
                        this.setState(() {
                          _registeringBusiness = false;
                        });
                        // FocusScope.of(context).requestFocus(focusNode);
                        final scaffold = ScaffoldMessenger.of(context);
                        scaffold.showSnackBar(
                          SnackBar(
                            content: Text(error.toString()),
                          ),
                        );
                      });
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
