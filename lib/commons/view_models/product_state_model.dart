import 'package:flutter/material.dart';

class ProductStateModel extends ChangeNotifier {
  
  bool _refresh = false;
  bool get refresh => _refresh;
  setRefresh(bool refresh) => _refresh = refresh;

}