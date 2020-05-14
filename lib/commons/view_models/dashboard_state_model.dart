import 'package:flutter/material.dart';
import 'package:payever/commons/models/wallpaper.dart';
import 'package:payever/settings/network/employees_api.dart';

import '../models/models.dart';
import '../network/network.dart';
import '../utils/utils.dart';
import '../views/views.dart';

class DashboardStateModel extends ChangeNotifier with Validators {
  Terminal _activeTerminal;

  Terminal get activeTerminal => _activeTerminal;

  setActiveTerminal(Terminal activeTerminal) =>
      _activeTerminal = activeTerminal;

  List<Terminal> _terminalList = List();

  List<Terminal> get terminalList => _terminalList;

  setTerminalList(List<Terminal> terminals) => _terminalList = terminals;

  double _total = 0.0;

  double get total => _total;

  setTotal(double total) => _total = total;

  List<AppWidget> _currentWidgets = List();

  List<AppWidget> get currentWidgets => _currentWidgets;

  setCurrentWidget(List<AppWidget> apps) => _currentWidgets = apps;

  List<BusinessApps> _currentAppData = List();

  List<BusinessApps> get currentAppData => _currentAppData;

  setCurrentAppData(List<BusinessApps> apps) => _currentAppData = apps;

  List<Month> _lastYear = List();

  List<Month> get lastYear => _lastYear;

  setLastYear(List<Month> lastYear) => _lastYear = lastYear;

  List<double> _monthlySum = List();

  List<double> get monthlySum => _monthlySum;

  setMonthlySum(List<double> monthlySum) => _monthlySum = monthlySum;

  List<Day> _lastMonth = List();

  List<Day> get lastMonth => _lastMonth;

  setLastMonth(List<Day> lastMonth) => _lastMonth = lastMonth;

  List<Tutorial> _tutorials = List();

  List<Tutorial> get tutorials => _tutorials;

  setTutorials(List<Tutorial> tutorials) => _tutorials = tutorials;

  List<Widget> _activeWid = List();
  String uiKit = Env.commerceOs + "/assets/ui-kit/icons-png/";

  Future<List<Widget>> loadWidgetCards() async {
    for (int i = 0; i < _currentWidgets.length; i++) {
      var wid = _currentWidgets[i];
      switch (wid.type) {
        case "transactions":
          _activeWid.add(TransactionCard(
            wid.type,
            NetworkImage(uiKit + wid.icon),
            false,
          ));
          break;
        case "pos":
          _activeWid
              .add(POSCard(wid.type, NetworkImage(uiKit + wid.icon), wid.help));
          break;
        case "products":
          _activeWid.add(
              ProductsSoldCard(wid.type, NetworkImage(uiKit + wid.icon), wid.help));
          break;
        case "settings":
          _activeWid.add(
              SettingsCard(wid.type, NetworkImage(uiKit + wid.icon), wid.help));
          break;
        default:
      }
    }
    return _activeWid;
  }

  Future<dynamic> fetchDaily(Business currentBusiness) {
    return RestDataSource()
        .getDays(currentBusiness.id, GlobalUtils.activeToken.accessToken, null);
  }

  Future<dynamic> fetchMonthly(Business currentBusiness) {
    return RestDataSource().getMonths(
        currentBusiness.id, GlobalUtils.activeToken.accessToken, null);
  }

  Future<dynamic> fetchTotal(Business currentBusiness) {
    return RestDataSource().getTransactionList(
        currentBusiness.id, GlobalUtils.activeToken.accessToken, "", null);
  }

  Future<dynamic> getDaily(Business currentBusiness) async {
    var days = await fetchDaily(currentBusiness);
    days.forEach((day) {
      lastMonth.add(Day.map(day));
    });
    setLastMonth(lastMonth);
    return getMonthly(currentBusiness);
  }

  Future<dynamic> getMonthly(Business currentBusiness) async {
    var months = await fetchMonthly(currentBusiness);
    months.forEach((month) {
      lastYear.add(Month.map(month));
    });
    setLastYear(lastYear);
    num sum;
    for (int i = (lastYear.length - 1); i >= 0; i--) {
      sum += lastYear[i].amount;
      monthlySum.add(sum);
    }

    return getTotal(currentBusiness);
  }

  Future<dynamic> getTotal(Business currentBusiness) async {
    var _total = await fetchTotal(currentBusiness);
    setTotal(Transaction.toMap(_total).paginationData.amount.toDouble());
    return _total;
  }

  ///API CALLS
  Future<bool> getAppsBusinessInfo(Business currentBusiness) async {
    return RestDataSource().getAppsBusiness(
        currentBusiness.id, GlobalUtils.activeToken.accessToken)
        .then((dynamic obj) {
      List<BusinessApps> businessApps = List<BusinessApps>();
      obj.forEach((item) {
        if ((item['dashboardInfo']?.isEmpty ?? true) == false) {
          var appData = BusinessApps.fromMap(item);
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
      });
      setCurrentAppData(businessApps);
      return true;
    }).catchError((onError) {
      print("ERROR ---- $onError");
      return false;
    });
  }

  Future<List<WallpaperCategory>> getWallpaper() => EmployeesApi().getWallpapers()
  .then((wallpapers){
    List<WallpaperCategory> _list = List();
    wallpapers.forEach((cat){
        _list.add(WallpaperCategory.map(cat));
    });
    return _list;
  });
  
}
