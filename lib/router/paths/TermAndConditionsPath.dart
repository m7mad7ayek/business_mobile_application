import 'package:wedeliver_business/router/RoutePath.dart';
import 'package:wedeliver_business/router/paths/LoginPath.dart';
import 'package:wedeliver_business/router/paths/SignupPath.dart';

class TermsAndConditionsPath extends RoutePath {
  String path = '/terms-and-conditions';
  bool isPublic = true;
  List<RoutePath> _parents = [SignupPath()];

  List<RoutePath> get parents => _parents;
}
