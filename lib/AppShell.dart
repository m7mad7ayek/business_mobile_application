import 'package:flutter/material.dart';
import 'package:wedeliver_business/router/InnerRouteDelegate.dart';
import 'package:wedeliver_business/router/paths/NewOrderPath.dart';
import 'package:wedeliver_business/router/paths/OrderListPath.dart';
import 'package:wedeliver_business/router/paths/SettingsPath.dart';
import 'package:wedeliver_business/router/paths/SupportPath.dart';
import 'package:wedeliver_business/router/paths/WalletPath.dart';
import 'package:wedeliver_business/state/appState.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'localization/language_constant.dart';

class AppShell extends StatefulWidget {
  AppState appState;

  AppShell({@required this.appState});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<AppShell> {
  InnerRouteDelegate _innerRouteDelegate;
  ChildBackButtonDispatcher _backButtonDispatcher;
  bool keyboardOpen = false;
  var keyboardVisibilityController;
  @override
  void initState() {
    super.initState();
    _innerRouteDelegate = InnerRouteDelegate(widget.appState);
    keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() => keyboardOpen = visible);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _backButtonDispatcher = Router.of(context)
        .backButtonDispatcher
        .createChildBackButtonDispatcher();
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    _innerRouteDelegate.appState = widget.appState;
  }

  @override
  Widget build(BuildContext context) {
    var appState = widget.appState;
    return Scaffold(
      resizeToAvoidBottomInset: false,
        // appBar: AppBar(),
        body: Router(
          routerDelegate: _innerRouteDelegate,
          backButtonDispatcher: _backButtonDispatcher,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
        child:  keyboardOpen
        ? SizedBox()
            :
        FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            appState.route = NewOrderPath();
            appState.selectedIndex = 2;
          },
        ),),
        bottomNavigationBar: keyboardOpen
            ? SizedBox()
            :BottomAppBar(
          shape: CircularNotchedRectangle(),
          color: Colors.white,
          notchMargin: 10,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          child: BottomNavigationBar(
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            /*selectedLabelStyle: TextStyle(fontSize: 0),
          unselectedLabelStyle: TextStyle(fontSize: 0),*/
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: new Icon(
                  Icons.home,
                ),
                label: getTranslated(context, 'home'),
              ),
              BottomNavigationBarItem(
                icon: new Icon(Icons.account_balance_wallet),
                label: getTranslated(context, 'wallet'),
              ),
              BottomNavigationBarItem(
                icon: new Icon(
                  Icons.add_circle,
                  color: Colors.transparent,
                ),
                label: getTranslated(context, 'new_order'),
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.support_agent_outlined), label: getTranslated(context, 'support')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: getTranslated(context, 'settings')),
            ],
            currentIndex: appState.selectedIndex,
            onTap: (inx) {
              switch (inx) {
                case 0:
                  appState.route = OrderListPath();
                  break;
                case 1:
                  appState.route = WalletPath();
                  break;
                case 2:
                  appState.route = NewOrderPath();
                  break;
                case 3:
                  appState.route = SupportPath();
                  break;
                case 4:
                  appState.route = SettingsPath();
                  break;
              }
              appState.selectedIndex = inx;
            },
          ),
        ) /*BottomNavigationBar(
        fixedColor: Colors.black,
        unselectedItemColor: Colors.black38,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.add_circle),
            label: 'Create Order',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.support_agent_outlined), label: 'Support'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: appState.selectedIndex,
        onTap: (inx) {
          appState.selectedIndex = inx;
        },
      ),*/
        );
  }
}
