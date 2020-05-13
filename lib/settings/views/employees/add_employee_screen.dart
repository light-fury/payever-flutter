import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
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

class AddEmployeeScreen extends StatefulWidget {
  @override
  createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  var openedRow = ValueNotifier(0);

  final _formKey = GlobalKey<FormState>();

  List<EmployeeGroup> employeeCurrentGroups = List<EmployeeGroup>();
  List<String> employeeCurrentGroupsList = List<String>();

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
    EmployeesStateModel employeesStateModel =
        Provider.of<EmployeesStateModel>(context);
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        _isPortrait =
            Orientation.portrait == MediaQuery.of(context).orientation;
        Measurements.height = (_isPortrait
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.width);
        Measurements.width = (_isPortrait
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.height);
        _isTablet = Measurements.width < 600 ? false : true;
        print("_isTablet: $_isTablet");

        return BackgroundBase(
          true,
          appBar: CustomAppBar(
            title: Text("Add Employee"),
            onTap: () {
              Navigator.pop(context);
            },
            actions: <Widget>[
              StreamBuilder(
                  stream: employeesStateModel.submitValid,
                  builder: (context, snapshot) {
                    return RawMaterialButton(
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Invite',
                        style: TextStyle(
                            color: snapshot.hasData
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            fontSize: 18),
                      ),
                      onPressed: () {
                        if (snapshot.hasData) {
                          print("data can be send");
                          _createNewEmployee(
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
            child: Form(
              key: _formKey,
              child: CustomFutureBuilder<List<BusinessApps>>(
                  future: getBusinessApps(employeesStateModel),
                  errorMessage: "Error loading data",
                  onDataLoaded: (List results) {
                    return Column(
                      children: <Widget>[
                        Flexible(
                          child: CustomExpansionTile(
                            isWithCustomIcon: false,
                            widgetsTitleList: <Widget>[
//                                    ExpandableHeader.toMap({"icon": Icon(
//                                      Icons.business_center,
//                                       size: 28,
//                                    ), "title": "Apps Access", "isExpanded": false}),
                              Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.person,
                                            size: 28,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Info",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              Measurements.width * 0.05),
                                    ),
                                  ],
                                ),
                              ),
//                                      Container(
//                                        child: Row(
//                                          mainAxisAlignment:
//                                              MainAxisAlignment.spaceBetween,
//                                          children: <Widget>[
//                                            Container(
//                                              child: Row(
//                                                children: <Widget>[
//                                                  Icon(
//                                                    Icons.business_center,
//                                                    size: 28,
//                                                  ),
//                                                  SizedBox(width: 10),
//                                                  Text(
//                                                    "Apps Access",
//                                                    style:
//                                                        TextStyle(fontSize: 18),
//                                                  ),
//                                                ],
//                                              ),
//                                              padding: EdgeInsets.symmetric(
//                                                  horizontal:
//                                                      Measurements.width *
//                                                          0.05),
//                                            ),
//                                          ],
//                                        ),
//                                      ),
                            ],
                            widgetsBodyList: <Widget>[
                              EmployeeInfoRow(
                                openedRow: openedRow,
                                employeesStateModel: employeesStateModel,
                                employeeCurrentGroups: employeeCurrentGroups,
                                employeeCurrentGroupsList:
                                    employeeCurrentGroupsList,
                              ),
//                                      CustomAppsAccessExpansionTile(
//                                        employeesStateModel:
//                                            employeesStateModel,
//                                        businessApps: results,
//                                        isNewEmployeeOrGroup: true,
//                                      ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ),
        );
      },
    );
  }

  void _createNewEmployee(GlobalStateModel globalStateModel,
      EmployeesStateModel employeesStateModel, BuildContext context) async {
    var data = {
      "email": employeesStateModel.emailValue,
      "first_name": employeesStateModel.firstNameValue,
      "last_name": employeesStateModel.lastNameValue,
      "position": employeesStateModel.positionValue,
      "groups": employeeCurrentGroupsList,
    };

//    print("DATA: $data");

    await employeesStateModel.createNewEmployee(data);
    Navigator.of(context).pop();
  }
}

class EmployeeInfoRow extends StatefulWidget {
  final ValueNotifier openedRow;
  final EmployeesStateModel employeesStateModel;
  final List<EmployeeGroup> employeeCurrentGroups;
  final List<String> employeeCurrentGroupsList;

  EmployeeInfoRow(
      {this.openedRow,
      this.employeesStateModel,
      this.employeeCurrentGroups,
      this.employeeCurrentGroupsList});

  @override
  createState() => _EmployeeInfoRowState();
}

class _EmployeeInfoRowState extends State<EmployeeInfoRow>
    with TickerProviderStateMixin {
  bool isOpen = true;

  bool _isPortrait;
  bool _isTablet;

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  final GlobalKey<AutoCompleteTextFieldState<BusinessEmployeesGroups>> acKey =
      GlobalKey();

  List<BusinessEmployeesGroups> employeesGroupsList =
      List<BusinessEmployeesGroups>();

  listener() {
    setState(() {
      if (widget.openedRow.value == 0) {
        isOpen = !isOpen;
      } else {
        isOpen = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.openedRow.addListener(listener);

    _firstNameController.text = widget.employeesStateModel.firstNameValue;
    _lastNameController.text = widget.employeesStateModel.lastNameValue;
    _emailController.text = widget.employeesStateModel.emailValue;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GlobalStateModel globalStateModel = Provider.of<GlobalStateModel>(context);

//    EmployeesStateModel employeesStateModel =
//        Provider.of<EmployeesStateModel>(context);

    _isPortrait = Orientation.portrait == MediaQuery.of(context).orientation;
    Measurements.height = (_isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width);
    Measurements.width = (_isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height);
    _isTablet = Measurements.width < 600 ? false : true;

    print("_isPortrait: $_isPortrait");
    print("_isTablet: $_isTablet");

    Widget getEmployeeInfoRow() {
      return Column(
        children: <Widget>[
          SizedBox(height: Measurements.height * 0.010),
          Container(
//            color: Colors.blueGrey,
            width: _isPortrait
                ? Measurements.width * 0.96
                : MediaQuery.of(context).size.width * 0.88,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                StreamBuilder(
                    stream: widget.employeesStateModel.firstName,
                    builder: (context, snapshot) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Measurements.width * 0.025),
                        alignment: Alignment.center,
//                        width: Measurements.width * 0.475,
                        width: _isPortrait
                            ? Measurements.width * 0.475
//                            : MediaQuery.of(context).size.width * 0.326,
                            : MediaQuery.of(context).size.width * 0.436,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                        ),
                        child: TextField(
                          controller: _firstNameController,
                          style:
                              TextStyle(fontSize: Measurements.height * 0.02),
                          onChanged: widget.employeesStateModel.changeFirstName,
                          decoration: InputDecoration(
                            hintText: "First Name",
                            hintStyle: TextStyle(
                              color: snapshot.hasError
                                  ? Colors.red
                                  : Colors.white.withOpacity(0.5),
                            ),
                            labelText: "First Name",
                            labelStyle: TextStyle(
                              color:
                                  snapshot.hasError ? Colors.red : Colors.grey,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      );
                    }),
                StreamBuilder(
                    stream: widget.employeesStateModel.lastName,
                    builder: (context, snapshot) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Measurements.width * 0.025),
                        alignment: Alignment.center,
                        width: _isPortrait
                            ? Measurements.width * 0.475
//                            : MediaQuery.of(context).size.width * 0.326,
                            : MediaQuery.of(context).size.width * 0.436,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                        ),
                        child: TextField(
                          controller: _lastNameController,
                          style:
                              TextStyle(fontSize: Measurements.height * 0.02),
                          onChanged: widget.employeesStateModel.changeLastName,
                          decoration: InputDecoration(
                              hintText: "Last Name",
                              hintStyle: TextStyle(
                                color: snapshot.hasError
                                    ? Colors.red
                                    : Colors.white.withOpacity(0.5),
                              ),
                              border: InputBorder.none,
                              labelText: "Last Name",
                              labelStyle: TextStyle(
                                color: snapshot.hasError
                                    ? Colors.red
                                    : Colors.grey,
                              )),
                        ),
                      );
                    })
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: Measurements.width * 0.010),
          ),
          Container(
            width: _isPortrait
                ? Measurements.width * 0.96
                : MediaQuery.of(context).size.width * 0.88,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                StreamBuilder(
                    stream: widget.employeesStateModel.email,
                    builder: (context, snapshot) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Measurements.width * 0.025),
                        alignment: Alignment.center,
                        width: _isPortrait
                            ? Measurements.width * 0.475
                            : MediaQuery.of(context).size.width * 0.436,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                        ),
                        child: TextField(
                          controller: _emailController,
                          style:
                              TextStyle(fontSize: Measurements.height * 0.02),
                          onChanged: widget.employeesStateModel.changeEmail,
                          decoration: InputDecoration(
                            hintText: "Email",
                            hintStyle: TextStyle(
                              color: snapshot.hasError
                                  ? Colors.red
                                  : Colors.white.withOpacity(0.5),
                            ),
                            labelText: "Email",
                            labelStyle: TextStyle(
                              color:
                                  snapshot.hasError ? Colors.red : Colors.grey,
                            ),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      );
                    }),
                StreamBuilder(
                    stream: widget.employeesStateModel.position,
                    builder: (context, snapshot) {
                      return Container(
                        color: Colors.white.withOpacity(0.05),
                        width: _isPortrait
                            ? Measurements.width * 0.475
                            : MediaQuery.of(context).size.width * 0.436,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: snapshot.hasError
                                      ? Colors.red
                                      : Colors.transparent,
                                  width: 1)),
                          child: DropDownMenu(
                            optionsList: GlobalUtils.positionsListOptions(),
                            defaultValue:
                                widget.employeesStateModel.positionValue,
                            placeHolderText: "Position",
                            onChangeSelection: (selectedOption, index) {
                              print("selectedOption: $selectedOption");
                              print("index: $index");
                              widget.employeesStateModel
                                  .changePosition(selectedOption);
                            },
                          ),
                        ),
                      );
                    })
              ],
            ),
          ),
//          SizedBox(height: Measurements.height * 0.010),
          Padding(
            padding: EdgeInsets.only(top: Measurements.width * 0.020),
          ),
          CustomFutureBuilder<List<BusinessEmployeesGroups>>(
            future: fetchEmployeesGroupsList("", true, globalStateModel),
            errorMessage: "",
            onDataLoaded: (List results) {
              return Column(
                children: <Widget>[
                  Container(
                    width: _isPortrait
                        ? Measurements.width * 0.96
                        : MediaQuery.of(context).size.width * 0.88,
                    child: Row(
                      children: <Widget>[
                        Text(
                          "Groups:",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: Measurements.height * 0.060,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.employeeCurrentGroups.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Chip(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.09),
//              label: Text(widget.employeeCurrentGroups[index].name),
                                    label: Text(widget
                                        .employeeCurrentGroups[index].name),
                                    deleteIcon: Icon(
                                      IconData(58829,
                                          fontFamily: 'MaterialIcons'),
                                      size: 20,
                                    ),
                                    onDeleted: () {
                                      print("chip pressed");
                                      var groupIndex =
                                          widget.employeeCurrentGroups[index];
                                      setState(() {
                                        widget.employeeCurrentGroups
                                            .remove(groupIndex);
                                        widget.employeeCurrentGroupsList
                                            .remove(groupIndex.id);
                                      });
                                    },
                                  ),
                                );

//                                return Padding(
//                                  padding: EdgeInsets.all(
//                                      Measurements.width * (_isTablet ? 0.025 : 0.020)),
//                                  child: Container(
//                                    decoration: BoxDecoration(
//                                      color: Colors.white.withOpacity(0.05),
////                                      color: Colors.grey,
//                                      borderRadius: BorderRadius.circular(26),
//                                    ),
//                                    child: Row(
////                                      mainAxisAlignment:
////                                          MainAxisAlignment.spaceEvenly,
//                                      crossAxisAlignment: CrossAxisAlignment.center,
//                                      children: <Widget>[
//                                        Padding(
//                                          padding: EdgeInsets.symmetric(
//                                              horizontal:
//                                              Measurements.width * 0.025),
//                                          child: Center(
//                                              child: Text(widget.employee
//                                                  .groups[index].name, style: TextStyle(fontSize: 15))),
//                                        ),
//                                        Padding(
//                                          padding: EdgeInsets.all(
//                                              Measurements.width * 0.011),
//                                          child: InkWell(
//                                            radius: 20,
//                                            child: Icon(
//                                              IconData(58829,
//                                                  fontFamily: 'MaterialIcons'),
//                                              size: 19,
//                                            ),
//                                            onTap: () {
//                                              setState(() {
//                                                _deleteEmployeeFromGroup(
//                                                    employeesStateModel,
//                                                    widget.employee
//                                                        .groups[index].id);
//                                                widget.employee.groups.remove(
//                                                    widget.employee
//                                                        .groups[index]);
//                                              });
//                                            },
//                                          ),
//                                        )
//                                      ],
//                                    ),
//                                  ),
//                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: Measurements.width * 0.025),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16)),
                    width: _isPortrait
                        ? Measurements.width * 0.96
                        : MediaQuery.of(context).size.width * 0.88,
//                    height: Measurements.height * (_isTablet ? 0.08 : 0.07),
                    child: AutoCompleteTextField<BusinessEmployeesGroups>(
//                      decoration: InputDecoration(
//                          hintText: "Search groups:", suffixIcon: Icon(Icons.search)),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          labelText: "Search groups",
                          labelStyle: TextStyle(color: Colors.grey),
                          hintText: "Search groups here"),
                      itemSubmitted: (item) {
                        setState(() {
                          widget.employeeCurrentGroups.add(
                              EmployeeGroup.fromMap(
                                  {"name": item.name, "_id": item.id}));
                          widget.employeeCurrentGroupsList.add(item.id);
                        });
                      },
                      key: acKey,
                      suggestions: employeesGroupsList,
                      itemBuilder: (context, suggestion) => Padding(
                          child: ListTile(
                            title: Text(suggestion.name),
//                              trailing: Text("Grroups: ${suggestion.name}")
                          ),
                          padding: EdgeInsets.all(8.0)),
                      itemSorter: (a, b) => a.name == b.name ? 0 : -1,
                      itemFilter: (suggestion, input) => suggestion.name
                          .toLowerCase()
                          .startsWith(input.toLowerCase()),
                    ),
                  ),
                ],
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: Measurements.width * 0.020),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
//        Container(
//          decoration: BoxDecoration(
//            color: Colors.white.withOpacity(0.1),
//            borderRadius: BorderRadius.only(
//                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
//          ),
//          child: InkWell(
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              children: <Widget>[
//                Container(
////                  child: Text(Language.getProductStrings("sections.employee")),
//                  child: Row(
//                    children: <Widget>[
//                      Icon(
//                        Icons.person,
//                        size: 28,
//                      ),
//                      SizedBox(width: 10),
//                      Text(
//                        "Info",
//                        style: TextStyle(fontSize: 18),
//                      ),
//                    ],
//                  ),
//                  padding: EdgeInsets.symmetric(
//                      horizontal: Measurements.width * 0.05),
//                ),
//                IconButton(
//                  icon: Icon(isOpen
//                      ? Icons.keyboard_arrow_up
//                      : Icons.keyboard_arrow_down),
//                  onPressed: () {
//                    widget.openedRow.notifyListeners();
//                    widget.openedRow.value = 0;
//                  },
//                ),
//              ],
//            ),
//            onTap: () {
//              widget.openedRow.notifyListeners();
//              widget.openedRow.value = 0;
//            },
//          ),
//        ),
        AnimatedContainer(
            color: Colors.white.withOpacity(0.05),
            duration: Duration(milliseconds: 200),
            child: Container(
              width: _isPortrait ? Measurements.width : double.infinity,
              child: isOpen
                  ? AnimatedSize(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      vsync: this,
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                getEmployeeInfoRow(),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(width: 0, height: 0),
            )),
        Container(
            color: Colors.white.withOpacity(0.1),
            child: isOpen
                ? Divider(
                    color: Colors.white.withOpacity(0.4),
                  )
                : Divider(
                    color: Colors.white.withOpacity(0.8),
                  )),
        //
      ],
    );
  }

  Future<List<BusinessEmployeesGroups>> fetchEmployeesGroupsList(
      String search, bool init, GlobalStateModel globalStateModel) async {
    EmployeesApi api = EmployeesApi();

//    employeeCurrentGroups = [];
//    for (var group in widget.employee.groups) {
//      employeeCurrentGroups.add(group.id);
//    }

    var businessEmployeesGroups = await api
        .getBusinessEmployeesGroupsList(globalStateModel.currentBusiness.id,
            GlobalUtils.activeToken.accessToken, context)
        .then((businessEmployeesGroupsData) {
      print(
          "businessEmployeesGroupsData data loaded: $businessEmployeesGroupsData");

      employeesGroupsList = [];
      for (var group in businessEmployeesGroupsData) {
        print("group: $group");
        var groupData = BusinessEmployeesGroups.fromMap(group);
        if (!widget.employeeCurrentGroups.contains(groupData.id)) {
          employeesGroupsList.add(groupData);
        }
      }

      return employeesGroupsList;
    }).catchError((onError) {
      print("Error loading employees groups: $onError");

      if (onError.toString().contains("401")) {
        GlobalUtils.clearCredentials();
        Navigator.pushReplacement(
            context,
            PageTransition(
                child: LoginScreen(), type: PageTransitionType.fade));
      }
    });

    return businessEmployeesGroups;
  }

//  Future<void> _addEmployeeToGroup(EmployeesStateModel employeesStateModel,
//      BusinessEmployeesGroups group) async {
//    return employeesStateModel.addEmployeeToGroup(group.id, widget.employee.id);
//  }
//
//  Future<void> _deleteEmployeeFromGroup(
//      EmployeesStateModel employeesStateModel, String groupId) async {
//    return employeesStateModel.deleteEmployeeFromGroup(
//        groupId, widget.employee.id);
//  }

}
