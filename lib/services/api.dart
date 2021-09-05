import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future call(
    {String url,
    String method,
    Map<String, dynamic> data,
    dynamic includeBID = false}) async {
  dynamic formData;
  if (method == 'GET') {
    formData = data;
  } else {
    formData = new FormData.fromMap(data);
  }

  // or new Dio with a BaseOptions instance.
  var options = BaseOptions(
    baseUrl: 'https://expressapis.wedeliverspace.dev/api/v1',

    //baseUrl: 'https://expressapis.wedeliverspace.dev/api/v1',
   // baseUrl: 'https://expressapis.wedeliverapp.com/api/v1',
    /*connectTimeout: 5000,
    receiveTimeout: 3000,*/
  );
  Dio dio = Dio(options);

  final prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var user = prefs.getString('user');
  Map<String, dynamic> userinfo = jsonDecode(user == null ? '{}' : user);
  if ((includeBID.runtimeType == bool && includeBID == true) ||
      includeBID.runtimeType == String) {
    String key = includeBID.runtimeType == String && includeBID.isNotEmpty
        ? includeBID
        : 'business_id';
    if (method == 'POST') {
      formData.fields.add(MapEntry(key, userinfo['business_id'].toString()));
    } else {
      if (formData == null) {
        formData = new Map<String, dynamic>();
      }
      formData[key] = userinfo['business_id'].toString();
    }
  }


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

  final _options = Options(
    method: method,
    headers: {
      Headers.contentTypeHeader: 'multipart/form-data',
      'Authorization': token,
      'App-Version': version,
      'Platform': platform,
      'Platform-Version': platformVersion,
    },
  );
  var response;
  try {
    if (method == 'GET') {
      response = await dio
          .get(
        url,
        queryParameters: formData,
        options: _options,
      )
          .catchError((error) {
        return error?.response;
      });
    } else {
      var test = 1;
      response = await dio
          .post(
        url,
        data: formData,
        options: _options,
      )
          .catchError((error) {
        return error?.response;
      });
    }
  } catch (e) {
    var test = 1;
  }

  final result = response?.data;

  if (response?.statusCode != 200) {
    throw Exception(result.runtimeType == String
        ? response?.statusMessage
        : result['message']);
  }

  return result;
}
