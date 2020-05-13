import '../utils/utils.dart';

class Version {
  String _minVersion;
  String _currentVersion;
  String _appleStoreUrl;
  String _playStoreUrl;

  Version(this._currentVersion, this._minVersion, this._appleStoreUrl,
      this._playStoreUrl);

  Version.map(obj) {
    _minVersion = obj[GlobalUtils.DB_VERSION_MIN_VERSION];
    _currentVersion = obj[GlobalUtils.DB_VERSION_CURRENT_VERSION];
    _appleStoreUrl = obj[GlobalUtils.DB_VERSION_APPLE_STORE];
    _playStoreUrl = obj[GlobalUtils.DB_VERSION_PLAY_STORE];
  }

  String get minVersion => _minVersion;

  String get currentVersion => _currentVersion;

  String storeLink(bool isApple) => isApple ? _appleStoreUrl : _playStoreUrl;
}
