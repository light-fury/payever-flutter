import 'package:flutter/material.dart';

import '../models/models.dart';

class GlobalStateModel extends ChangeNotifier {
  String _currentWallpaper;
  String _currentWallpaperBlur;

  String _defaultCustomWallpaper =
      "https://payevertest.azureedge.net/images/commerseos-background.jpg";
  String _defaultCustomWallpaperBlur =
      "https://payevertest.azureedge.net/images/commerseos-background-blurred.jpg";

  Business _currentBusiness;
  List<AppWidget> _appWidgets;

  String get currentWallpaper => _currentWallpaper ?? _defaultCustomWallpaper;

  String get defaultCustomWallpaper => _defaultCustomWallpaper;

  Business get currentBusiness => _currentBusiness;

  List<AppWidget> get appWidgets => _appWidgets;

  String get currentWallpaperBlur =>
      _currentWallpaperBlur ?? _defaultCustomWallpaperBlur;

  setCurrentWallpaper(String wallpaper, {bool notify}) {
    _currentWallpaper = wallpaper;
    setCurrentWallpaperBlur(wallpaper + "-blurred", notify: false);
    if (notify ?? true) notifyListeners();
  }

  setCurrentWallpaperBlur(String wallpaper, {bool notify}) {
    _currentWallpaperBlur = wallpaper;
    if (notify ?? true) notifyListeners();
  }

  setCurrentBusiness(Business business, {bool notify}) {
    _currentBusiness = business;
    if (notify ?? true) notifyListeners();
  }

  updateWallpaperBusinessAndAppsWidgets(
      String wallpaper, Business business, List<AppWidget> appWidgets) {
    _appWidgets = [];
    _currentWallpaper = wallpaper;
    _currentBusiness = business;
    _appWidgets = appWidgets;

    print("_currentWallpaper: $_currentWallpaper");
    print("_currentBusiness: $_currentBusiness");
    print("_appWidgets: $_appWidgets");

    notifyListeners();
  }
}
