import '../utils/utils.dart';

class Token {
  String accessToken;
  String refreshToken;

  Token.map(dynamic obj) {
    this.accessToken = obj[GlobalUtils.DB_TOKEN_ACC];
    this.refreshToken = obj[GlobalUtils.DB_TOKEN_RFS];
  }

  String get getAccessToken => accessToken;

  String get getRefreshToken => refreshToken;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map[GlobalUtils.DB_TOKEN_ACC] = accessToken;
    map[GlobalUtils.DB_TOKEN_RFS] = refreshToken;
    return map;
  }
}
