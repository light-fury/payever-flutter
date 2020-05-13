import 'package:flutter/material.dart';

class CustomAppBar extends AppBar {
  CustomAppBar(
      {Key key, Widget title, VoidCallback onTap, List<Widget> actions})
      : super(
            key: key,
            title: title,
            backgroundColor: Colors.transparent,
            brightness: Brightness.dark,
            leading: InkWell(
              radius: 20,
              child: Icon(IconData(58829, fontFamily: 'MaterialIcons')),
              onTap: onTap,
            ),
            centerTitle: true,
            elevation: 0,
            actions: actions);
}
