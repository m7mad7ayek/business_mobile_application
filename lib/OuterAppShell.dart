import 'package:flutter/material.dart';
import 'package:wedeliver_business/router/InnerRouteDelegate.dart';
import 'package:wedeliver_business/state/appState.dart';

class OuterAppShell extends StatefulWidget {
  AppState appState;

  OuterAppShell({@required this.appState});

  @override
  _OuterAppState createState() => _OuterAppState();
}

class _OuterAppState extends State<OuterAppShell> {
  InnerRouteDelegate _innerRouteDelegate;
  ChildBackButtonDispatcher _backButtonDispatcher;

  @override
  void initState() {
    super.initState();
    _innerRouteDelegate = InnerRouteDelegate(widget.appState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _backButtonDispatcher = Router.of(context)
        .backButtonDispatcher
        .createChildBackButtonDispatcher();
  }

  @override
  void didUpdateWidget(covariant OuterAppShell oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    _innerRouteDelegate.appState = widget.appState;
  }

  @override
  Widget build(BuildContext context) {
    var appState = widget.appState;
    return Scaffold(
      // appBar: AppBar(),
      body: Router(
        routerDelegate: _innerRouteDelegate,
        backButtonDispatcher: _backButtonDispatcher,
      ),
    );
  }
}
