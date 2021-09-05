import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedeliver_business/router/paths/LoginPath.dart';
import 'package:wedeliver_business/router/paths/OrderDetailsPath.dart';
import 'package:wedeliver_business/router/paths/OrderListPath.dart';
import 'package:wedeliver_business/router/RoutePath.dart';
import 'package:wedeliver_business/router/paths/SettingsPath.dart';

class OrderRouteInformationParser
    extends RouteInformationParser<RoutePath> {
  @override
  Future<RoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? '');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if(token == null || token.isEmpty){
      return LoginPath();
    }

    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'settings') {
      return SettingsPath();
    } else {
      if (uri.pathSegments.length >= 2) {
        if (uri.pathSegments[0] == 'order') {
          return OrderDetailsPath(int.tryParse(uri.pathSegments[1]));
        }
      }
      return OrderListPath();
    }
  }

  @override
  RouteInformation restoreRouteInformation(RoutePath config) {
    if (config is OrderListPath) {
      return RouteInformation(location: '/home');
    }
    if (config is OrderDetailsPath) {
      return RouteInformation(location: '/order/${config.id}');
    }
    if (config is SettingsPath) {
      return RouteInformation(location: '/settings');
    }
    return null;
  }
}
