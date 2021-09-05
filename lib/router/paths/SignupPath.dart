import 'package:wedeliver_business/router/RoutePath.dart';
import 'package:wedeliver_business/router/paths/LoginPath.dart';

class SignupPath extends RoutePath {
  String path = '/signup';
  bool isPublic = true;
  List<RoutePath> _parents = [LoginPath()];

  List<RoutePath> get parents => _parents;
}
