import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../../commons/views/custom_elements/drop_down_menu.dart';
import '../../view_models/view_models.dart';
import '../../network/network.dart';
import '../../utils/utils.dart';

class LanguagePopUp extends StatefulWidget {
  Map<String, String> languages = {
    "en": "English",
    "es": "Español",
    "de": "Deutsch",
    "no": "Norsk",
    "da": "Dansk",
    "sv": "Svenska",
  };
  Map<String, String> languagesToConst = {
    "English": "en",
    "Español": "es",
    "Deutsch": "de",
    "Norsk": "no",
    "Dansk": "da",
    "Svenska": "sv",
  };

  @override
  _LanguagePopUpState createState() => _LanguagePopUpState();
}

class _LanguagePopUpState extends State<LanguagePopUp> {
  String _lang;

  @override
  void initState() {
    super.initState();
    _lang = Language.language;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 400,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: Container(
                      height: 50,
                      child: DropDownMenu(
                        customColor: false,
                        onChangeSelection: (lang, _index) {
                          _lang = widget.languagesToConst[lang];
                          setState(() {});
                        },
                        backgroundColor: Colors.transparent,
                        optionsList: <String>["English", "Deutsch"],
                        placeHolderText: widget.languages[Language.language],
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: InkWell(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10)),
                    ),
                    child: Text(Language.getCommerceOSStrings("actions.save")),
                  ),
                  onTap: () {
                    print("tap");
                    print("${widget.languages[_lang]}");
                    EmployeesApi()
                        .patchLanguage(
                            GlobalUtils.activeToken.accessToken, _lang)
                        .then((_) {
                      Language.setLanguage(_lang);
                      SharedPreferences.getInstance().then(
                          (p) => p.setString(GlobalUtils.LANGUAGE, _lang));
                      Language(context);
                      Provider.of<GlobalStateModel>(context).notifyListeners();
                      Navigator.of(context).pop();
                    });
                  },
                ))
              ],
            ),
          ),
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 16),
        ),
      ),
    );
  }
}
