import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wedeliver_business/localization/language_constant.dart';

class SupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'support')),
      ),
      body: Center(
        child: Text('Support Screen'),
      ),
    );
  }
}
