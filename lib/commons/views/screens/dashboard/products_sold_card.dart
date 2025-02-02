import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:payever/commons/views/screens/dashboard/dashboard_app_installed.dart';
import 'package:provider/provider.dart';

import '../../../view_models/view_models.dart';
import 'products_sold_card_item.dart';
import 'dashboard_card_ref.dart';

import '../../../../products/views/views.dart';

class ProductsSoldCard extends StatelessWidget {
  final String _appName;
  final ImageProvider _imageProvider;
  final String _help;
  final bool dashboardApp;

  ProductsSoldCard(this._appName, this._imageProvider, this._help, {this.dashboardApp = false});

  @override
  Widget build(BuildContext context) {
    GlobalStateModel globalStateModel = Provider.of<GlobalStateModel>(context);

    print(_help);
    
    if (dashboardApp == true) {
      return DashboardAppInstalled(
        _appName,
        _imageProvider,
        Padding(
          padding: EdgeInsets.symmetric(vertical: 1),
          child: InkWell(
            highlightColor: Colors.transparent,
            child: ProductsSoldCardItem(),
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      child: ProductScreen(
                        business: globalStateModel.currentBusiness,
                        wallpaper: globalStateModel.currentWallpaper,
                        posCall: false,
                      ),
                      type: PageTransitionType.fade));
            },
          ),
        ),
      );
    }
    return DashboardCardRef(
      _appName,
      _imageProvider,
      Padding(
        padding: EdgeInsets.symmetric(vertical: 1),
        child: InkWell(
          highlightColor: Colors.transparent,
          child: ProductsSoldCardItem(),
          onTap: () {
            Navigator.push(
                context,
                PageTransition(
                    child: ProductScreen(
                      business: globalStateModel.currentBusiness,
                      wallpaper: globalStateModel.currentWallpaper,
                      posCall: false,
                    ),
                    type: PageTransitionType.fade));
          },
        ),
      ),
    );
  }
}
