import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final String label;
  final bool loading;
  final ButtonStyle style;
  final ValueChanged onPressed;

  LoadingButton(
      {this.loading, this.onPressed, this.label, this.style});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: style != null ? style : null,
      icon: loading
          ? SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
              height: 15,
              width: 15,
            )
          : SizedBox.shrink(),
      onPressed: loading
          ? null
          : () {
              onPressed(null);
            },
      label: Text(label),
    );
  }
}
