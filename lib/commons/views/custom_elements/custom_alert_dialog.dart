import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onContinuePressed;

  CustomAlertDialog(
      {Key key,
      @required this.title,
      @required this.message,
      @required this.onContinuePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel", style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("Continue", style: TextStyle(color: Colors.white)),
          onPressed: onContinuePressed,
        ),
      ],
    );
  }
}
