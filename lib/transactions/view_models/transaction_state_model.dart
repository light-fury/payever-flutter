import 'package:flutter/material.dart';

class TransactionStateModel extends ChangeNotifier {
  
  String _searchField =""; 
  String get searchField => _searchField;
  setSearchField(String _search) => _searchField = _search;

}