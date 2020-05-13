import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../utils/utils.dart';
import '../../../../settings/views/employees/employees.dart';
import 'dashboard_card.dart';

bool _isTablet = false;
bool _isPortrait = true;
bool _isBusiness = true;

class SettingsCard extends StatefulWidget {
  final String appName;
  final ImageProvider imageProvider;

  // final Business business;
  // final String wallpaper;

//  final bool isBusiness;
  final String help;

  SettingsCard(this.appName, this.imageProvider, this.help);

  @override
  createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard> {
  double _cardSize;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
        widget.appName,
        widget.imageProvider,
//        MainSettingsCard(widget.isBusiness),
        MainSettingsCard(_isBusiness),
        SettingsSecCard(),
        SettingsNavigation(),
        true,
        true);
  }
}

class MainSettingsCard extends StatefulWidget {
  final bool isBusiness;

  MainSettingsCard(this.isBusiness);

  @override
  createState() => _MainSettingsCardState();
}

//class _MainSettingsCardState extends State<MainSettingsCard> {
//  double _cardSize;
//
//  @override
//  Widget build(BuildContext context) {
//    return OrientationBuilder(
//      builder: (BuildContext context, Orientation orientation) {
//        _isPortrait =
//            Orientation.portrait == MediaQuery.of(context).orientation;
//        Measurements.height = (_isPortrait
//            ? MediaQuery.of(context).size.height
//            : MediaQuery.of(context).size.width);
//        Measurements.width = (_isPortrait
//            ? MediaQuery.of(context).size.width
//            : MediaQuery.of(context).size.height);
//        _isTablet = Measurements.width < 600 ? false : true;
//        _cardSize = Measurements.height * (_isTablet ? 0.03 : 0.05);
//        return AnimatedContainer(
//          duration: Duration(milliseconds: 100),
//          height: _cardSize * (_isTablet ? 2.5 : 2),
//          padding: EdgeInsets.only(
//              bottom: Measurements.width * (_isTablet ? 0.01 : 0.015)),
//          child: Row(
//            children: <Widget>[
//              Flexible(
//                flex: 1,
//                child: CustomSettingsButton(
//                  buttonIcon: Icon(Icons.airplay),
//                  buttonText: "Edit Wallpaper",
//                  buttonColor: Colors.grey.withOpacity(0.3),
//                  onPressed: () {},
//                ),
//              ),
//              Flexible(
//                flex: 1,
//                child: CustomSettingsButton(
//                  buttonIcon: Icon(Icons.all_out),
//                  buttonText: "Edit Language",
//                  buttonColor: Colors.grey.withOpacity(0.3),
//                  onPressed: () {
//
//                  },
//                ),
//              ),
//            ],
//          ),
//        );
//      },
//    );
//  }
//}

class _MainSettingsCardState extends State<MainSettingsCard> {
  double _cardSize;

  @override
  Widget build(BuildContext context) {
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
        _cardSize = Measurements.height * (_isTablet ? 0.03 : 0.05);
        return InkWell(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 100),
            height: _cardSize * (_isTablet ? 2.5 : 2),
            padding: EdgeInsets.only(
                bottom: Measurements.width * (_isTablet ? 0.01 : 0.015)),
            child: Row(
              children: <Widget>[
//              SizedBox(
//                width: _isTablet
//                    ? Measurements.width * 0.15
//                    : Measurements.width * 0.18,
//                height: _isTablet
//                    ? Measurements.width * 0.15
//                    : Measurements.width * 0.18,
//                child: CircleAvatar(
//                  backgroundColor: Colors.blue,
//                  child: SvgPicture.asset(
//                    "images/mailIcon.svg",
////                    fit: BoxFit.fill,
//                    color: Colors.white,
//                  ),
//                ),
//              ),

                SizedBox(
                  width: _isTablet
                      ? Measurements.width * 0.15
                      : Measurements.width * 0.18,
                  height: _isTablet
                      ? Measurements.width * 0.15
                      : Measurements.width * 0.18,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey.withOpacity(0.3),
//                  child: Icon(Icons.settings, color: Colors.white,size: 40,),
                    child: Icon(
                      Icons.people,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),

                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: AutoSizeText(
                              "Employees",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: AutoSizeText(
                              "View employees and groups.",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                PageTransition(
//                  child: SettingsScreen(),
                  child: EmployeesScreen(),
                  type: PageTransitionType.fade,
                ));
          },
        );
      },
    );
  }
}

class SettingsSecCard extends StatefulWidget {
  @override
  createState() => _SettingsSecCardState();
}

class _SettingsSecCardState extends State<SettingsSecCard> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class SettingsNavigation implements CardContract {
  @override
  void loadScreen(BuildContext context, ValueNotifier state) {
//    state.notifyListeners();
//    Navigator.push(context, PageTransition(child: TransactionScreen(_currentWallpaper,false,_currentBusiness), type: PageTransitionType.fade,));
    Navigator.push(
        context,
        PageTransition(
//          child: SettingsScreen(),
          child: EmployeesScreen(),
          type: PageTransitionType.fade,
        ));

    state.value = false;
  }

  @override
  String learnMore() {
    return null;
  }
}
