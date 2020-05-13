import '../utils/utils.dart';

class Shop {
  bool _active;
  String _business;
  String _channelSet;
  String _createdAt;
  String _defaultLocale;
  bool _live;
  List<String> _locales = List();
  String _logo;
  String _name;
  String _theme;
  String _updatedAt;
  String __v;
  String _id;

  Shop.toMap(dynamic obj) {
    _active = obj[GlobalUtils.DB_SHOP_ACTIVE];
    _business = obj[GlobalUtils.DB_SHOP_BUSINESS];
    _channelSet = obj[GlobalUtils.DB_SHOP_CHANNEL_SET];
    _createdAt = obj[GlobalUtils.DB_SHOP_CREATED_AT];
    _defaultLocale = obj[GlobalUtils.DB_SHOP_DEFAULT_LOCALE];
    _live = obj[GlobalUtils.DB_SHOP_LIVE];
    _logo = obj[GlobalUtils.DB_SHOP_LOGO];
    _name = obj[GlobalUtils.DB_SHOP_NAME];
    _theme = obj[GlobalUtils.DB_SHOP_THEME];
    _updatedAt = obj[GlobalUtils.DB_SHOP_UPDATED_AT];
    _id = obj[GlobalUtils.DB_SHOP_ID];
  }

  bool get active => _active;

  String get business => _business;

  String get channelSet => _channelSet;

  String get createdAt => _createdAt;

  String get defaultLocale => _defaultLocale;

  bool get live => _live;

  String get logo => _logo;

  String get name => _name;

  String get theme => _theme;

  String get updatedAt => _updatedAt;

  String get v => __v;

  String get id => _id;

  List<String> locales = List();
}
