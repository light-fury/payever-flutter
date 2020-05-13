import 'package:flutter/material.dart';

class ExpandableHeader {
  final Icon icon;
  final String title;
  final bool isExpanded;

  ExpandableHeader({this.icon, this.title, this.isExpanded});

  factory ExpandableHeader.toMap(data) {
    return ExpandableHeader(
      icon: data['icon'],
      title: data['title'],
      isExpanded: data['isExpanded']
    );
  }




}