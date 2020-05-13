import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../commons/views/custom_elements/custom_elements.dart';
import '../../view_models/view_models.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';


bool _isPortrait;
bool _isTablet;

class GroupsSelectorScreen extends StatefulWidget {
  @override
  createState() => _GroupsSelectorScreenState();
}

class _GroupsSelectorScreenState extends State<GroupsSelectorScreen> {
  final _key = GlobalKey<ScaffoldState>();

  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    GlobalStateModel globalStateModel = Provider.of<GlobalStateModel>(context);

    _isPortrait = Orientation.portrait == MediaQuery.of(context).orientation;
    _isTablet = Measurements.width < 600 ? false : true;
    Measurements.height = (_isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width);
    Measurements.width = (_isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height);

    List<BusinessEmployeesGroups> businessEmployeesGroups = List<BusinessEmployeesGroups>();
    List<BusinessEmployeesGroups> selectedOptions = List<BusinessEmployeesGroups>();

    businessEmployeesGroups.add(BusinessEmployeesGroups.fromMap({"name": "MyGroup1"}));
    businessEmployeesGroups.add(BusinessEmployeesGroups.fromMap({"name": "MyGroup2"}));
    businessEmployeesGroups.add(BusinessEmployeesGroups.fromMap({"name": "MyGroup3"}));
    businessEmployeesGroups.add(BusinessEmployeesGroups.fromMap({"name": "MyGroup4"}));
    businessEmployeesGroups.add(BusinessEmployeesGroups.fromMap({"name": "MyGroup5"}));
    businessEmployeesGroups.add(BusinessEmployeesGroups.fromMap({"name": "MyGroup6"}));
    businessEmployeesGroups.add(BusinessEmployeesGroups.fromMap({"name": "MyGroup7"}));
    businessEmployeesGroups.add(BusinessEmployeesGroups.fromMap({"name": "MyGroup8"}));

    return OrientationBuilder(builder: (BuildContext context, Orientation orientation) {

      return Stack(
        children: <Widget>[
          Positioned(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              top: 0.0,
              child: CachedNetworkImage(
                imageUrl: globalStateModel.currentWallpaper ??
                    globalStateModel.defaultCustomWallpaper,
                placeholder: (context, url) => Container(),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
              )),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              child: Scaffold(
                backgroundColor: Colors.black.withOpacity(0.2),
                appBar: CustomAppBar(
                  title: Text("Add user to groups"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                body: Form(
                  key: _key,
                  onWillPop: _onWillPop,
                  child: Container(
                    child: Column(
                      children: <Widget>[
//                        Text("Select groups"),
//                        EmployeesGroupsMultiSelect(
//                          businessEmployeesGroups,
//                          selectedOptions,
//                          onSelectionChanged: (List<BusinessEmployeesGroups> selectedList) {
//
//                          },
//                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },);


  }
}
