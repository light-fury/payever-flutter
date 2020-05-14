import 'package:flutter/material.dart';
import 'package:payever/commons/views/screens/dashboard/dashboard_app_started.dart';
import 'package:payever/commons/views/screens/dashboard/dashboard_app_uninstalled.dart';
import 'package:payever/commons/views/screens/dashboard/settings_card_info.dart';
import 'package:provider/provider.dart';

import '../../../view_models/view_models.dart';
import '../../../utils/utils.dart';
import '../../../models/models.dart';

import 'pos_card.dart';
import 'transaction_card.dart';
import 'tutorial_card.dart';
import 'products_sold_card.dart';

class DashboardOverview extends StatefulWidget {
  DashboardOverview();

  @override
  createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview> {
  final String uiKit = Env.commerceOs + "/assets/ui-kit/icons-png/";

  @override
  void initState() {
    super.initState();
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _activeWid = List();

    DashboardStateModel dashboardStateModel =
        Provider.of<DashboardStateModel>(context);
    _activeWid.add(Padding(
      padding: EdgeInsets.only(top: 25),
    ));
    for (int i = 0; i < dashboardStateModel.currentWidgets.length; i++) {
      var wid = dashboardStateModel.currentWidgets[i];
      switch (wid.type) {
        case "tutorial":
          // _activeWid.add(TransactionCard(
          //     wid.type,
          //     NetworkImage(UI_KIT + wid.icon),
          //     false,
          //     ));
          _activeWid
              .add(SimplyTutorial(wid.type, NetworkImage(uiKit + wid.icon)));
          break;
        case "transactions":
          // _activeWid.add(TransactionCard(
          //     wid.type,
          //     NetworkImage(UI_KIT + wid.icon),
          //     false,
          //     ));
          _activeWid.add(
              SimplifyTransactions(wid.type, NetworkImage(uiKit + wid.icon)));
          break;
        // case "pos":
        //   // _activeWid.add(POSCard(
        //   //     wid.type,
        //   //     NetworkImage(UI_KIT + wid.icon),
        //   //     wid.help));
        //   _activeWid.add(SimplifyTerminal(
        //     wid.type,
        //     NetworkImage(uiKit + wid.icon),
        //   ));
        //   break;
        case "products":
          _activeWid.add(ProductsSoldCard(
            wid.type,
            NetworkImage(uiKit + wid.icon),
            ""
          ));
          break;
       case "settings":
         _activeWid.add(SettingsCardInfo(
           wid.type,
           NetworkImage(uiKit + wid.icon),
         ));
          break;
//        case "connect":
//          _activeWid.add(DashboardCard_ref(
//              wid.type,
//              NetworkImage(UI_KIT + wid.icon),
//              Center(child: Text("test"),),
//              body: ListView(shrinkWrap: true,children: <Widget>[Center(child: Text("test"),),Center(child: Text("test"),),Center(child: Text("test"),),],),
//              ));
//          break;
        default:
      }
    }
    for (int i = 0; i < (dashboardStateModel.currentAppData ?? []).length; i++) {
      var individualApp = dashboardStateModel.currentAppData[i];
      var productName = individualApp.dashboardInfo.title.split('.').last;
      var iconUrl = uiKit + individualApp.dashboardInfo.icon.substring(8);
      if (individualApp.installed == false) {
        _activeWid.add(new DashboardAppUninstalled(
          productName,
          NetworkImage(iconUrl),
          individualApp.microUuid,
          refresh,
        ));
      } else if (individualApp.setupStatus == 'completed') {
        switch (productName) {
          case "tutorial":
            _activeWid
              .add(SimplyTutorial(
                productName,
                NetworkImage(iconUrl),
                dashboardApp: true,
              ));
            break;
          case "transactions":
            _activeWid.add(SimplifyTransactions(
              productName,
              NetworkImage(iconUrl),
              dashboardApp: true,
            ));
            break;
          case "pos":
            _activeWid.add(SimplifyTerminal(
              productName,
              NetworkImage(iconUrl),
              dashboardApp: true,
            ));
            break;
          case "products":
            _activeWid.add(ProductsSoldCard(
              productName,
              NetworkImage(iconUrl),
              "",
              dashboardApp: true,
            ));
            break;
          case "settings":
            _activeWid.add(SettingsCardInfo(
              productName,
              NetworkImage(iconUrl),
              dashboardApp: true,
            ));
              break;
          default:
        }
      } else {
        _activeWid.add(new DashboardAppStarted(
          productName,
          NetworkImage(iconUrl),
          individualApp.microUuid,
          individualApp.code,
          refresh,
        ));
      }
    }
    return Container(
        color: Colors.transparent,
        child: ListView(
          shrinkWrap: true,
          children: _activeWid,
        ));
  }
}
