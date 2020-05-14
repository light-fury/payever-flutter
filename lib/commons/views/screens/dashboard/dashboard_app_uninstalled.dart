// Flutter code sample for Card

// This sample shows creation of a [Card] widget that shows album information
// and two actions.

import 'package:flutter/material.dart';
import 'package:payever/commons/commons.dart';
import 'package:payever/commons/utils/app_style.dart';
import 'package:payever/commons/utils/common_utils.dart';
import 'package:payever/commons/utils/translations.dart';
import 'package:provider/provider.dart';

class DashboardAppUninstalled extends StatefulWidget {
  final String _appName;
  final String _microUuid;
  final ImageProvider _imageProvider;
  final Function() _notifyParent;

  DashboardAppUninstalled(this._appName, this._imageProvider, this._microUuid, this._notifyParent);

  @override
  createState() => _DashboardAppUninstalledState();
}

class _DashboardAppUninstalledState extends State<DashboardAppUninstalled> {
  GlobalStateModel globalStateModel;
  DashboardStateModel dashboardStateModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool _isPortrait =
        Orientation.portrait == MediaQuery.of(context).orientation;
    Measurements.height = (_isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width);
    Measurements.width = (_isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height);
    bool _isTablet = Measurements.width < 600 ? false : true;
    globalStateModel = Provider.of<GlobalStateModel>(context);
    dashboardStateModel = Provider.of<DashboardStateModel>(context);
    return Container(
      height: AppStyle.dashboardAppCardHeight(),
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(vertical: Measurements.width * (_isTablet ?0.003:0.01)),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: Measurements.width * (_isTablet ? (Measurements.width < 850?0.2: 0.25): (_isPortrait ? 0.05 : 1.3))),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          clipBehavior: Clip.antiAlias,
          child: Container(
            color: Color(0xFF373737).withOpacity(0.6),
            child: Column(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 18, bottom: 12),
                      child: Image(
                        image: widget._imageProvider,
                        height: AppStyle.dashboardAppLogoSize(),
                        width: AppStyle.dashboardAppLogoSize(),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    Container(
                      height: 24,
                      child: Text(
                        Language.getWidgetStrings("widgets.tutorial.type.${widget._appName}"),
                        style: TextStyle(
                          fontSize: AppStyle.fontSizeAppBar(),
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      height: 24,
                      child: Text(
                        Language.getWidgetStrings("widgets.${widget._appName}.install-app"),
                        style: TextStyle(
                          fontSize: AppStyle.fontSizeTabMid(),
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  height: AppStyle.dashboardAppButtonHeight(),
                  margin: EdgeInsets.only(top: 20),
                  color: Color(0xFF373737).withOpacity(0.2),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                          child: Text('Get started', style: TextStyle(fontSize: AppStyle.fontSizeTabMid())),
                          onPressed: () {
                            RestDataSource()
                              .toggleBusinessAppInstall(
                                globalStateModel.currentBusiness.id,
                                GlobalUtils.activeToken.accessToken,
                                widget._microUuid
                              )
                              .then((apps) {
                                dashboardStateModel.getAppsBusinessInfo(globalStateModel.currentBusiness)
                                .then((onData) {
                                  if (onData == true) {
                                    widget._notifyParent();
                                  }
                                });
                              });
                          },
                        ),
                      ),
                      Container(
                        width: 1,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      Expanded(
                        child: FlatButton(
                          child: Text(
                            Language.getWidgetStrings("widgets.actions.learn-more"),
                            style: TextStyle(fontSize: AppStyle.fontSizeTabMid())),
                          onPressed: () {/* ... */},
                        ),
                      ),
                    ],
                  )
                ),
              ],
            ),
          )
        ),
      )
    );
  }
}
