import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../commons/views/custom_elements/custom_elements.dart';
import '../../view_models/view_models.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import 'custom_apps_access_expansion_tile.dart';

bool _isPortrait;
bool _isTablet;

class AddGroupScreen extends StatefulWidget {
  @override
  createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  TextEditingController _groupNameController = TextEditingController();

  EmployeesStateModel employeesStateModel;

  @override
  void initState() {
    super.initState();
//    _groupNameController.text = employeesStateModel.groupValue;
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<List<BusinessApps>> getBusinessApps(
      EmployeesStateModel employeesStateModel) async {
    List<BusinessApps> businessApps = List<BusinessApps>();
    var apps = await employeesStateModel.getAppsBusinessInfo();
    for (var app in apps) {
      var appData = BusinessApps.fromMap(app);
      if (appData.dashboardInfo.title != null) {
        if (appData.allowedAcls.create != null) {
          appData.allowedAcls.create = false;
        }
        if (appData.allowedAcls.read != null) {
          appData.allowedAcls.read = false;
        }
        if (appData.allowedAcls.update != null) {
          appData.allowedAcls.update = false;
        }
        if (appData.allowedAcls.delete != null) {
          appData.allowedAcls.delete = false;
        }
        businessApps.add(appData);
      }
    }

    employeesStateModel.updateBusinessApps(businessApps);

    print("businessApps: $businessApps");

    return businessApps;
  }

  @override
  Widget build(BuildContext context) {
    GlobalStateModel globalStateModel = Provider.of<GlobalStateModel>(context);
    employeesStateModel = Provider.of<EmployeesStateModel>(context);

    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        _isPortrait =
            Orientation.portrait == MediaQuery.of(context).orientation;
        _isTablet = Measurements.width < 600 ? false : true;
        Measurements.height = (_isPortrait
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.width);
        Measurements.width = (_isPortrait
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.height);

        return BackgroundBase(
          true,
          appBar: CustomAppBar(
            title: Text("Add New Group"),
            onTap: () {
              Navigator.pop(context);
            },
            actions: <Widget>[
              StreamBuilder(
                  stream: employeesStateModel.group,
                  builder: (context, snapshot) {
                    return RawMaterialButton(
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Save',
                        style: TextStyle(
                            color: snapshot.hasData
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            fontSize: 18),
                      ),
                      onPressed: () {
                        if (snapshot.hasData) {
                          print("data can be send");
                          _createNewGroup(
                              globalStateModel, employeesStateModel, context);
                        } else {
                          print("The data can't be send");
                        }
                      },
                    );
                  }),
            ],
          ),
          body: CustomFutureBuilder<List<BusinessApps>>(
            future: getBusinessApps(employeesStateModel),
            errorMessage: "Error loading apps access",
            onDataLoaded: (List results) {
              return SafeArea(
                child: Container(
                  padding: EdgeInsets.only(
                      top: Measurements.width * 0.01,
//                      right: Measurements.width * 0.01,
//                      left: Measurements.width * 0.01,
                      bottom: Measurements.width * 0.08),
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        height: Measurements.width * (_isTablet ? 0.13 : 0.18),
                        padding: EdgeInsets.symmetric(
                            horizontal: Measurements.width * 0.02),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0)),
                            color: Colors.black.withOpacity(0.5)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                StreamBuilder(
                                    stream: employeesStateModel.group,
                                    builder: (context, snapshot) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                Measurements.width * 0.025),
                                        alignment: Alignment.center,
                                        color: Colors.white.withOpacity(0.05),
                                        width: Measurements.width * 0.475,
//                                              height: Measurements.height *
//                                                  (_isTablet ? 0.08 : 0.07),
                                        child: TextField(
                                          controller: _groupNameController,
                                          onChanged:
                                              employeesStateModel.changeGroup,
                                          style: TextStyle(
                                              fontSize:
                                                  Measurements.height * 0.02),
                                          decoration: InputDecoration(
                                            hintText: "Group Name",
                                            hintStyle: TextStyle(
                                              color: snapshot.hasError
                                                  ? Colors.red
                                                  : Colors.white
                                                      .withOpacity(0.5),
                                            ),
                                            labelText: "Group Name",
                                            labelStyle: TextStyle(
                                              color: snapshot.hasError
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                            border: InputBorder.none,
                                          ),
//                                                onSaved: (firstName) {},
                                          //  validator: (value) {
                                          //
                                          //  },
                                        ),
                                      );
                                    }),
                              ],
                            ),
                          ],
                        ),
                      ),
//                              EmployeesAppsAccessComponent(
//                                openedRow: ValueNotifier(1),
//                                businessAppsData: results,
//                                isNewEmployeeOrGroup: true,
//                              ),

                      Flexible(
                        child: CustomExpansionTile(
                          isWithCustomIcon: false,
                          widgetsTitleList: <Widget>[
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.business_center,
                                          size: 28,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Apps Access",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: Measurements.width * 0.05),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          widgetsBodyList: <Widget>[
                            CustomAppsAccessExpansionTile(
                              employeesStateModel: employeesStateModel,
                              businessApps: results,
                              isNewEmployeeOrGroup: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _createNewGroup(GlobalStateModel globalStateModel,
      EmployeesStateModel employeesStateModel, BuildContext context) async {
    List<GroupAcl> groupAclList = List<GroupAcl>();
    for (var app in employeesStateModel.businessApps) {
      if (app.allowedAcls.create != null && app.allowedAcls.create == true ||
          app.allowedAcls.read != null && app.allowedAcls.read == true ||
          app.allowedAcls.update != null && app.allowedAcls.update == true ||
          app.allowedAcls.delete != null && app.allowedAcls.delete == true) {
        var aclData = Map();
        aclData['microservice'] = app.dashboardInfo.title;
        if (app.allowedAcls.create != null) {
          aclData['create'] = app.allowedAcls.create;
        }
        if (app.allowedAcls.read != null) {
          aclData['read'] = app.allowedAcls.read;
        }
        if (app.allowedAcls.update != null) {
          aclData['update'] = app.allowedAcls.update;
        }
        if (app.allowedAcls.delete != null) {
          aclData['delete'] = app.allowedAcls.delete;
        }

        groupAclList.add(GroupAcl(aclData));
      }

//      print("app.dashboardInfo.title: ${app.dashboardInfo.title}" + " "
//          + "app.allowedAcls.create: ${app.allowedAcls.create}" + " "
//          + "app.allowedAcls.read: ${app.allowedAcls.read}" + " "
//          + "app.allowedAcls.update: ${app.allowedAcls.update}" + " "
//          + "app.allowedAcls.delete: ${app.allowedAcls.delete}");

    }

//    print("groupAclList: $groupAclList");

    var data = {
      "name": _groupNameController.text,
      "acls": groupAclList,
    };

    print("DATA: $data");

    await employeesStateModel.createNewGroup(data);
    Navigator.of(context).pop();
  }
}
