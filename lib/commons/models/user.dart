import '../utils/utils.dart';

class User {
  String _createdAt;
  String _email;
  String _firstName;
  String _language;
  String _lastName;
  String _updatedAt;
  String _id;

  String _salutation;
  String _phone;
  String _birthday;
  String _logo;

  User(
      this._createdAt,
      this._email,
      this._firstName,
      this._language,
      this._lastName,
      this._updatedAt,
      this._id,
      this._salutation,
      this._phone,
      this._logo,
      this._birthday);

  User.map(dynamic obj) {
    this._id = obj[GlobalUtils.DB_USER_ID];
    this._firstName = obj[GlobalUtils.DB_USER_FIRST_NAME];
    this._lastName = obj[GlobalUtils.DB_USER_LAST_NAME];
    this._language = obj[GlobalUtils.DB_USER_LANGUAGE];
    this._updatedAt = obj[GlobalUtils.DB_USER_UPDATED_AT];
    this._createdAt = obj[GlobalUtils.DB_USER_CREATED_AT];
    this._email = obj[GlobalUtils.DB_USER_EMAIL];

    this._salutation = obj[GlobalUtils.DB_USER_SALUTATION];
    this._phone = obj[GlobalUtils.DB_USER_PHONE];
    this._logo = obj[GlobalUtils.DB_USER_LOGO];
    this._birthday = obj[GlobalUtils.DB_USER_BIRTHDAY];
  }

  String get id => _id;

  String get firstName => _firstName;

  String get lastName => _lastName;

  String get language => _language;

  String get updatedAt => _updatedAt;

  String get createdAt => _createdAt;

  String get email => _email;

  String get salutation => _salutation;

  String get phone => _phone;

  String get birthday => _birthday;

  String get logo => _logo;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map[GlobalUtils.DB_USER_ID] = _id;
    map[GlobalUtils.DB_USER_FIRST_NAME] = _firstName;
    map[GlobalUtils.DB_USER_LAST_NAME] = _lastName;
    map[GlobalUtils.DB_USER_LANGUAGE] = _language;
    map[GlobalUtils.DB_USER_UPDATED_AT] = _updatedAt;
    map[GlobalUtils.DB_USER_CREATED_AT] = _createdAt;
    map[GlobalUtils.DB_USER_EMAIL] = _email;
    map[GlobalUtils.DB_USER_SALUTATION] = _salutation;
    map[GlobalUtils.DB_USER_PHONE] = _phone;
    map[GlobalUtils.DB_USER_BIRTHDAY] = _birthday;
    map[GlobalUtils.DB_USER_LOGO] = _logo;
    return map;
  }
}
