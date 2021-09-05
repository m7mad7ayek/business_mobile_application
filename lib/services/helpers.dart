import 'package:flutter/material.dart';

MaterialColor buildMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

const Color GREY_COLOR = Color.fromRGBO(248, 247, 251, 1);
const Color PURPLE_COLOR = Color.fromRGBO(97, 61, 183, 1);

class Palette {
  Color _bg;
  Color _bc;
  Color _fc;

  set bg(Color c) {
    _bg = c;
  } 

  Color get bg => _bg;

  set bc(Color c) {
    _bc= c;
  } 

  Color get bc => _bc;

  set fc(Color c) {
    _fc = c;
  } 

  Color get fc => _fc;
}

Palette getStatusColor({@required String status}) {

  Palette p = new Palette();
  switch (status.toLowerCase()) {
    case 'rto':
    case 'delivering':
    case 'picking up':
    case 'reached pick up location':
    case 'reached drop off location':
      p.bg =  Color.fromRGBO(230, 247, 255, 1);
      p.bc = Color.fromRGBO(91, 145, 255, 1);
      p.fc = Color.fromRGBO(28, 153, 255, 1);
      break;
    case 'assigned for delivery':
    case 'assigned for picking up':
      p.bg = Color.fromRGBO(230, 255, 251, 1);
      p.bc = Color.fromRGBO(161, 238, 230, 1);
      p.fc = Color.fromRGBO(26, 207, 221, 1);
      break;
    case 'rto successful':
    case 'picked up':
    case 'delivered':
      p.bg = Color.fromRGBO(246, 255, 237, 1);
      p.bc = Color.fromRGBO(199, 240, 168, 1);
      p.fc = Color.fromRGBO(131, 201, 77, 1);
      break;
    case 'pending':
    case 'pending delivery':
      p.bg = Color.fromRGBO(255, 247, 230, 1);
      p.bc = Color.fromRGBO(255, 231, 191, 1);
      p.fc = Color.fromRGBO(250, 160, 109, 1);
      break;
    case 'canceled':
    case 'rto failed':
    case 'delivery failed':
    case 'picking up failed':
      p.bg = Color.fromRGBO(255, 241, 240, 1);
      p.bc = Color.fromRGBO(255, 204, 200, 1);
      p.fc = Color.fromRGBO(248, 93, 70, 1);
      break;
    default:
      p.bg = Color.fromRGBO(66, 66, 66, 1.0);
      p.bc = Color.fromRGBO(156, 156, 156, 1.0);
      p.fc = Color.fromRGBO(156, 156, 156, 1.0);
      break;
  }

  return p;
}
