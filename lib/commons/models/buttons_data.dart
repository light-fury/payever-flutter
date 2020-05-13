import 'package:flutter/material.dart';

class ButtonsData {
  final ImageProvider icon;
  final String title;
  final VoidCallback action;

  ButtonsData({this.icon, this.title, this.action});

  factory ButtonsData.toMap(data) {
    return ButtonsData(
        icon: data['icon'], title: data['title'], action: data['action']);
  }
}
