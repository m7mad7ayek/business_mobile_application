import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wedeliver_business/OuterAppShell.dart';
import 'package:wedeliver_business/router/paths/LoginPath.dart';
import 'package:wedeliver_business/router/paths/OrderDetailsPath.dart';
import 'package:wedeliver_business/router/paths/OrderListPath.dart';
import 'package:wedeliver_business/router/RoutePath.dart';
import 'package:wedeliver_business/router/paths/SettingsPath.dart';
import 'package:wedeliver_business/state/appState.dart';

import '../AppShell.dart';

class OrderRouteDelegate extends RouterDelegate<RoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;

  AppState appState = AppState();

  OrderRouteDelegate() : navigatorKey = GlobalKey<NavigatorState>() {
    appState.addListener(notifyListeners);
  }

  @override
  Future<void> setNewRoutePath(RoutePath config) async {
    appState.ready = true;
    appState.route = config;
    if (config is LoginPath) {

      appState.loggedIn = false;
    } else {
      appState.loggedIn = true;
      if (config is OrderListPath) {
        appState.selectedIndex = 0;
        appState.selectedOrder = null;
      } else if (config is OrderDetailsPath) {
        // nested home/ details screen
        appState.setSelectedOrderById(config.id);
      } else if (config is SettingsPath) {
        // setting screen
        appState.selectedIndex = 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: this.navigatorKey,
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }
          if (appState.selectedOrder != null) {
            appState.selectedOrder = null;
          }
          notifyListeners();
          return true;
        },
        pages: [
          if(appState.ready == false)
            MaterialPage(
              child: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else
            if (appState.route.isPublic == true)
              MaterialPage(
              child: OuterAppShell(appState: appState),
              )
            else
              MaterialPage(
                child: AppShell(appState: appState),
              )

        ]);
  }
}
