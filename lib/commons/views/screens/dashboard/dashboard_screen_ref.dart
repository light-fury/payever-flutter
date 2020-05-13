import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../models/models.dart';
import '../../../utils/utils.dart';
import '../../../view_models/view_models.dart';
import '../../custom_elements/custom_elements.dart';

import 'dashboard_apps.dart';
import 'dashboard_menu.dart';
import 'dashboard_overview.dart';
import 'pos_card.dart';
import 'products_sold_card.dart';
import 'settings_card.dart';

bool _isTablet;

class DashboardScreen extends StatelessWidget {
  final appWidgets;
  final appData;

  DashboardScreen({this.appWidgets, this.appData});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DashboardStateModel>(
      builder: (BuildContext context) {
        DashboardStateModel dashboardStateModel = DashboardStateModel();
        dashboardStateModel.setCurrentWidget(appWidgets);
        dashboardStateModel.setCurrentAppData(appData);
        return dashboardStateModel;
      },
      child: DashboardScreenWidget(),
    );
  }
}

class DashboardScreenWidget extends StatefulWidget {
  @override
  _DashboardScreenWidgetState createState() => _DashboardScreenWidgetState();
}

class _DashboardScreenWidgetState extends State<DashboardScreenWidget>
    with TickerProviderStateMixin {
  List<NavigationIconView> _navigationViews;
  int _currentIndex = 0;
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _navigationViews = <NavigationIconView>[
      NavigationIconView(
        icon: Container(
            child: SvgPicture.asset("assets/images/dashboardicon.svg",
                color: Colors.white.withOpacity(0.3), height: 18)),
        activeIcon: Container(
            child: SvgPicture.asset("assets/images/dashboardicon.svg",
                color: Colors.white, height: 19)),
        title: Language.getCustomStrings("dashboard.navigation.overview"),
        vSync: this,
        tablet: _isTablet,
      ),
      NavigationIconView(
        icon: Container(
            child: SvgPicture.asset("assets/images/appsicon.svg",
                color: Colors.white.withOpacity(0.3), height: 18)),
        activeIcon: Container(
            child: SvgPicture.asset("assets/images/appsicon.svg",
                color: Colors.white, height: 19)),
        title: Language.getCustomStrings("dashboard.navigation.apps"),
        vSync: this,
        tablet: _isTablet,
      ),
      NavigationIconView(
        icon: Container(
            child: SvgPicture.asset("assets/images/hamburger.svg",
                color: Colors.white.withOpacity(0.3), height: 18)),
        activeIcon: Container(
            child: SvgPicture.asset("assets/images/hamburger.svg",
                color: Colors.white, height: 19)),
        title: Language.getCustomStrings("dashboard.navigation.menu"),
        tablet: _isTablet,
        vSync: this,
      ),
    ];
    //NavigationBar items
  }

  buildUi() {
    _controller = TabController(length: 3, vsync: this);
    _navigationViews[_currentIndex].controller.value = 1.0;
  }

  @override
  Widget build(BuildContext context) {
//    GlobalStateModel globalStateModel = Provider.of<GlobalStateModel>(context);
    bool _isPortrait =
        Orientation.portrait == MediaQuery.of(context).orientation;
    Measurements.height = (_isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width);
    Measurements.width = (_isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height);
    _isTablet = Measurements.width > 600;
    Widget scaffoldBody;
    switch (_currentIndex) {
      case 0:
        scaffoldBody = DashboardOverview();
        break;
      case 1:
        scaffoldBody = DashboardApps();
        break;
      case 2:
        scaffoldBody = DashboardMenu();
        break;
      default:
    }
    buildUi();
    return BackgroundBase(
      _currentIndex != 0,
      body: scaffoldBody,
      bottomNav: BottomNavigationBar(
        items: _navigationViews
            .map<BottomNavigationBarItem>(
                (NavigationIconView navigationView) => navigationView.item)
            .toList(),
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.3),
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
            _controller.index = _currentIndex;
          });
        },
      ),
    );
  }
}

class NavigationIconView {
  NavigationIconView({
    Widget icon,
    Widget activeIcon,
    String title,
    Color color,
    TickerProvider vSync,
    bool tablet,
  })  : _icon = icon,
        _title = title,
        item = BottomNavigationBarItem(
          icon: icon,
          activeIcon: activeIcon,
          title: Container(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                title,
                style: TextStyle(fontSize: 10),
              )),
          backgroundColor: color,
        ),
        controller = AnimationController(
          duration: kThemeAnimationDuration,
          vsync: vSync,
        ) {
    _animation = controller.drive(CurveTween(
      curve: const Interval(1.0, 1.0, curve: Curves.linear),
    ));
  }

  final Widget _icon;
  final String _title;
  final BottomNavigationBarItem item;
  final AnimationController controller;
  Animation<double> _animation;

  FadeTransition transition(
      BottomNavigationBarType type, BuildContext context) {
    print("$_icon $_title");
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: _animation.drive(
          Tween<Offset>(
            begin: const Offset(0.0, 0.0),
            end: Offset.zero,
          ),
        ),
      ),
    );
  }
}

class CardParts {
  static bool _isTablet = false;
  static bool _isPortrait = true;

  static Widget _transactionCard;
  static List<Widget> _activeWid = List();
  static POSCard _posCard;
  static ProductsSoldCard _productsCard;
  static SettingsCard _settingsCard;
  static String uiKit = Env.commerceOs + "/assets/ui-kit/icons-png/";

  static double _appBarSize;

  static Token _currentToken;
  static String wallpaper;
  static Business _currentBusiness;
  static User _currentUser;
  static Terminal currentTerminal;
  static List<AppWidget> _currentWidgets;
  static bool _isBusiness;
  static List<int> indexes = List();
}
