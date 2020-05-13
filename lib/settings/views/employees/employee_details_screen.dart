import 'dart:ui';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../../commons/views/custom_elements/custom_elements.dart';
import '../../../commons/views/screens/login/login.dart';
import '../../view_models/view_models.dart';
import '../../network/network.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import 'custom_apps_access_expansion_tile.dart';

bool _isPortrait;
bool _isTablet;

class EmployeeDetailsScreen extends StatefulWidget {
  final Employees employee;

  EmployeeDetailsScreen(this.employee);

  @override
  createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  var openedRow = ValueNotifier(0);

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  Future<List<dynamic>> fetchAppsAccessOptions(
      GlobalStateModel globalStateModel, String userId) async {
    List<dynamic> appsAccessOptionsList = List<dynamic>();

    return appsAccessOptionsList;
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

    EmployeesStateModel employeesStateModel =
        Provider.of<EmployeesStateModel>(context);

    employeesStateModel.changeFirstName(widget.employee.firstName);
    employeesStateModel.changeLastName(widget.employee.lastName);
    employeesStateModel.changeEmail(widget.employee.email);
    employeesStateModel.changePosition(widget.employee.position);

    return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
      _isPortrait = Orientation.portrait == MediaQuery.of(context).orientation;
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
          title: Text("Employee Details"),
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
                      'Save',
                      style: TextStyle(
                          color: snapshot.hasData
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          fontSize: 18),
                    ),
                    onPressed: () {
                      if (snapshot.hasData) {
                        print("Data can be send");
                        _updateEmployee(
                            globalStateModel, employeesStateModel, context);
                      } else {
                        print("The data can't be send");
                      }
                    },
                  );
                }),
          ],
        ),
        body: CustomFutureBuilder(
          future: fetchAppsAccessOptions(globalStateModel, widget.employee.id),
          errorMessage: "Error loading employee details",
          onDataLoaded: (results) {
            return SafeArea(
              child: Form(
                key: _formKey,
                child: CustomFutureBuilder<List<BusinessApps>>(
                  future: getBusinessApps(employeesStateModel),
                  errorMessage: "Error loading apps.",
                  onDataLoaded: (List results) {
                    return Column(
                      children: <Widget>[
                        Flexible(
                          child: CustomExpansionTile(
                            isWithCustomIcon: false,
                            listSize: widget.employee.status == 0 ? 1 : null,
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
                              widget.employee.status != 0
                                  ? Container(
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
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                              ],
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    Measurements.width * 0.05),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                            ],
                            widgetsBodyList: <Widget>[
                              EmployeeInfoRowDetails(
                                openedRow: openedRow,
                                employee: widget.employee,
                                employeesStateModel: employeesStateModel,
                              ),
                              widget.employee.status != 0
                                  ? CustomAppsAccessExpansionTile(
                                      employeesStateModel: employeesStateModel,
                                      businessApps: results,
                                      isNewEmployeeOrGroup: false,
                                    )
                                  : Container(),
                            ],
                          ),
                        ),

//                                    InkWell(
//                                      child: Container(
//                                        color: Colors.white.withOpacity(0.4),
//                                        width: _isPortrait
//                                            ? Measurements.width * 0.99
//                                            : double.infinity,
//                                        height: Measurements.height *
//                                            (_isTablet ? 0.05 : 0.07),
//                                        child: Center(
//                                            child: Text(
//                                              "Delete Employee",
//                                              style: TextStyle(
//                                                  color: Colors.white,
//                                                  fontSize: 19),
//                                            )),
//                                      ),
//                                      onTap: () {
//                                        _deleteEmployeeConfirmation(
//                                            context, employeesStateModel);
//                                      },
//                                    ),
                      ],
                    );

//                                        return EmployeesAppsAccessComponent(
//                                          openedRow: openedRow,
//                                          businessAppsData: results,
//                                          isNewEmployeeOrGroup: false,
//                                        );

//                                        return AppsAccessRow(
//                                          openedRow: openedAppsAccessRow,
////                                        employee: widget.employee,
////                                        employeeGroups: snapshot.data,
//                                          businessAppsData: results,
//                                        );
                  },
                ),
              ),
            );
          },
        ),
      );
    });
  }

  void _updateEmployee(GlobalStateModel globalStateModel,
      EmployeesStateModel employeesStateModel, BuildContext context) async {
    var data = {
      "email": employeesStateModel.emailValue,
      "first_name": employeesStateModel.firstNameValue,
      "last_name": employeesStateModel.lastNameValue,
      "position": employeesStateModel.positionValue
    };

    print("Data: $data");

    for (var app in employeesStateModel.businessApps) {
      print("app.allowedAcls.create: ${app.allowedAcls.create}" +
          " " +
          "app.allowedAcls.read: ${app.allowedAcls.read}" +
          " " +
          "app.allowedAcls.update: ${app.allowedAcls.update}" +
          " " +
          "app.allowedAcls.delete: ${app.allowedAcls.delete}");
    }

//    employeesStateModel.clearEmployeeData();

    //await employeesStateModel.updateEmployee(data, widget.employee.id);
    //Navigator.of(context).pop();
  }
}

class EmployeeInfoRowDetails extends StatefulWidget {
  final ValueNotifier openedRow;
  final Employees employee;

//  final dynamic employeeGroups;
  final EmployeesStateModel employeesStateModel;

  EmployeeInfoRowDetails(
      {this.openedRow,
      this.employee,
//      this.employeeGroups,
      this.employeesStateModel});

  @override
  createState() => _EmployeeInfoRowDetailsState();
}

class _EmployeeInfoRowDetailsState extends State<EmployeeInfoRowDetails>
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
  List<String> employeeCurrentGroups = List<String>();

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
    _firstNameController.text = widget.employee.firstName;
    _lastNameController.text = widget.employee.lastName;
    _emailController.text = widget.employee.email;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> fetchAppsAccessOptions(
      GlobalStateModel globalStateModel, String userId) async {
    List<dynamic> appsAccessOptionsList = List<dynamic>();

    return appsAccessOptionsList;
  }

  Future<List<BusinessEmployeesGroups>> fetchEmployeesGroupsList(
      String search, bool init, GlobalStateModel globalStateModel) async {
    EmployeesApi api = EmployeesApi();

    employeeCurrentGroups = [];
    for (var group in widget.employee.groups) {
      employeeCurrentGroups.add(group.id);
    }

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
        if (!employeeCurrentGroups.contains(groupData.id)) {
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

  @override
  Widget build(BuildContext context) {
    GlobalStateModel globalStateModel = Provider.of<GlobalStateModel>(context);

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

    print("_isPortrait: $_isPortrait");
    print("_isTablet: $_isTablet");

    Widget getEmployeeInfoRow() {
      return Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: Measurements.width * 0.020),
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
                    stream: widget.employeesStateModel.firstName,
                    builder: (context, snapshot) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Measurements.width * 0.025),
                        alignment: Alignment.center,
//                      color: Colors.white.withOpacity(0.05),
                        width: _isPortrait
                            ? Measurements.width * 0.475
//                            : MediaQuery.of(context).size.width * 0.326,
                            : MediaQuery.of(context).size.width * 0.436,
//                        height: Measurements.height * (_isTablet ? 0.08 : 0.07),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
//                            border: Border.all(
////                                color: snapshot.hasData
//                                color: snapshot.hasError
//                                    ? Colors.red
//                                    : Colors.transparent,
//                                width: 2)
                        ),
                        child: TextField(
//                          controller: TextEditingController()..text = 'Your initial value',
                          controller: _firstNameController,
                          style:
                              TextStyle(fontSize: Measurements.height * 0.02),
                          onChanged: widget.employeesStateModel.changeFirstName,
                          decoration: InputDecoration(
                            hintText: "First Name",
                            hintStyle: TextStyle(
//                              color: snapshot.hasData
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
//                Container(
//                  padding: EdgeInsets.symmetric(
//                      horizontal: Measurements.width * 0.025),
//                  alignment: Alignment.center,
//                  color: Colors.white.withOpacity(0.05),
//                  width: Measurements.width * 0.475,
//                  height: Measurements.height * (_isTablet ? 0.05 : 0.07),
//                  child: TextFormField(
//                    style: TextStyle(fontSize: Measurements.height * 0.02),
//                    initialValue: widget.employee.firstName,
////                    initialValue: widget.parts.editMode?widget.parts.product.price.toString():"",
////                    inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
//                    decoration: InputDecoration(
////                      hintText: Language.getProductStrings("price.placeholders.price"),
//                      hintText: "First Name",
////                      hintStyle: TextStyle(
////                          color: widget.priceError
////                              ? Colors.red
////                              : Colors.white.withOpacity(0.5)),
//                      labelText: "First Name",
//                      labelStyle: TextStyle(
//                        color: Colors.grey,
//                      ),
//                      border: InputBorder.none,
//                    ),
////                    keyboardType: TextInputType.number,
//                    onSaved: (firstName) {
////                      widget.parts.product.price = num.parse(price);
//                    },
////                    validator: (value) {
////
////                    },
//                  ),
//                ),
                StreamBuilder(
                    stream: widget.employeesStateModel.lastName,
                    builder: (context, snapshot) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Measurements.width * 0.025),
                        alignment: Alignment.center,
//                      color: Colors.white.withOpacity(0.05),
                        width: _isPortrait
                            ? Measurements.width * 0.475
//                            : MediaQuery.of(context).size.width * 0.326,
                            : MediaQuery.of(context).size.width * 0.436,
//                        height: Measurements.height * (_isTablet ? 0.08 : 0.07),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
//                            border: Border.all(
////                                color: snapshot.hasData
//                                color: snapshot.hasError
//                                    ? Colors.red
//                                    : Colors.transparent,
//                                width: 2)
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
                    }),

//                Container(
//                  padding: EdgeInsets.symmetric(
//                      horizontal: Measurements.width * 0.025),
//                  alignment: Alignment.center,
//                  color: Colors.white.withOpacity(0.05),
//                  width: Measurements.width * 0.475,
//                  height: Measurements.height * (_isTablet ? 0.05 : 0.07),
//                  child: TextFormField(
//                    style: TextStyle(fontSize: Measurements.height * 0.02),
//                    initialValue: widget.employee.lastName,
//                    decoration: InputDecoration(
//                        hintText: "Last Name",
//                        border: InputBorder.none,
//                        labelText: "Last Name",
//                        labelStyle: TextStyle(
//                          color: Colors.grey,
//                        )),
//                    onSaved: (lastName) {},
////                    validator: (value) {
////                    },
//                  ),
//                )
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
//                      color: Colors.white.withOpacity(0.05),
                        width: _isPortrait
                            ? Measurements.width * 0.475
//                            : MediaQuery.of(context).size.width * 0.326,
                            : MediaQuery.of(context).size.width * 0.436,
//                        height: Measurements.height * (_isTablet ? 0.08 : 0.07),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
//                            border: Border.all(
//                                color: snapshot.hasData
//                                    ? Colors.transparent
//                                    : Colors.red,
//                                width: 2)
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
//                Container(
//                  padding: EdgeInsets.symmetric(
//                      horizontal: Measurements.width * 0.025),
//                  alignment: Alignment.center,
//                  color: Colors.white.withOpacity(0.05),
//                  width: Measurements.width * 0.475,
//                  height: Measurements.height * (_isTablet ? 0.05 : 0.07),
//                  child: TextFormField(
//                    style: TextStyle(fontSize: Measurements.height * 0.02),
//                    initialValue: widget.employee.email,
////                    initialValue: widget.parts.editMode?widget.parts.product.price.toString():"",
////                    inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
//                    decoration: InputDecoration(
////                      hintText: Language.getProductStrings("price.placeholders.price"),
//                      hintText: "Email",
////                      hintStyle: TextStyle(
////                          color: widget.priceError
////                              ? Colors.red
////                              : Colors.white.withOpacity(0.5)),
//                      labelText: "Email",
//                      labelStyle: TextStyle(
//                        color: Colors.grey,
//                      ),
//                      border: InputBorder.none,
//                    ),
////                    keyboardType: TextInputType.number,
//                    onSaved: (email) {
////                      widget.parts.product.price = num.parse(price);
//                    },
////                    validator: (value) {
////
////                    },
//                  ),
//                ),
                StreamBuilder(
                    stream: widget.employeesStateModel.position,
                    builder: (context, snapshot) {
                      return Container(
//                  padding: EdgeInsets.symmetric(
//                      horizontal: Measurements.width * 0.025),
//                  alignment: Alignment.center,
                        color: Colors.white.withOpacity(0.05),
                        width: _isPortrait
                            ? Measurements.width * 0.475
//                            : MediaQuery.of(context).size.width * 0.326,
                            : MediaQuery.of(context).size.width * 0.436,
//                        height: Measurements.height * (_isTablet ? 0.08 : 0.07),
//                  child: TextFormField(
//                    style: TextStyle(fontSize: Measurements.height * 0.02),
//                    initialValue: widget.employee.position[0].positionType,
//                    decoration: InputDecoration(
//                        hintText: "Position",
//                        border: InputBorder.none,
//                        labelText: "Position",
//                        labelStyle: TextStyle(
//                          color: Colors.grey,
//                        )),
//                    onSaved: (position) {},
////                    validator: (value) {
////                    },
//                  ),

                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: snapshot.hasError
                                      ? Colors.red
                                      : Colors.transparent,
                                  width: 1)),
                          child: DropDownMenu(
                            optionsList: GlobalUtils.positionsListOptions(),
                            defaultValue: widget.employee.position,
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
//                Container(
////                  padding: EdgeInsets.symmetric(
////                      horizontal: Measurements.width * 0.025),
////                  alignment: Alignment.center,
//                  color: Colors.white.withOpacity(0.05),
//                  width: Measurements.width * 0.475,
//                  height: Measurements.height * (_isTablet ? 0.05 : 0.07),
////                  child: TextFormField(
////                    style: TextStyle(fontSize: Measurements.height * 0.02),
////                    initialValue: widget.employee.position[0].positionType,
////                    decoration: InputDecoration(
////                        hintText: "Position",
////                        border: InputBorder.none,
////                        labelText: "Position",
////                        labelStyle: TextStyle(
////                          color: Colors.grey,
////                        )),
////                    onSaved: (position) {},
//////                    validator: (value) {
//////                    },
////                  ),
//
//                  child: SizedBox(
//                    width: double.infinity,
//                    child: DropDownMenu(
//                      optionsList: <String>[
//                        "Cashier",
//                        "Sales",
//                        "Marketing",
//                        "Staff",
//                        "Admin",
//                        "Others",
//                      ],
//                      defaultValue: widget.employee.position,
//                      placeHolderText: "Position",
//                      onChangeSelection: (selectedOption, index) {
//                        print("selectedOption: $selectedOption");
//                        print("index: $index");
//                      },
//                    ),
//                  ),
//                )
              ],
            ),
          ),
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
                              itemCount: widget.employee.groups.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Chip(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.09),
                                    label: Text(
                                        widget.employee.groups[index].name),
                                    deleteIcon: Icon(
                                      IconData(58829,
                                          fontFamily: 'MaterialIcons'),
                                      size: 20,
                                    ),
                                    onDeleted: () {
                                      print("chip pressed");
                                      setState(() {
                                        _deleteEmployeeFromGroup(
                                            employeesStateModel,
                                            widget.employee.groups[index].id);
                                        widget.employee.groups.remove(
                                            widget.employee.groups[index]);
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
//                                                  Measurements.width * 0.025),
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
                          widget.employee.groups.add(EmployeeGroup.fromMap(
                              {"name": item.name, "_id": item.id}));
                          _addEmployeeToGroup(employeesStateModel, item);
                        });
                      },
                      key: acKey,
                      suggestions: employeesGroupsList,
                      itemBuilder: (context, suggestion) => Padding(
                          child: ListTile(
                            title: Text(suggestion.name),
//                              trailing: Text("Groups: ${suggestion.name}")
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
//          Padding(
//            padding: EdgeInsets.only(top: Measurements.width * 0.020),
//          ),
//          InkWell(
//            child: Container(
//              color: Colors.white.withOpacity(0.1),
//              width: Measurements.width * 0.99,
//              height: Measurements.height * (_isTablet ? 0.05 : 0.07),
//              child: Center(
//                  child: Text(
//                "Delete Employee",
//                style: TextStyle(color: Colors.white, fontSize: 19),
//              )),
//            ),
//            onTap: () {},
//          ),
          Padding(
            padding: EdgeInsets.only(top: Measurements.width * 0.01),
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
////                  child: Text(Language.getProductStrings("sections.main")),
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
//            height: widget.isOpen ? Measurements.height * 0.62 : 0,
            duration: Duration(milliseconds: 200),
            child: Container(
              width: _isPortrait ? Measurements.width : double.infinity,
              child: isOpen
                  ? AnimatedSize(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      vsync: this,
                      child: Container(
//                        padding: EdgeInsets.symmetric(
//                            horizontal: Measurements.width * 0.025),
                        color: Colors.black.withOpacity(0.3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
//                                Container(
//                                  height: Measurements.height * 0.3,
//                                  child: getEmployeeInfoRow(),
//                                ),
                                getEmployeeInfoRow(),
//                    Column(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: <Widget>[
//                      ],
//                    )
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(width: 0, height: 0),
            )),
        //--
        Container(
            color: Colors.white.withOpacity(0.1),
            child: isOpen
                ? Divider(
                    color: Colors.white.withOpacity(0),
                  )
                : Divider(
                    color: Colors.white,
                  )),
        //
      ],
    );
  }

  Future<void> _addEmployeeToGroup(EmployeesStateModel employeesStateModel,
      BusinessEmployeesGroups group) async {
    return employeesStateModel.addEmployeesToGroup(
        group.id, widget.employee.id);
  }

  Future<void> _deleteEmployeeFromGroup(
      EmployeesStateModel employeesStateModel, String groupId) async {
    var data = {
      "employees": [widget.employee.id]
    };

    return employeesStateModel.deleteEmployeesFromGroup(groupId, data);
  }
}

//class AppsAccessRow extends StatefulWidget {
//  final ValueNotifier openedRow;
//  final List<BusinessApps> businessAppsData;
//
////  final Employees employee;
////  final dynamic employeeGroups;
//
//  AppsAccessRow({this.openedRow, this.businessAppsData});
//
////  AppsAccessRow({this.openedRow, this.employee, this.employeeGroups});
//
//  @override
//  createState() => _AppsAccessRowState();
//}

//class _AppsAccessRowState extends State<AppsAccessRow>
//    with TickerProviderStateMixin {
//  bool isOpen = true;
//
//  bool _isPortrait;
//  bool _isTablet;
//
//  var appPermissionsRow = ValueNotifier(0);
//
//  static String uiKit = Env.Commerceos + "/assets/ui-kit/icons-png/";
//
//  listener() {
//    setState(() {
//      if (widget.openedRow.value == 0) {
//        isOpen = !isOpen;
//      } else {
//        isOpen = false;
//      }
//    });
//  }
//
//  @override
//  void initState() {
//    super.initState();
//    widget.openedRow.addListener(listener);
//  }
//
//  @override
//  Widget build(BuildContext context) {
////    GlobalStateModel globalStateModel = Provider.of<GlobalStateModel>(context);
//    EmployeesStateModel employeesStateModel =
//        Provider.of<EmployeesStateModel>(context);
//
//    _isPortrait = Orientation.portrait == MediaQuery.of(context).orientation;
//    Measurements.height = (_isPortrait
//        ? MediaQuery.of(context).size.height
//        : MediaQuery.of(context).size.width);
//    Measurements.width = (_isPortrait
//        ? MediaQuery.of(context).size.width
//        : MediaQuery.of(context).size.height);
//    _isTablet = Measurements.width < 600 ? false : true;
//
//    print("_isPortrait: $_isPortrait");
//    print("_isTablet: $_isTablet");
//
//    Widget getAppsAccessRow() {
//      return ListView.builder(
//        padding: EdgeInsets.all(0.1),
//        shrinkWrap: true,
//        physics: ClampingScrollPhysics(),
////        itemCount: widget.businessAppsData.length,
//        itemCount: employeesStateModel.businessApps.length,
//        itemBuilder: (BuildContext context, int index) {
//          var appIndex = widget.businessAppsData[index];
//          return ExpandableListView(
//            iconData: NetworkImage(uiKit + appIndex.dashboardInfo.icon),
//            title: Language.getCommerceOSStrings(appIndex.dashboardInfo.title),
//            isExpanded: false,
//            widgetList: Container(
//              child: Padding(
//                padding: EdgeInsets.symmetric(
//                    horizontal: Measurements.width * 0.020),
//                child: Column(
//                  children: <Widget>[
//                    appIndex.allowedAcls.create != null
//                        ? Divider()
//                        : Container(width: 0, height: 0),
//                    appIndex.allowedAcls.create != null
//                        ? Row(
//                            mainAxisSize: MainAxisSize.max,
//                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                            children: <Widget>[
//                              Text(
//                                "Create",
//                                style: TextStyle(
//                                    color: Colors.white,
//                                    fontSize: 20,
//                                    fontWeight: FontWeight.normal),
//                              ),
//                              Switch(
//                                activeColor: Color(0XFF0084ff),
//                                value: employeesStateModel
//                                    .businessApps[index].allowedAcls.create,
//                                onChanged: (bool value) {
//                                  setState(() {
//                                    employeesStateModel
//                                        .updateBusinessAppPermissionCreate(
//                                            index, value);
//                                    employeesStateModel
//                                        .updateBusinessAppPermissionRead(
//                                            index, value);
//                                    employeesStateModel
//                                        .updateBusinessAppPermissionUpdate(
//                                            index, value);
//                                    employeesStateModel
//                                        .updateBusinessAppPermissionDelete(
//                                            index, value);
//                                  });
//                                },
//                              )
//                            ],
//                          )
//                        : Container(width: 0, height: 0),
//                    appIndex.allowedAcls.read != null
//                        ? Divider()
//                        : Container(width: 0, height: 0),
//                    appIndex.allowedAcls.read != null
//                        ? Row(
//                            mainAxisSize: MainAxisSize.max,
//                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                            children: <Widget>[
//                              Text(
//                                "Read",
//                                style: TextStyle(
//                                    color: Colors.white,
//                                    fontSize: 20,
//                                    fontWeight: FontWeight.normal),
//                              ),
//                              Switch(
//                                activeColor: Color(0XFF0084ff),
////                                value: appIndex.allowedAcls.read,
//                                value: employeesStateModel
//                                    .businessApps[index].allowedAcls.read,
//                                onChanged: (bool value) {
//                                  setState(() {
//                                    employeesStateModel
//                                        .updateBusinessAppPermissionRead(
//                                            index, value);
//                                    if (employeesStateModel.businessApps[index]
//                                            .allowedAcls.create ==
//                                        true) {
//                                      employeesStateModel
//                                          .updateBusinessAppPermissionCreate(
//                                              index, value);
//                                    }
//                                    if (employeesStateModel.businessApps[index]
//                                            .allowedAcls.update ==
//                                        true) {
//                                      employeesStateModel
//                                          .updateBusinessAppPermissionUpdate(
//                                              index, value);
//                                    }
//                                    if (employeesStateModel.businessApps[index]
//                                            .allowedAcls.delete ==
//                                        true) {
//                                      employeesStateModel
//                                          .updateBusinessAppPermissionDelete(
//                                              index, value);
//                                    }
//                                  });
//                                },
//                              )
//                            ],
//                          )
//                        : Container(width: 0, height: 0),
//                    appIndex.allowedAcls.update != null
//                        ? Divider()
//                        : Container(width: 0, height: 0),
//                    appIndex.allowedAcls.update != null
//                        ? Row(
//                            mainAxisSize: MainAxisSize.max,
//                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                            children: <Widget>[
//                              Text(
//                                "Update",
//                                style: TextStyle(
//                                    color: Colors.white,
//                                    fontSize: 20,
//                                    fontWeight: FontWeight.normal),
//                              ),
//                              Switch(
//                                activeColor: Color(0XFF0084ff),
////                                value: appIndex.allowedAcls.update,
//                                value: employeesStateModel
//                                    .businessApps[index].allowedAcls.update,
//                                onChanged: (bool value) {
//                                  setState(() {
//                                    if (employeesStateModel.businessApps[index]
//                                            .allowedAcls.read ==
//                                        false) {
//                                      print("read not selected");
//                                    } else {
//                                      employeesStateModel
//                                          .updateBusinessAppPermissionUpdate(
//                                              index, value);
//                                    }
//
////                                    if (employeesStateModel.businessApps[index]
////                                            .allowedAcls.read ==
////                                        true) {
////                                      employeesStateModel
////                                          .updateBusinessAppPermissionRead(
////                                              index, value);
////                                    }
//                                  });
//                                },
//                              )
//                            ],
//                          )
//                        : Container(width: 0, height: 0),
//                    appIndex.allowedAcls.delete != null
//                        ? Divider()
//                        : Container(width: 0, height: 0),
//                    appIndex.allowedAcls.delete != null
//                        ? Row(
//                            mainAxisSize: MainAxisSize.max,
//                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                            children: <Widget>[
//                              Text(
//                                "Delete",
//                                style: TextStyle(
//                                    color: Colors.white,
//                                    fontSize: 20,
//                                    fontWeight: FontWeight.normal),
//                              ),
//                              Switch(
//                                activeColor: Color(0XFF0084ff),
////                                value: appIndex.allowedAcls.delete,
//                                value: employeesStateModel
//                                    .businessApps[index].allowedAcls.delete,
//                                onChanged: (bool value) {
//                                  setState(() {
//                                    if (employeesStateModel.businessApps[index]
//                                            .allowedAcls.read ==
//                                        false) {
//                                      print("read not selected");
//                                    } else {
//                                      employeesStateModel
//                                          .updateBusinessAppPermissionDelete(
//                                              index, value);
//                                    }
////                                    if (employeesStateModel.businessApps[index]
////                                            .allowedAcls.read ==
////                                        true) {
////                                      employeesStateModel
////                                          .updateBusinessAppPermissionRead(
////                                              index, value);
////                                    }
//                                  });
//                                },
//                              )
//                            ],
//                          )
//                        : Container(width: 0, height: 0),
//                    Divider(),
//                  ],
//                ),
//              ),
//            ),
//          );
//        },
//      );
//    }
//
//    return Column(
//      children: <Widget>[
//        Container(
//          decoration: BoxDecoration(
//            color: Colors.white.withOpacity(0.1),
//          ),
//          child: InkWell(
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              children: <Widget>[
//                Container(
////                  child: Text(Language.getProductStrings("sections.main")),
//                  child: Row(
//                    children: <Widget>[
//                      Icon(
//                        Icons.business_center,
//                        size: 28,
//                      ),
//                      SizedBox(width: 10),
//                      Text(
//                        "Apps Access",
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
//        AnimatedContainer(
//            color: Colors.white.withOpacity(0.05),
////            height: widget.isOpen ? Measurements.height * 0.62 : 0,
//            duration: Duration(milliseconds: 200),
//            child: Container(
//              width: _isPortrait ? Measurements.width : double.infinity,
//              child: isOpen
//                  ? AnimatedSize(
//                      duration: Duration(milliseconds: 500),
//                      curve: Curves.easeInOut,
//                      vsync: this,
//                      child: Container(
//                        padding: EdgeInsets.symmetric(
//                            horizontal: Measurements.width * 0.0015),
//                        color: Colors.black.withOpacity(0.05),
//                        child: getAppsAccessRow(),
////                        child: Column(
////                          mainAxisAlignment: MainAxisAlignment.center,
////                          children: <Widget>[
////                            Row(
////                              mainAxisSize: MainAxisSize.max,
////                              mainAxisAlignment: MainAxisAlignment.center,
////                              children: <Widget>[
////                                Column(
////                                  children: <Widget>[
//////                                    Expanded(child: getAppsAccessRow()),
////                                    getAppsAccessRow(),
////                                    Padding(
////                                      padding: EdgeInsets.only(
////                                          top: Measurements.width * 0.020),
////                                    ),
////                                    InkWell(
////                                      child: Container(
////                                        color: Colors.white.withOpacity(0.1),
////                                        width: Measurements.width * 0.99,
////                                        height: Measurements.height *
////                                            (_isTablet ? 0.05 : 0.07),
////                                        child: Center(
////                                            child: Text(
////                                          "Save",
////                                          style: TextStyle(
////                                              color: Colors.white,
////                                              fontSize: 19),
////                                        )),
////                                      ),
////                                      onTap: () {},
////                                    ),
////                                    Padding(
////                                      padding: EdgeInsets.only(
////                                          top: Measurements.width * 0.01),
////                                    ),
////                                  ],
////                                ),
//////                                Container(
//////                                  height: Measurements.height * 0.3,
//////                                  child: getAppsAccessRow(),
//////                                ),
////                              ],
////                            )
////                          ],
////                        ),
//                      ),
//                    )
//                  : Container(width: 0, height: 0),
//            )),
////        Container(
////            color: isOpen
////                ? Colors.transparent
////                : Colors.white.withOpacity(0.1),
////            height: Measurements.height * 0.01,
////            child: isOpen
////                ? Divider(
////              color: Colors.white.withOpacity(0),
////            )
////                : Divider(
////              color: Colors.white,
////            )),
//      ],
//    );
//  }
//}

//class AppsAccessRow extends StatefulWidget {
//  ValueNotifier openedRow;
//  Employees employee;
//  dynamic employeeGroups;
//  bool isOpen = false;
//
//  AppsAccessRow({this.openedRow, this.employee, this.employeeGroups});
//
//  @override
//  createState() => _AppsAccessRowState();
//}
//
//class _AppsAccessRowState extends State<AppsAccessRow>
//    with TickerProviderStateMixin {
//  var appPermissionsRow = ValueNotifier(0);
//
//  listener() {
//    setState(() {
//      if (widget.openedRow.value == 0) {
//        widget.isOpen = !widget.isOpen;
//      } else {
//        widget.isOpen = false;
//      }
//    });
//  }
//
//  @override
//  void initState() {
//    super.initState();
//    widget.openedRow.addListener(listener);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    Widget getAppsAccessRow() {
//      return Container(
//        width: Measurements.width - 2,
////       height: 100,
//        child: ListView.builder(
//          padding: EdgeInsets.all(0.1),
//          shrinkWrap: true,
//          itemCount: widget.employee.roles.length,
//          itemBuilder: (BuildContext context, int index) {
//            if (index == 0) {
//              return Container();
//            } else {
//              return Column(
//                children: <Widget>[
////                  ExpandableListView(
////                    iconData: Icons.shopping_basket,
////                    title: widget
////                        .employee.roles[index].permission[0].acls[0].microService,
////                    isExpanded: true,
////                    widgetList: Center(child: Text("Hello"),),
////                  ),
//                  ExpandableListView(
////                    iconData: Icons.shopping_basket,
//                    title: widget.employee.roles[index].permission[0].acls[0]
//                        .microService,
//                    isExpanded: false,
//                    widgetList: Container(
//                      child: Padding(
//                        padding: EdgeInsets.symmetric(
//                            horizontal: Measurements.width * 0.020),
//                        child: Column(
//                          children: <Widget>[
//                            Divider(),
//                            Row(
//                              mainAxisSize: MainAxisSize.max,
//                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                              children: <Widget>[
//                                Text(
//                                  "Create",
//                                  style: TextStyle(
//                                      color: Colors.white,
//                                      fontSize: 22,
//                                      fontWeight: FontWeight.bold),
//                                ),
//                                Switch(
//                                  activeColor: Color(0XFF0084ff),
//                                  value: widget.employee.roles[index]
//                                      .permission[0].acls[0].create,
//                                  onChanged: (bool value) {
//                                    setState(() {});
//                                  },
//                                )
//                              ],
//                            ),
//                            Divider(),
//                            Row(
//                              mainAxisSize: MainAxisSize.max,
//                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                              children: <Widget>[
//                                Text(
//                                  "Read",
//                                  style: TextStyle(
//                                      color: Colors.white,
//                                      fontSize: 22,
//                                      fontWeight: FontWeight.bold),
//                                ),
//                                Switch(
//                                  activeColor: Color(0XFF0084ff),
//                                  value: widget.employee.roles[index]
//                                      .permission[0].acls[0].read,
//                                  onChanged: (bool value) {
//                                    setState(() {});
//                                  },
//                                )
//                              ],
//                            ),
//                            Divider(),
//                            Row(
//                              mainAxisSize: MainAxisSize.max,
//                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                              children: <Widget>[
//                                Text(
//                                  "Update",
//                                  style: TextStyle(
//                                      color: Colors.white,
//                                      fontSize: 22,
//                                      fontWeight: FontWeight.bold),
//                                ),
//                                Switch(
//                                  activeColor: Color(0XFF0084ff),
//                                  value: widget.employee.roles[index]
//                                      .permission[0].acls[0].update,
//                                  onChanged: (bool value) {
//                                    setState(() {});
//                                  },
//                                )
//                              ],
//                            ),
//                            Divider(),
//                            Row(
//                              mainAxisSize: MainAxisSize.max,
//                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                              children: <Widget>[
//                                Text(
//                                  "Delete",
//                                  style: TextStyle(
//                                      color: Colors.white,
//                                      fontSize: 22,
//                                      fontWeight: FontWeight.bold),
//                                ),
//                                Switch(
//                                  activeColor: Color(0XFF0084ff),
//                                  value: widget.employee.roles[index]
//                                      .permission[0].acls[0].delete,
//                                  onChanged: (bool value) {
//                                    setState(() {});
//                                  },
//                                )
//                              ],
//                            ),
//                          ],
//                        ),
//                      ),
//                    ),
//                  ),
//                ],
//              );
////              return ExpandableListView(
////                iconData: Icons.shopping_basket,
////                title: widget
////                    .employee.roles[index].permission[0].acls[0].microService,
////                isExpanded: false,
////                widgetList: Container(
////                  child: Padding(
////                    padding: EdgeInsets.symmetric(
////                        horizontal: Measurements.width * 0.020),
////                    child: Column(
////                      children: <Widget>[
////                        Divider(),
////                        Row(
////                          mainAxisSize: MainAxisSize.max,
////                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
////                          children: <Widget>[
////                            Text(
////                              "Create",
////                              style: TextStyle(
////                                  color: Colors.white,
////                                  fontSize: 22,
////                                  fontWeight: FontWeight.bold),
////                            ),
////                            Switch(
////                              activeColor: Color(0XFF0084ff),
////                              value: widget.employee.roles[index].permission[0]
////                                  .acls[0].create,
////                              onChanged: (bool value) {
////                                setState(() {
////
////                                });
////                              },
////                            )
////                          ],
////                        ),
////                        Divider(),
////                        Row(
////                          mainAxisSize: MainAxisSize.max,
////                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
////                          children: <Widget>[
////                            Text(
////                              "Read",
////                              style: TextStyle(
////                                  color: Colors.white,
////                                  fontSize: 22,
////                                  fontWeight: FontWeight.bold),
////                            ),
////                            Switch(
////                              activeColor: Color(0XFF0084ff),
////                              value: widget.employee.roles[index].permission[0]
////                                  .acls[0].read,
////                              onChanged: (bool value) {
////                                setState(() {});
////                              },
////                            )
////                          ],
////                        ),
////                        Divider(),
////                        Row(
////                          mainAxisSize: MainAxisSize.max,
////                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
////                          children: <Widget>[
////                            Text(
////                              "Update",
////                              style: TextStyle(
////                                  color: Colors.white,
////                                  fontSize: 22,
////                                  fontWeight: FontWeight.bold),
////                            ),
////                            Switch(
////                              activeColor: Color(0XFF0084ff),
////                              value: widget.employee.roles[index].permission[0]
////                                  .acls[0].update,
////                              onChanged: (bool value) {
////                                setState(() {});
////                              },
////                            )
////                          ],
////                        ),
////                        Divider(),
////                        Row(
////                          mainAxisSize: MainAxisSize.max,
////                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
////                          children: <Widget>[
////                            Text(
////                              "Delete",
////                              style: TextStyle(
////                                  color: Colors.white,
////                                  fontSize: 22,
////                                  fontWeight: FontWeight.bold),
////                            ),
////                            Switch(
////                              activeColor: Color(0XFF0084ff),
////                              value: widget.employee.roles[index].permission[0]
////                                  .acls[0].delete,
////                              onChanged: (bool value) {
////                                setState(() {});
////                              },
////                            )
////                          ],
////                        ),
////                      ],
////                    ),
////                  ),
////                ),
////              );
//            }
//          },
//        ),
//      );
//    }
//
//    return Column(
//      children: <Widget>[
//        Container(
//          decoration: BoxDecoration(
//            color: Colors.white.withOpacity(0.1),
//          ),
//          child: InkWell(
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              children: <Widget>[
//                Container(
////                  child: Text(Language.getProductStrings("sections.main")),
//                  child: Row(
//                    children: <Widget>[
//                      Icon(
//                        Icons.business_center,
//                        size: 28,
//                      ),
//                      SizedBox(width: 10),
//                      Text(
//                        "Apps Access",
//                        style: TextStyle(fontSize: 18),
//                      ),
//                    ],
//                  ),
//                  padding: EdgeInsets.symmetric(
//                      horizontal: Measurements.width * 0.05),
//                ),
//                IconButton(
//                  icon: Icon(widget.isOpen
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
//        AnimatedContainer(
//            color: Colors.white.withOpacity(0.05),
////            height: widget.isOpen ? Measurements.height * 0.62 : 0,
//            duration: Duration(milliseconds: 200),
//            child: Container(
//              width: Measurements.width * 0.999,
//              child: widget.isOpen
//                  ? AnimatedSize(
//                      duration: Duration(milliseconds: 500),
//                      curve: Curves.easeInOut,
//                      vsync: this,
//                      child: Container(
//                        padding: EdgeInsets.symmetric(
//                            horizontal: Measurements.width * 0.0015),
//                        color: Colors.black.withOpacity(0.05),
//                        child: Column(
//                          mainAxisAlignment: MainAxisAlignment.center,
//                          children: <Widget>[
//                            Row(
//                              mainAxisSize: MainAxisSize.max,
//                              mainAxisAlignment: MainAxisAlignment.center,
//                              children: <Widget>[
//                                Column(
//                                  children: <Widget>[
////                                    Expanded(child: getAppsAccessRow()),
//                                    getAppsAccessRow(),
//                                  ],
//                                ),
////                                Container(
////                                  height: Measurements.height * 0.3,
////                                  child: getAppsAccessRow(),
////                                ),
//                              ],
//                            )
//                          ],
//                        ),
//                      ),
//                    )
//                  : Container(width: 0, height: 0),
//            )),
//        Container(
//            color: widget.isOpen
//                ? Colors.transparent
//                : Colors.white.withOpacity(0.1),
//            height: widget.isOpen ? 0 : Measurements.height * 0.01,
//            child: widget.isOpen
//                ? Divider(
//                    color: Colors.white.withOpacity(0),
//                  )
//                : Divider(
//                    color: Colors.white,
//                  )),
//      ],
//    );
//  }
//}
