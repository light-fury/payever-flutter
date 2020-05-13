import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../commons/views/custom_elements/custom_elements.dart';
import '../../view_models/view_models.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import 'expandable_component.dart';

class EmployeesAppsAccessComponent extends StatefulWidget {
  final ValueNotifier openedRow;
  final List<BusinessApps> businessAppsData;
  final List<GroupAcl> groupAclsList;
  final Function(bool) isChanged;
  final bool isNewEmployeeOrGroup;

  EmployeesAppsAccessComponent(
      {@required this.openedRow,
      @required this.businessAppsData,
      this.groupAclsList,
      this.isChanged,
      @required this.isNewEmployeeOrGroup});

  @override
  createState() => _EmployeesAppsAccessComponentState();
}

class _EmployeesAppsAccessComponentState
    extends State<EmployeesAppsAccessComponent> with TickerProviderStateMixin {
  bool isOpen = false;

  bool _isPortrait = true;
  bool _isTablet = true;

  static String uiKit = Env.commerceOs + "/assets/ui-kit/icons-png/";

  listener() {
    setState(() {
      if (widget.openedRow.value == 1) {
        isOpen = !isOpen;
      } else {
        isOpen = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      if (widget.openedRow.value == 1) {
        isOpen = !isOpen;
      } else {
        isOpen = false;
      }
    });

    widget.openedRow.addListener(listener);
  }

  _getAppsComponentAccess() {
    if (widget.isNewEmployeeOrGroup) {}
  }

  _getAclsData() {
    for (var acl in widget.groupAclsList) {
      for (var app in widget.businessAppsData) {
        if (app.dashboardInfo.title == acl.aclData['microservice']) {
//          setState(() {
          if (app.allowedAcls.create != null) {
            app.allowedAcls.create = acl.aclData['create'];
          }
          if (app.allowedAcls.read != null) {
            app.allowedAcls.read = acl.aclData['read'];
          }
          if (app.allowedAcls.update != null) {
            app.allowedAcls.update = acl.aclData['update'];
          }
          if (app.allowedAcls.delete != null) {
            app.allowedAcls.delete = acl.aclData['delete'];
          }
//          });

        }
      }
    }
  }

  Future<void> checkAppsAcls() async {
    if (widget.groupAclsList != null) {
      await _getAclsData();
      return "";
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    EmployeesStateModel employeesStateModel =
        Provider.of<EmployeesStateModel>(context);

    _isPortrait = Orientation.portrait == MediaQuery.of(context).orientation;
    Measurements.height = (_isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width);
    Measurements.width = (_isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height);
    _isTablet = Measurements.width < 600 ? false : true;

    Widget getAppsAccessRow() {
      return ListView.builder(
        padding: EdgeInsets.all(0.1),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: employeesStateModel.businessApps.length,
        itemBuilder: (BuildContext context, int index) {
          var appIndex = widget.businessAppsData[index];
          return CustomFutureBuilder(
            future: checkAppsAcls(),
            errorMessage: "Error loading apps",
            onDataLoaded: (results) {
              return ExpandableListView(
                iconData: NetworkImage(uiKit + appIndex.dashboardInfo.icon),
                title:
                    Language.getCommerceOSStrings(appIndex.dashboardInfo.title),
                isExpanded: false,
                openedAppRowIndex: index,
                openedAppRow: ValueNotifier(999),
                widgetList: Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Measurements.width * 0.020),
                    child: Column(
                      children: <Widget>[
                        appIndex.allowedAcls.create != null
                            ? Divider()
                            : Container(width: 0, height: 0),
                        appIndex.allowedAcls.create != null
                            ? Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Create",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Switch(
                                    activeColor: Color(0XFF0084ff),
                                    value: employeesStateModel
                                        .businessApps[index].allowedAcls.create,
                                    onChanged: (bool value) {
                                      setState(() {
//                                   widget.isChanged(true);
                                        employeesStateModel
                                            .updateBusinessAppPermissionCreate(
                                                index, value);
                                        employeesStateModel
                                            .updateBusinessAppPermissionRead(
                                                index, value);
                                        if (employeesStateModel
                                                .businessApps[index]
                                                .allowedAcls
                                                .update ==
                                            true) {
                                          employeesStateModel
                                              .updateBusinessAppPermissionUpdate(
                                                  index, value);
                                        }
                                        if (employeesStateModel
                                                .businessApps[index]
                                                .allowedAcls
                                                .delete ==
                                            true) {
                                          employeesStateModel
                                              .updateBusinessAppPermissionDelete(
                                                  index, value);
                                        }
                                      });
                                    },
                                  )
                                ],
                              )
                            : Container(width: 0, height: 0),
                        appIndex.allowedAcls.read != null
                            ? Divider()
                            : Container(width: 0, height: 0),
                        appIndex.allowedAcls.read != null
                            ? Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Read",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Switch(
                                    activeColor: Color(0XFF0084ff),
                                    value: employeesStateModel
                                        .businessApps[index].allowedAcls.read,
                                    onChanged: (bool value) {
                                      setState(() {
//                                   widget.isChanged(true);
                                        employeesStateModel
                                            .updateBusinessAppPermissionRead(
                                                index, value);
                                        if (employeesStateModel
                                                .businessApps[index]
                                                .allowedAcls
                                                .create ==
                                            true) {
                                          employeesStateModel
                                              .updateBusinessAppPermissionCreate(
                                                  index, value);
                                        }
                                        if (employeesStateModel
                                                .businessApps[index]
                                                .allowedAcls
                                                .update ==
                                            true) {
                                          employeesStateModel
                                              .updateBusinessAppPermissionUpdate(
                                                  index, value);
                                        }
                                        if (employeesStateModel
                                                .businessApps[index]
                                                .allowedAcls
                                                .delete ==
                                            true) {
                                          employeesStateModel
                                              .updateBusinessAppPermissionDelete(
                                                  index, value);
                                        }
                                      });
                                    },
                                  )
                                ],
                              )
                            : Container(width: 0, height: 0),
                        appIndex.allowedAcls.update != null
                            ? Divider()
                            : Container(width: 0, height: 0),
                        appIndex.allowedAcls.update != null
                            ? Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Update",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Switch(
                                    activeColor: Color(0XFF0084ff),
                                    value: employeesStateModel
                                        .businessApps[index].allowedAcls.update,
                                    onChanged: (bool value) {
                                      setState(() {
//                                   widget.isChanged(true);
                                        if (employeesStateModel
                                                .businessApps[index]
                                                .allowedAcls
                                                .read ==
                                            false) {
                                          print("read not selected");
                                        } else {
                                          employeesStateModel
                                              .updateBusinessAppPermissionUpdate(
                                                  index, value);
                                        }
                                      });
                                    },
                                  )
                                ],
                              )
                            : Container(width: 0, height: 0),
                        appIndex.allowedAcls.delete != null
                            ? Divider()
                            : Container(width: 0, height: 0),
                        appIndex.allowedAcls.delete != null
                            ? Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Delete",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Switch(
                                    activeColor: Color(0XFF0084ff),
                                    value: employeesStateModel
                                        .businessApps[index].allowedAcls.delete,
                                    onChanged: (bool value) {
                                      setState(() {
//                                   widget.isChanged(true);
                                        if (employeesStateModel
                                                .businessApps[index]
                                                .allowedAcls
                                                .read ==
                                            false) {
                                          print("read not selected");
                                        } else {
                                          employeesStateModel
                                              .updateBusinessAppPermissionDelete(
                                                  index, value);
                                        }
                                      });
                                    },
                                  )
                                ],
                              )
                            : Container(width: 0, height: 0),
                        Divider(),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
          ),
          child: InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                IconButton(
                  icon: Icon(isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                  onPressed: () {
                    widget.openedRow.notifyListeners();
                    widget.openedRow.value = 1;
                  },
                ),
              ],
            ),
            onTap: () {
              widget.openedRow.notifyListeners();
              widget.openedRow.value = 1;
            },
          ),
        ),
        AnimatedContainer(
            color: Colors.white.withOpacity(0.05),
            duration: Duration(milliseconds: 200),
            width: _isPortrait ? Measurements.width : double.infinity,
            child: Container(
              width: Measurements.width * 0.999,
              child: isOpen
                  ? AnimatedSize(
                      duration: Duration(milliseconds: 5),
                      curve: Curves.linear,
//                      curve: Curves.easeInOut,
                      vsync: this,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Measurements.width * 0.0015),
                        color: Colors.black.withOpacity(0.05),
                        child: getAppsAccessRow(),
                      ),
                    )
                  : Container(width: 0, height: 0),
            )),
      ],
    );
  }
}
