import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../../commons/views/custom_elements/custom_elements.dart';
import '../../../commons/views/screens/login/login.dart';
import '../../view_models/view_models.dart';
import '../../network/network.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

bool _isPortrait;
bool _isTablet;

class EmployeesSelectionsListScreen extends StatefulWidget {
  final List<String> employeesList;
  final String groupId;

  const EmployeesSelectionsListScreen(
      {Key key, @required this.employeesList, @required this.groupId})
      : super(key: key);

  @override
  createState() => _EmployeesSelectionsListScreenState();
}

class _EmployeesSelectionsListScreenState
    extends State<EmployeesSelectionsListScreen> {
  GlobalStateModel globalStateModel;

  List<String> employeesIdsToGroup = List<String>();

  @override
  void initState() {
    super.initState();
  }

  Future<List<Employees>> fetchEmployeesList(
      String search, bool init, GlobalStateModel globalStateModel) async {
    List<Employees> employeesList = List<Employees>();

    EmployeesApi api = EmployeesApi();

    await api
        .getEmployeesList(globalStateModel.currentBusiness.id,
            GlobalUtils.activeToken.accessToken, context)
        .then((employeesData) {
      print("getEmployeesList: Employees data loaded: $employeesData");

      for (var employee in employeesData) {
        var employeeInfo = Employees.fromMap(employee);
        print("employeeInfo: $employeeInfo");
        if (!widget.employeesList.contains(employeeInfo.id)) {
          employeesList.add(Employees.fromMap(employee));
        }
      }
    }).catchError((onError) {
      print("Error loading employees: $onError");

      if (onError.toString().contains("401")) {
        GlobalUtils.clearCredentials();
        Navigator.pushReplacement(
            context,
            PageTransition(
                child: LoginScreen(), type: PageTransitionType.fade));
      }
    });

    return employeesList;
  }

  @override
  Widget build(BuildContext context) {
    globalStateModel = Provider.of<GlobalStateModel>(context);
    _isPortrait = Orientation.portrait == MediaQuery.of(context).orientation;
    _isTablet = Measurements.width < 600 ? false : true;
    Measurements.height = (_isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width);
    Measurements.width = (_isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height);

    EmployeesStateModel employeesStateModel =
        Provider.of<EmployeesStateModel>(context);

    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return BackgroundBase(
          true,
          appBar: CustomAppBar(
            title: StreamBuilder(
                stream: employeesStateModel.availableEmployeeList,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return Text(snapshot.hasData
                      ? "${employeesIdsToGroup.length} Employees Selected"
                      : "Select Employees");
                }),
            onTap: () {
              Navigator.pop(context);
            },
            actions: <Widget>[
              StreamBuilder(
                  stream: employeesStateModel.availableEmployeeList,
                  builder: (context, snapshot) {
                    return RawMaterialButton(
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Add',
                        style: TextStyle(
                            color: snapshot.hasData
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            fontSize: 18),
                      ),
                      onPressed: () {
                        if (snapshot.hasData) {
                          print("data can be send");
                          _inviteEmployeesToGroup(
                              globalStateModel, employeesStateModel, context);
                        } else {
                          print("The data can't be send");
                        }
                      },
                    );
                  }),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                CustomFutureBuilder<List<Employees>>(
                  future: fetchEmployeesList("", true, globalStateModel),
                  errorMessage: "Error loading employees",
                  onDataLoaded: (results) {
                    if (results.length == 0) {
                      return Expanded(
                        child: Center(
                          child: Text("No employees yet"),
                        ),
                      );
                    } else {
                      return Expanded(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 2),
//                                  ListView.builder(
//                                    shrinkWrap: true,
//                                    itemCount: values.length,
//                                    itemBuilder: (BuildContext context, int index) {
//                                        return CheckboxListTile(
//                                          title: Text("Hello $index"),
//                                          value: values[index],
//                                          onChanged: (bool value) {
//                                            setState(() {
////                                              values.keys[index] = value;
//                                            });
//                                          },
//                                        );
//                                  },),

//                              ListView(
//                                children: values.keys.map((String key) {
//                                  return new CheckboxListTile(
//                                    title: new Text(key),
//                                    value: values[key],
//                                    onChanged: (bool value) {
//                                      setState(() {
//                                        values[key] = value;
//                                      });
//                                    },
//                                  );
//                                }).toList(),),

                            Expanded(
                              child: CustomList(
                                  globalStateModel.currentBusiness,
                                  "",
                                  results,
                                  EmployeesScreenData(results,
                                      globalStateModel.currentWallpaper),
                                  ValueNotifier(false),
                                  0,
                                  employeesIdsToGroup,
                                  employeesStateModel),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _inviteEmployeesToGroup(GlobalStateModel globalStateModel,
      EmployeesStateModel employeesStateModel, BuildContext context) async {
    print("employeesIdsToGroup: $employeesIdsToGroup");

    var data = {"employees": employeesIdsToGroup};

    await employeesStateModel.addEmployeesToGroup(widget.groupId, data);
    Navigator.of(context).pop();
  }
}

class EmployeesScreenData {
  Business _business;
  String _wallpaper;
  List<Employees> _employees = List<Employees>();

  EmployeesScreenData(dynamic obj, String wallpaper) {
    _employees = obj;
  }

  List<Employees> get employees => _employees;

  Business get business => _business;

  String get wallpaper => _wallpaper;
}

class CustomList extends StatefulWidget {
  final List<Employees> employeesData;
  final Business currentBusiness;
  final EmployeesScreenData data;
  final List<String> employeesIdsToGroup;
  final EmployeesStateModel employeesStateModel;

  final ValueNotifier isLoading;
  final String search;
  final int page = 1;
  final int pageCount;

  CustomList(
      this.currentBusiness,
      this.search,
      this.employeesData,
      this.data,
      this.isLoading,
      this.pageCount,
      this.employeesIdsToGroup,
      this.employeesStateModel);

  @override
  _CustomListState createState() => _CustomListState();
}

class _CustomListState extends State<CustomList> {
  ScrollController controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
//      physics: ClampingScrollPhysics(),
//          controller: controller,
      itemCount: widget.employeesData.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0)
          return _isTablet
              ? TabletTableRow(null, true, null, widget.employeesIdsToGroup,
                  widget.employeesStateModel)
              : PhoneTableRow(null, true, null, widget.employeesIdsToGroup,
                  widget.employeesStateModel);
        index = index - 1;
        return _isTablet
            ? TabletTableRow(widget.employeesData[index], false, widget.data,
                widget.employeesIdsToGroup, widget.employeesStateModel)
            : PhoneTableRow(widget.employeesData[index], false, widget.data,
                widget.employeesIdsToGroup, widget.employeesStateModel);
      },
    );
  }
}

class PhoneTableRow extends StatefulWidget {
  final Employees _currentEmployee;
  final bool _isHeader;
  final EmployeesScreenData data;
  final List<String> employeesIdsToGroup;
  final EmployeesStateModel employeesStateModel;

  PhoneTableRow(this._currentEmployee, this._isHeader, this.data,
      this.employeesIdsToGroup, this.employeesStateModel);

  @override
  _PhoneTableRowState createState() => _PhoneTableRowState();
}

class _PhoneTableRowState extends State<PhoneTableRow> {
  bool isChecked = false;

  bool _isPortrait;
  bool _isTablet;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    GlobalStateModel globalStateModel = Provider.of<GlobalStateModel>(context);

    _isPortrait = Orientation.portrait == MediaQuery.of(context).orientation;
    _isTablet = Measurements.width < 600 ? false : true;
    Measurements.height = (_isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width);
    Measurements.width = (_isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height);

    return InkWell(
      child: Container(
        alignment: Alignment.topCenter,
        width: Measurements.width,
        padding: EdgeInsets.symmetric(horizontal: Measurements.width * 0.05),
//        height: Measurements.height * (!widget._isHeader ? 0.12 : 0.09),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              color: !widget._isHeader
                  ? Colors.transparent
                  : Colors.black.withOpacity(0.5),
//              width: !_isHeader ? Measurements.width * (_isPortrait ? 0.9 : 0.99) : Measurements.width * (_isPortrait ? 0.9 : 0.99),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      height:
                          Measurements.height * (_isPortrait ? 0.050 : 0.045),
                      child: !widget._isHeader
                          ?
//                      Container(
////                              height: Measurements.height *
////                                  (_isPortrait ? 0.050 : 0.085),
//                              child: Checkbox(
//                                activeColor: Color(0XFF0084ff),
//                                value: isChecked,
//                                onChanged: (bool value) {
//                                  setState(() {
//                                    isChecked = value;
//                                    print("value: $value");
//                                    if (value == true) {
//                                      widget.employeesIdsToGroup
//                                          .add(widget._currentEmployee.id);
//
//                                      widget.employeesStateModel
//                                          .changEmployeeList(
//                                              widget.employeesIdsToGroup);
//                                    } else {
//                                      widget.employeesIdsToGroup
//                                          .remove(widget._currentEmployee.id);
//
//                                      widget.employeesStateModel
//                                          .changEmployeeList(
//                                              widget.employeesIdsToGroup);
//                                    }
//                                  });
//
//                                  print(
//                                      "employeesIdsToGroup: ${widget.employeesIdsToGroup}");
//                                },
//                              ),
//                            )

                          InkWell(
                              onTap: () {
                                setState(() {
                                  isChecked = !isChecked;
                                  if (isChecked == true) {
                                    widget.employeesIdsToGroup
                                        .add(widget._currentEmployee.id);

                                    widget.employeesStateModel
                                        .changEmployeeList(
                                            widget.employeesIdsToGroup);
                                  } else {
                                    widget.employeesIdsToGroup
                                        .remove(widget._currentEmployee.id);

                                    widget.employeesStateModel
                                        .changEmployeeList(
                                            widget.employeesIdsToGroup);
                                  }
                                });
                              },
                              child: Center(
                                child: SizedBox(
                                  width: Measurements.width * 0.05,
                                  height: Measurements.height * 0.0280,
                                  child: Container(
                                    child: Center(
                                      child: isChecked
                                          ? Icon(Icons.check,
                                              color: Colors.white,
                                              size: Measurements.width * 0.04)
                                          : Container(),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border.all(
                                          width: Measurements.width * 0.002,
                                          color: isChecked
                                              ? Colors.white
                                              : Colors.black38),
                                      borderRadius: const BorderRadius.all(
                                          const Radius.circular(5)),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              width: Measurements.width * 0.050, height: 0),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.centerLeft,
//                    width: Measurements.width * 0.2,
                      height:
                          Measurements.height * (_isPortrait ? 0.050 : 0.045),
                      child: !widget._isHeader
                          ? AutoSizeText(
                              widget._currentEmployee.firstName +
                                  " " +
                                  widget._currentEmployee.lastName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false)
                          : Container(
                              alignment: Alignment.centerLeft,
//                              height: Measurements.height *
//                                  (_isPortrait ? 0.050 : 0.055),
                              child: AutoSizeText(
                                  Language.getTransactionStrings(
                                      "Employee name"),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(fontSize: 14))),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: Measurements.width * (_isPortrait ? 0.20 : 0.25),
                      height:
                          Measurements.height * (_isPortrait ? 0.050 : 0.045),
                      child: !widget._isHeader
                          ? AutoSizeText(widget._currentEmployee.position,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false)
                          : Container(
                              alignment: Alignment.centerLeft,
//                              height: Measurements.height *
//                                  (_isPortrait ? 0.050 : 0.058),
                              child: AutoSizeText(
                                  Language.getTransactionStrings("Position"),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(fontSize: 14))),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: Measurements.width * (_isPortrait ? 0.23 : 0.25),
                      height:
                          Measurements.height * (_isPortrait ? 0.050 : 0.045),
                      child: !widget._isHeader
                          ? AutoSizeText(widget._currentEmployee.email,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false)
                          : Container(
                              alignment: Alignment.centerLeft,
//                              height: Measurements.height *
//                                  (_isPortrait ? 0.050 : 0.055),
                              child: AutoSizeText(
                                  Language.getTransactionStrings("Mail"),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(fontSize: 14))),
                    ),
                  ),
                ],
              ),
            ),
            Divider()
          ],
        ),
      ),
      onTap: () {
        if (!widget._isHeader) {
//          Navigator.push(
//              context,
//              PageTransition(
//                child: ProxyProvider<RestDatasource, EmployeesStateModel>(
//                  builder: (context, api, employeesState) =>
//                      EmployeesStateModel(globalStateModel, api),
//                  child: EmployeeDetailsScreen(_currentEmployee),
//                ),
//                type: PageTransitionType.fade,
//              ));
        }
      },
    );
  }
}

class TabletTableRow extends StatefulWidget {
  final Employees _currentEmployee;
  final bool _isHeader;
  final EmployeesScreenData data;
  final List<String> employeesIdsToGroup;
  final EmployeesStateModel employeesStateModel;

  TabletTableRow(this._currentEmployee, this._isHeader, this.data,
      this.employeesIdsToGroup, this.employeesStateModel);

  @override
  _TabletTableRowState createState() => _TabletTableRowState();
}

class _TabletTableRowState extends State<TabletTableRow> {
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        alignment: Alignment.topCenter,
        width: Measurements.width,
        padding: EdgeInsets.symmetric(horizontal: Measurements.width * 0.05),
        height: Measurements.height * (!widget._isHeader ? 0.07 : 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              color: !widget._isHeader
                  ? Colors.transparent
                  : Colors.black.withOpacity(0.5),
//              width: !_isHeader ? Measurements.width * (_isPortrait ? 0.9 : 0.99) : Measurements.width * (_isPortrait ? 0.9 : 0.99),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: !widget._isHeader
                          ?
//                      Container(
////                              height: Measurements.height *
////                                  (_isPortrait ? 0.050 : 0.085),
//                              child: Checkbox(
//                                activeColor: Color(0XFF0084ff),
//                                value: isChecked,
//                                onChanged: (bool value) {
//                                  setState(() {
//                                    isChecked = value;
//                                    print("value: $value");
//                                    if (value == true) {
//                                      widget.employeesIdsToGroup
//                                          .add(widget._currentEmployee.id);
//
//                                      widget.employeesStateModel
//                                          .changEmployeeList(
//                                              widget.employeesIdsToGroup);
//                                    } else {
//                                      widget.employeesIdsToGroup
//                                          .remove(widget._currentEmployee.id);
//
//                                      widget.employeesStateModel
//                                          .changEmployeeList(
//                                              widget.employeesIdsToGroup);
//                                    }
//                                  });
//
//                                  print(
//                                      "employeesIdsToGroup: ${widget.employeesIdsToGroup}");
//                                },
//                              ),
//                            )

                          InkWell(
                              onTap: () {
                                setState(() {
                                  isChecked = !isChecked;
                                  if (isChecked == true) {
                                    widget.employeesIdsToGroup
                                        .add(widget._currentEmployee.id);

                                    widget.employeesStateModel
                                        .changEmployeeList(
                                            widget.employeesIdsToGroup);
                                  } else {
                                    widget.employeesIdsToGroup
                                        .remove(widget._currentEmployee.id);

                                    widget.employeesStateModel
                                        .changEmployeeList(
                                            widget.employeesIdsToGroup);
                                  }
                                });
                              },
                              child: Center(
                                child: SizedBox(
                                  width: Measurements.width * 0.03,
                                  height: Measurements.height * 0.0230,
                                  child: Container(
                                    child: Center(
                                      child: isChecked
                                          ? Icon(Icons.check,
                                              color: Colors.white,
                                              size: Measurements.width * 0.02)
                                          : Container(),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border.all(
                                          width: Measurements.width * 0.002,
                                          color: isChecked
                                              ? Colors.white
                                              : Colors.grey),
                                      borderRadius: const BorderRadius.all(
                                          const Radius.circular(5)),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              width: Measurements.width * 0.050, height: 0),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.centerLeft,
//                    width: Measurements.width * 0.2,
                      child: !widget._isHeader
                          ? AutoSizeText(
                              widget._currentEmployee.firstName +
                                  " " +
                                  widget._currentEmployee.lastName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false)
                          : Container(
                              alignment: Alignment.centerLeft,
                              height: Measurements.height *
                                  (_isPortrait ? 0.050 : 0.051),
                              child: AutoSizeText(
                                  Language.getTransactionStrings(
                                      "Employee name"),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(fontSize: 14))),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: Measurements.width * (_isPortrait ? 0.20 : 0.25),
                      child: !widget._isHeader
                          ? AutoSizeText(widget._currentEmployee.position,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false)
                          : Container(
                              alignment: Alignment.centerLeft,
                              height: Measurements.height *
                                  (_isPortrait ? 0.050 : 0.051),
                              child: AutoSizeText(
                                  Language.getTransactionStrings("Position"),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(fontSize: 14))),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: Measurements.width * (_isPortrait ? 0.23 : 0.25),
                      child: !widget._isHeader
                          ? AutoSizeText(widget._currentEmployee.email,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false)
                          : Container(
                              alignment: Alignment.centerLeft,
                              height: Measurements.height *
                                  (_isPortrait ? 0.050 : 0.051),
                              child: AutoSizeText(
                                  Language.getTransactionStrings("Mail"),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(fontSize: 14))),
                    ),
                  ),
                ],
              ),
            ),
            Divider()
          ],
        ),
      ),
      onTap: () {
        if (!widget._isHeader) {
//          Navigator.push(
//              context,
//              PageTransition(
//                child: EmployeeDetailsScreen(_currentWallpaper, _currentBusiness, _currentEmployee),
//                type: PageTransitionType.fade,
//              ));

//            Navigator.pushNamed(context, '/employeeDetails', arguments: _currentEmployee);

//          Navigator.push(
//              context,
//              PageTransition(
//                child: EmployeeDetailsScreen(_currentEmployee),
//                type: PageTransitionType.fade,
//              ));
        }
      },
    );
  }
}
