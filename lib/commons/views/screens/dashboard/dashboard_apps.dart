import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../../view_models/view_models.dart';
import '../../../models/models.dart';
import '../../../network/network.dart';
import '../../../utils/utils.dart';


import '../../../../transactions/views/views.dart';
import '../../../../products/views/views.dart';
import '../../../../pos/view_models/pos_state_model.dart';
import '../../../../pos/network/network.dart';
import '../../../../pos/views/views.dart';
import '../../../../settings/views/employees/employees.dart';

bool _isTablet;

class DashboardApps extends StatefulWidget {
  @override
  createState() => _DashboardAppsState();
}

class _DashboardAppsState extends State<DashboardApps> {
  DashboardStateModel dashboardStateModel;

  List<String> _availableApps = ["transactions", "pos", "products"];

  @override
  Widget build(BuildContext context) {
    _isTablet = MediaQuery.of(context).orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width > 600
        : MediaQuery.of(context).size.height > 600;
    List<Widget> _apps = List();
    dashboardStateModel = Provider.of<DashboardStateModel>(context);
    dashboardStateModel.currentWidgets.forEach((wid) {
      // if(widget._availableApps.contains(wid.type) && wid.type != "settings")
      if (_availableApps.contains(wid.type)) _apps.add(AppView(wid));
    });
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 25),
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.spaceEvenly,
              runSpacing: Measurements.height * 0.04,
              spacing: Measurements.width * 0.05,
              children: _apps,
            ),
          ],
        ),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  final AppWidget _currentApp;

  AppView(this._currentApp);

  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  bool _isLoading = false;
  GlobalStateModel globalStateModel;
  String uiKit = Env.commerceOs + "/assets/ui-kit/icons-png/";
  DashboardStateModel dashboardStateModel;

  @override
  Widget build(BuildContext context) {
    print(_isLoading);
    globalStateModel = Provider.of<GlobalStateModel>(context);
    dashboardStateModel = Provider.of<DashboardStateModel>(context);
    return Column(
      children: <Widget>[
        InkWell(
          borderRadius: BorderRadius.circular(15),
          highlightColor: Colors.black.withOpacity(0.3),
          child: Column(
            children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white.withOpacity(0.15),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Container(
                    width: 30,
                    height: 30,
                    child: CachedNetworkImage(
                      imageUrl: uiKit + widget._currentApp.icon,
                    ),
                  )),
            ],
          ),
          onTap: () {
            setState(() {
              _isLoading = true;
            });
            switch (widget._currentApp.type) {
              case "transactions":
                loadTransactions(context).then((_) {});
                break;
              case "pos":
                loadPOS().then((_) {
                  setState(() {
                    _isLoading = false;
                  });
                });
                break;
              case "products":
                loadProducts();
                setState(() {
                  _isLoading = false;
                });
                break;
//              case "settings":
//                loadSettings();
//                setState(() {
//                  _isLoading = false;
//                });
//                print("Settings loaded");
//                break;
              default:
            }
          },
        ),
        Padding(
          padding: EdgeInsets.only(
              bottom: Measurements.width * (_isTablet ? 0.01 : 0.01)),
        ),
        Text(
          Language.getWidgetStrings("widgets.${widget._currentApp.type}.title"),
          style: TextStyle(fontSize: _isTablet ? 13 : 12),
        ),
      ],
    );
  }

  Future<void> loadTransactions(BuildContext context) {
    setState(() {
      _isLoading = false;
    });
    return Navigator.push(
        context,
        PageTransition(
            child: TransactionScreenInit(),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 300)));
  }

  void loadProducts() {
    Navigator.push(
        context,
        PageTransition(
            child: ProductScreen(
              business: globalStateModel.currentBusiness,
              wallpaper: globalStateModel.currentWallpaper,
              posCall: false,
            ),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 50)));
  }

  Future<void> loadPOS() {
    setState(() {
      _isLoading = false;
    });
//    return Navigator.push(
//        context,
//        PageTransition(
//            child: NativePosScreen(
//                terminal: dashboardStateModel.activeTerminal,
//                business: globalStateModel.currentBusiness),
//            type: PageTransitionType.fade,duration: Duration(milliseconds: 50)));


    return Navigator.push(
        context,
        PageTransition(
            child: ChangeNotifierProvider<PosStateModel>(
              builder: (BuildContext context) =>
                  PosStateModel(globalStateModel, PosApi()),
              child: PosProductsListScreen(
                  terminal: dashboardStateModel.activeTerminal,
                  business: globalStateModel.currentBusiness),
            ),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 50)));
  }

  void loadSettings() {
    setState(() {
      _isLoading = false;
    });

    Navigator.push(
        context,
        PageTransition(
//          child: SettingsScreen(),
          child: EmployeesScreen(),
          type: PageTransitionType.fade,
        ));
  }
}
