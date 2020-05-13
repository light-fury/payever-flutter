import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../../models/models.dart';
import '../../../network/network.dart';
import '../../../utils/utils.dart';

class SearchParts {
  bool _isPortrait;
  bool _isTablet;
}

class SearchCard extends StatefulWidget {
  final ValueNotifier<String> search;
  final String id;

  SearchCard(this.search, this.id);

  @override
  createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  List<Transaction> _list = List();

  SearchParts _parts = SearchParts();
  String oldString = "";
  Stopwatch watch = Stopwatch();
  Timer t;

  @override
  void initState() {
    super.initState();
    widget.search.addListener(listener);
    watch.start();

    setState(() {
      _parts = SearchParts();
      print(_parts._isTablet);
    });
  }

  @override
  Widget build(BuildContext context) {
    _parts._isPortrait =
        Orientation.portrait == MediaQuery.of(context).orientation;
    Measurements.height = (_parts._isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width);
    Measurements.width = (_parts._isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height);
    _parts._isTablet = Measurements.width < 600 ? false : true;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Measurements.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(),
    );
  }

  void listener() {
    if (watch.elapsedMilliseconds < 2500) {
      print("send");
      send();
    } else {
      watch.reset();
      delete();
    }
  }

  void send() {
    RestDataSource api = RestDataSource();
    api
        .getTransactionList(
            widget.id,
            GlobalUtils.activeToken.accessToken,
            "?limit=8&query=${widget.search.value}&orderBy=created_at&direction=desc",
            context)
        .then((result) {
      print(result);
      _list = List();
      print(_list);
      oldString = widget.search.value;
    });
  }

  void delete() {
    RestDataSource api = RestDataSource();
    api
        .deleteTransactionList(widget.id, GlobalUtils.activeToken.accessToken,
            "?limit=8&query=$oldString&orderBy=created_at&direction=desc")
        .then((result) {
      print(result);
      send();
    });
  }
}
