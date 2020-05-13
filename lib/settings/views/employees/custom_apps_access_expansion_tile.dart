import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../view_models/view_models.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

class CustomAppsAccessExpansionTile extends StatefulWidget {
  final List<BusinessApps> businessApps;
  final EmployeesStateModel employeesStateModel;
  final bool isNewEmployeeOrGroup;

  const CustomAppsAccessExpansionTile(
      {Key key,
      @required this.businessApps,
      @required this.employeesStateModel,
      @required this.isNewEmployeeOrGroup})
      : super(key: key);

  @override
  createState() => _CustomAppsAccessExpansionTileState();
}

class _CustomAppsAccessExpansionTileState
    extends State<CustomAppsAccessExpansionTile> {
  int _activeIndex;

  static String uiKit = Env.commerceOs + "/assets/ui-kit/icons-png/";

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: ClampingScrollPhysics(),
//        physics: AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
//          itemCount: widget.businessApps.length,
        itemCount: widget.employeesStateModel.businessApps.length,
        itemBuilder: (BuildContext context, int i) {
          var appIndex = widget.businessApps[i];
          return Theme(
            data: Theme.of(context).copyWith(
                cardColor: Colors.white.withOpacity(0.2),
                brightness: Brightness.dark),
            child: Container(
              child: ExpansionPanelList(
                expansionCallback: (int index, bool status) {
                  setState(() {
                    _activeIndex = _activeIndex == i ? null : i;
                  });
                },
                children: [
                  ExpansionPanel(
                    isExpanded: _activeIndex == i,
                    canTapOnHeader: true,
                    headerBuilder: (BuildContext context, bool isExpanded) =>
                        Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
                                CachedNetworkImage(
                                  imageUrl: uiKit + appIndex.dashboardInfo.icon,
                                ),
                                SizedBox(width: 10),
                                Text(
                                    Language.getCommerceOSStrings(
                                        appIndex.dashboardInfo.title),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal)),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: Measurements.width * 0.05),
                          ),
                        ],
                      ),
                    ),
//                    body: widget.businessApps[i],
                    body: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: Measurements.width * 0.065,
                            right: Measurements.width * 0.040),
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
                                        value: widget.employeesStateModel
                                            .businessApps[i].allowedAcls.create,
                                        onChanged: (bool value) {
                                          setState(() {
                                            widget.employeesStateModel
                                                .updateBusinessAppPermissionCreate(
                                                    i, value);
                                            widget.employeesStateModel
                                                .updateBusinessAppPermissionRead(
                                                    i, value);
                                            widget.employeesStateModel
                                                .updateBusinessAppPermissionUpdate(
                                                    i, value);
                                            widget.employeesStateModel
                                                .updateBusinessAppPermissionDelete(
                                                    i, value);
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
//                                value: appIndex.allowedAcls.read,
                                        value: widget.employeesStateModel
                                            .businessApps[i].allowedAcls.read,
                                        onChanged: (bool value) {
                                          setState(() {
                                            widget.employeesStateModel
                                                .updateBusinessAppPermissionRead(
                                                    i, value);
                                            if (widget
                                                    .employeesStateModel
                                                    .businessApps[i]
                                                    .allowedAcls
                                                    .create ==
                                                true) {
                                              widget.employeesStateModel
                                                  .updateBusinessAppPermissionCreate(
                                                      i, value);
                                            }
                                            if (widget
                                                    .employeesStateModel
                                                    .businessApps[i]
                                                    .allowedAcls
                                                    .update ==
                                                true) {
                                              widget.employeesStateModel
                                                  .updateBusinessAppPermissionUpdate(
                                                      i, value);
                                            }
                                            if (widget
                                                    .employeesStateModel
                                                    .businessApps[i]
                                                    .allowedAcls
                                                    .delete ==
                                                true) {
                                              widget.employeesStateModel
                                                  .updateBusinessAppPermissionDelete(
                                                      i, value);
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
//                                value: appIndex.allowedAcls.update,
                                        value: widget.employeesStateModel
                                            .businessApps[i].allowedAcls.update,
                                        onChanged: (bool value) {
                                          setState(() {
                                            if (widget
                                                    .employeesStateModel
                                                    .businessApps[i]
                                                    .allowedAcls
                                                    .read ==
                                                false) {
                                              print("read not selected");
                                            } else {
                                              widget.employeesStateModel
                                                  .updateBusinessAppPermissionUpdate(
                                                      i, value);
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
//                                value: appIndex.allowedAcls.delete,
                                        value: widget.employeesStateModel
                                            .businessApps[i].allowedAcls.delete,
                                        onChanged: (bool value) {
                                          setState(() {
                                            if (widget
                                                    .employeesStateModel
                                                    .businessApps[i]
                                                    .allowedAcls
                                                    .read ==
                                                false) {
                                              print("read not selected");
                                            } else {
                                              widget.employeesStateModel
                                                  .updateBusinessAppPermissionDelete(
                                                      i, value);
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
                  ),
                ],
              ),
            ),
          );
        });
  }
}
