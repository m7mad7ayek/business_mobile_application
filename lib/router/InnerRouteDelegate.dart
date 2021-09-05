import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wedeliver_business/router/RoutePath.dart';
import 'package:wedeliver_business/router/paths/LoginPath.dart';
import 'package:wedeliver_business/router/paths/NewOrderPath.dart';
import 'package:wedeliver_business/router/paths/OrderListPath.dart';
import 'package:wedeliver_business/router/paths/SettingsPath.dart';
import 'package:wedeliver_business/router/paths/SignupPath.dart';
import 'package:wedeliver_business/router/paths/SupportPath.dart';
import 'package:wedeliver_business/router/paths/TermAndConditionsPath.dart';
import 'package:wedeliver_business/router/paths/WalletPath.dart';
import 'package:wedeliver_business/screens/FadeAnimationPage.dart';
import 'package:wedeliver_business/screens/LoginScreen.dart';
import 'package:wedeliver_business/screens/NewOrderScreen.dart';
import 'package:wedeliver_business/screens/OrderDetailsScreen.dart';
import 'package:wedeliver_business/screens/OrderListScreen.dart';
import 'package:wedeliver_business/screens/SettingScreen.dart';
import 'package:wedeliver_business/screens/SignupScreen.dart';
import 'package:wedeliver_business/screens/SupportScreen.dart';
import 'package:wedeliver_business/screens/TermsAndConditionsScreen.dart';
import 'package:wedeliver_business/screens/WalletScreen.dart';
import 'package:wedeliver_business/state/appState.dart';

class InnerRouteDelegate extends RouterDelegate<RoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePath> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  List<Page> pages = [];

  AppState _appState;

  AppState get appState => _appState;

  set appState(AppState newState) {
    if (newState == _appState) {
      return;
    }
    _appState = newState;
    notifyListeners();
  }

  InnerRouteDelegate(this._appState);

  List<Page> buildPages(RoutePath route) {
    bool hasParent = route.parents.length > 0;

    for (RoutePath rp in route.parents) {
      buildPages(rp);
      // var test = 1;
      // pages.addAll(_p);
    }
    // if(appState.route.parents.length > 0)

    dynamic screen = null;
    if (route is LoginPath) {
      screen = LoginScreen(this.appState);
    } else if (route is SignupPath) {
      screen = SignupScreen(this.appState);
    } else if (route is TermsAndConditionsPath) {
      screen = TermsAndConditionsScreen();
    } else if (route is OrderListPath) {
      screen = OrderListScreen(this.appState);
    } else if (route is WalletPath) {
      screen = WalletScreen();
    } else if (route is NewOrderPath) {
      screen = NewOrderScreen(this.appState);
    } else if (route is SupportPath) {
      screen = SupportScreen();
    } else if (route is SettingsPath) {
      screen = SettingScreen(this.appState);
    }
    pages.add(hasParent
        ? MaterialPage(
            key: ValueKey(route.path),
            child: screen,
          )
        : FadeAnimationPage(
            key: ValueKey(route.path),
            child: screen,
          ));
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    pages = [];
    return Navigator(
      key: this.navigatorKey,
      pages: [
        ...buildPages(appState.route)

        /* if(appState.route is LoginPath || appState.route.children.contains(LoginPath))
          FadeAnimationPage(
            child: LoginScreen(this.appState),
        )*/
        /*if (appState.loggedIn != true) ...[
          FadeAnimationPage(
            child: LoginScreen(
              goTo: (path) {
                appState.isSignupScreen = true;
                // notifyListeners();
              },
              onAuthed: (user) {
                appState.loggedIn = true;
                appState.selectedIndex = 0;
                // notifyListeners();
              },
            ),
          ),
          if (appState.isSignupScreen == true) ...[
            MaterialPage(
              key: ValueKey('Signup'),
              child: SignupScreen(
                goTo: (path) {
                  var test = 1;

                  appState.isTermsAndConditions = true;
                },
              ),
            ),
            if (appState.isTermsAndConditions == true)
              MaterialPage(
                key: ValueKey('Terms and Conditions'),
                child: TermsAndConditionsScreen(),
              ),
          ]
        ] else if (appState.selectedIndex == 0) ...[
          FadeAnimationPage(
            child: OrderListScreen(
              orders: appState.orders,
              onTap: (order) {
                appState.selectedOrder = order;
                // notifyListeners();
              },
            ),
          ),
          if (appState.selectedOrder != null)
            MaterialPage(
              key: ValueKey(appState.selectedOrder),
              child: OrderDetailsScreen(
                order: appState.selectedOrder,
              ),
            ),
        ] else ...[
          if (appState.selectedIndex == 1)
            FadeAnimationPage(
              child: WalletScreen(),
              key: ValueKey('Wallet'),
            ),
          if (appState.selectedIndex == 2)
            FadeAnimationPage(
              child: NewOrderScreen(
                onPlaceOrder: (response) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Order has been created successfully'),
                    ),
                  );
                  appState.selectedIndex = 0;
                },
              ),
              key: ValueKey('New Order'),
            ),
          if (appState.selectedIndex == 3)
            FadeAnimationPage(
              child: SupportScreen(),
              key: ValueKey('Support'),
            )
          else if (appState.selectedIndex == 4)
            FadeAnimationPage(
              child: SettingScreen(
                onOptionPressed: (String option) {
                  if (option == 'logout') {
                    appState.loggedIn = false;
                    notifyListeners();
                  }
                },
              ),
              key: ValueKey('Setting'),
            ),
        ]*/
      ],
      onPopPage: (route, result) {
        appState.route =
            appState.route.parents[appState.route.parents.length - 1];
        //  notifyListeners();
        return route.didPop(result);
      },
    );
  }

  @override
  Future<void> setNewRoutePath(RoutePath config) async {
    // TODO: implement setNewRoutePath
    throw UnimplementedError();
  }
}
