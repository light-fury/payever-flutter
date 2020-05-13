import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../../commons/views/custom_elements/custom_elements.dart';
import '../../view_models/view_models.dart';
import '../../network/network.dart';
import '../../utils/utils.dart';
import 'add_employee_screen.dart';
import 'employees_groups_list_tab_screen.dart';
import 'employees_list_tab_screen.dart';
import 'add_group_screen.dart';

bool _isPortrait;
bool _isTablet;

class EmployeesScreen extends StatefulWidget {
  @override
  createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  GlobalStateModel globalStateModel;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2);
    tabController.addListener(_handleTabSelection);
  }

  _handleTabSelection() {
    setState(() {
      _currentIndex = tabController.index;
    });
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

    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return BackgroundBase(true,
            appBar: CustomAppBar(
              title: Text("Employees"),
              onTap: () {
                Navigator.pop(context);
              },
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (tabController.index == 0) {
                      Navigator.push(
                          context,
                          PageTransition(
                            child: ProxyProvider<EmployeesApi,
                                EmployeesStateModel>(
                              builder: (context, api, employeesState) =>
                                  EmployeesStateModel(globalStateModel, api),
                              child: AddEmployeeScreen(),
                            ),
                            type: PageTransitionType.fade,
                          ));
                    } else {
                      Navigator.push(
                          context,
                          PageTransition(
                            child: ProxyProvider<EmployeesApi,
                                EmployeesStateModel>(
                              builder: (context, api, employeesState) =>
                                  EmployeesStateModel(globalStateModel, api),
                              child: AddGroupScreen(),
                            ),
                            type: PageTransitionType.fade,
                          ));
                    }
                  },
                ),
              ],
            ),
            body: ListView(
//                        physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                Center(
                  child: Container(
                    decoration: BoxDecoration(
//                                color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    width: Measurements.width * 0.8,
                    child: TabBar(
                      controller: tabController,
                      indicatorColor: Colors.white.withOpacity(0),
                      labelColor: Colors.white,
                      labelPadding: EdgeInsets.all(2),
                      unselectedLabelColor: Colors.white,
                      isScrollable: false,
                      tabs: <Widget>[
                        Container(
                          child: Tab(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  color: _currentIndex == 0
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(20))),
                              child: Center(
                                child: Text(
                                  'Employees',
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: Tab(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  color: _currentIndex == 1
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(20),
                                      bottomRight: Radius.circular(20))),
                              child: Center(
                                child: Text(
                                  'Groups',
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height - 2,
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: tabController,
                    children: <Widget>[
//                                EmployeesListTabScreen(),
                      ProxyProvider<EmployeesApi, EmployeesStateModel>(
                        builder: (context, api, employeesState) =>
                            EmployeesStateModel(globalStateModel, api),
                        child: EmployeesListTabScreen(),
                      ),
//                                EmployeesGroupsListTabScreen(),
                      ProxyProvider<EmployeesApi, EmployeesStateModel>(
                        builder: (context, api, employeesState) =>
                            EmployeesStateModel(globalStateModel, api),
                        child: EmployeesGroupsListTabScreen(),
                      )
                    ],
                  ),
                ),
              ],
            ));
      },
    );
  }
}
