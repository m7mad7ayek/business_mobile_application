import 'package:flutter/cupertino.dart';

class FadeAnimationPage extends Page {
  final Widget child;

  FadeAnimationPage({Key key, this.child}) : super(key: key);

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
        settings: this,
        pageBuilder: (_, anime1, anime2) {
          var curveTween = CurveTween(curve: Curves.easeIn);
          return FadeTransition(
            opacity: anime1.drive(curveTween),
            child: this.child,
          );
        });
  }
}
