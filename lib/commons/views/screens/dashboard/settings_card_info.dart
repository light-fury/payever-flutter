import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../../view_models/view_models.dart';
import '../../../models/models.dart';
import '../../../utils/translations.dart';
import '../../custom_elements/dashboard_card_templates.dart';
import '../../custom_elements/custom_dialog.dart'as dialog;
import '../../../../settings/views/language/language.dart';
import '../../../../settings/views/wallpaper/wallpaperscreen.dart';
import 'dashboard_card_ref.dart';

class SettingsCardInfo extends StatefulWidget {
  final String _appName;
  final ImageProvider _imageProvider;

  SettingsCardInfo(this._appName, this._imageProvider);

  @override
  createState() => _SettingsCardInfoState();
}

class _SettingsCardInfoState extends State<SettingsCardInfo> {

  List<ButtonsData> buttonsDataList = List<ButtonsData>();


  @override
  Widget build(BuildContext context) {

    buttonsDataList = [];
    buttonsDataList.add(ButtonsData(icon: AssetImage("assets/images/languageicon.png"),
        title: Language.getWidgetStrings("widgets.settings.actions.edit-language"), action: () => _popLanguages()));
   buttonsDataList.add(ButtonsData(icon: AssetImage("assets/images/wallpapericon.png"),
       title: Language.getWidgetStrings("widgets.settings.actions.edit-wallpaper"), action: () => _goToWallpaperScreen()));

    return DashboardCardRef(
      widget._appName,
      widget._imageProvider,
      ItemsCardNButtons(buttonsDataList),defPad: false,
    );
  }

//  _goToEmployeesScreen() {
//    showDialog(
//      context: context,
//      builder: (context){
//        return Dialog(elevation: 1,
//          backgroundColor: Colors.transparent,
//          child: LanguagePopUp());
//      }
//    );
//  }

  _popLanguages(){
    dialog.showDialog(
      context: context,
      builder: (context){
        return Dialog(elevation: 1,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.white.withOpacity(0.1),
          child: LanguagePopUp());
      }
    );
  }
  
  _goToWallpaperScreen() {
    Navigator.push(
        context,
        PageTransition(
          child: ChangeNotifierProvider<DashboardStateModel>(builder: (BuildContext context) {
            return DashboardStateModel();
          },
         child: WallpaperScreen(),), type: PageTransitionType.fade));
            // child: WallpaperScreen(), type: PageTransitionType.fade));
  }
}
