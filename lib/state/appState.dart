import 'package:flutter/cupertino.dart';
import 'package:wedeliver_business/models/order_model.dart';
import 'package:wedeliver_business/router/RoutePath.dart';
import 'package:wedeliver_business/router/paths/LoginPath.dart';
import 'package:wedeliver_business/router/paths/SignupPath.dart';

class AppState extends ChangeNotifier {
  int _selectedIndex;
  Order _selectedOrder;
  RoutePath _route;
  bool _loggedIn;
  bool _isSignupScreen;
  bool _isTermsAndConditions;
  bool _ready = false;

  final List<Order> orders = [
    Order(id: 1, business: 'Test1', branch: 'Hi1'),
    Order(id: 2, business: 'Test2', branch: 'Hi2'),
    Order(id: 3, business: 'Test3', branch: 'Hi3'),
    Order(id: 4, business: 'Test4', branch: 'Hi4')
  ];

  AppState() : _selectedIndex = 0;

  bool get loggedIn => _loggedIn;

  set loggedIn(bool v){
    _loggedIn = v;
    notifyListeners();
  }

  RoutePath get route => _route;

  set route(RoutePath routePath){
    _route = routePath;
    notifyListeners();
  }

  bool get ready => _ready;

  set ready(bool v) {
    _ready = v;
    notifyListeners();
  }

  bool get isSignupScreen => _isSignupScreen;

  set isSignupScreen(bool v) {
    _isSignupScreen = v;
    notifyListeners();
  }

  bool get isTermsAndConditions => _isTermsAndConditions;

  set isTermsAndConditions(bool v) {
    _isTermsAndConditions = v;
    notifyListeners();
  }

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int v) {
    _selectedIndex = v;
    if (_selectedIndex == 1) {
      _selectedOrder = null;
    }

    // notifyListeners();
  }

  Order get selectedOrder => _selectedOrder;

  set selectedOrder(Order value) {
    _selectedOrder = value;
    notifyListeners();
  }

  int getSelectedOrderById(int id) {
    if (!orders.contains(_selectedOrder)) return 0;
    return orders.indexOf(_selectedOrder);
  }

  void setSelectedOrderById(int id) {
    if (id < 0 || id > orders.length - 1) {
      return;
    }
    _selectedOrder = orders[id];
  }
}
