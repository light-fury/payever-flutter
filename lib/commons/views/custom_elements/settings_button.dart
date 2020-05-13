import 'package:flutter/material.dart';

class CustomSettingsButton extends StatelessWidget {
  final VoidCallback _onPressed;
  final Icon _buttonIcon;
  final String _buttonText;
  final Color _buttonColor;

  CustomSettingsButton(
      {Key key,
      @required VoidCallback onPressed,
      @required Icon buttonIcon,
      @required String buttonText,
      Color buttonColor})
      : _onPressed = onPressed,
        _buttonIcon = buttonIcon,
        _buttonText = buttonText,
        _buttonColor = buttonColor,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0,
          color: _buttonColor,
          disabledColor: Colors.grey,
          highlightColor: Colors.grey,
          splashColor: Colors.blueGrey,
          onPressed: _onPressed,
          child: FittedBox(
            child: Row(
              children: <Widget>[
                _buttonIcon,
                SizedBox(width: 10),
                Text(
                  _buttonText,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'Montserrat'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
