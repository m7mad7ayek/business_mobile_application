import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:wedeliver_business/common/LoadingButton.dart';
import 'package:wedeliver_business/localization/language_constant.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  @override
  _TermsAndConditionsScreen createState() => _TermsAndConditionsScreen();
}

class _TermsAndConditionsScreen extends State<TermsAndConditionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'terms_and_conditions')),
      ),
      body:
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16,right: 16,bottom: 16),
          child: Column(
            children: [
              SizedBox(height: 15,),
              Center(child: Text(getTranslated(context, 'terms_and_conditions_title'))),
              SizedBox(height: 4,),
              Text(getTranslated(context, 'terms_and_conditions_value'),textDirection: TextDirection.rtl,)
            ]


          ),
        ),
      )
      // Markdown(
      //     styleSheet: MarkdownStyleSheet(
      //       textAlign: WrapAlignment.end,
      //       h1Align: WrapAlignment.center,
      //     ),    data: getTranslated(context, 'terms_and_conditions_value')),

    );

  }
}
