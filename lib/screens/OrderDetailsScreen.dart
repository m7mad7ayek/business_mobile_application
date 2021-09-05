import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wedeliver_business/localization/language_constant.dart';
import 'package:wedeliver_business/models/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  final ValueKey key;
  final Order order;

  OrderDetailsScreen({this.key, this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(getTranslated(context, 'back')),
              ),
              if (this.order != null) ...[
                Text(this.order.business,
                    style: Theme.of(context).textTheme.headline3),
              ]
            ],
          ),
        ));
  }
}
