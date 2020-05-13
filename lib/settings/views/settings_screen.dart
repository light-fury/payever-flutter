import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/view_models.dart';
import '../../commons/views/custom_elements/custom_elements.dart';
import '../utils/utils.dart';
//import 'settings_drawer.dart';

bool _isPortrait;

class SettingsScreen extends StatefulWidget {
  @override
  createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    _isPortrait = Orientation.portrait == MediaQuery.of(context).orientation;
    Measurements.height = (_isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width);
    Measurements.width = (_isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height);

    GlobalStateModel globalStateModel = Provider.of<GlobalStateModel>(context);

    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return BackgroundBase(
          true,
          appBar: CustomAppBar(
            title: Text("Settings"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                width: Measurements.width,
                child: Card(
                    elevation: 1,
                    color: Colors.grey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.grey.withOpacity(0.2), width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "Business Name:",
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.grey.withOpacity(1)),
                          ),
                          Text(
                            globalStateModel.currentBusiness != null
                                ? globalStateModel.currentBusiness.name
                                : "",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ),
        );
      },
    );
  }
}
