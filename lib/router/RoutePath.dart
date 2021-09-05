import 'package:flutter/cupertino.dart';

abstract class RoutePath {
  String path;
  bool isPublic = false;
  List parents = [];
  dynamic screen;
}
