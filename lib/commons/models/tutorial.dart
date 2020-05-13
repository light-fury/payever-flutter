import '../utils/utils.dart';

class Tutorial {
  bool _init;
  String _icon;
  num _order;
  String _title;
  String _type;
  String _url;
  bool _watched;
  String __id;

  Tutorial.map(dynamic obj) {
    _init = obj[GlobalUtils.DB_TUTORIAL_INIT];
    _icon = obj[GlobalUtils.DB_TUTORIAL_ICON];
    _order = obj[GlobalUtils.DB_TUTORIAL_ORDER];
    _title = obj[GlobalUtils.DB_TUTORIAL_TITLE];
    _type = obj[GlobalUtils.DB_TUTORIAL_TYPE];
    _url = obj[GlobalUtils.DB_TUTORIAL_URL];
    _watched = obj[GlobalUtils.DB_TUTORIAL_WATCHED];
    __id = obj[GlobalUtils.DB_TUTORIAL_ID];
  }

  bool get init => _init;

  String get icon => _icon;

  num get order => _order;

  String get title => _title;

  String get type => _type;

  String get url => _url;

  bool get watched => _watched;

  String get id => __id;
}
