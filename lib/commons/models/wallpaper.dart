import 'package:payever/commons/utils/common_utils.dart';


class WallpaperCategory{
  String _code;
  List<WallpaperIndustry> _industries = List();
  
  String get code  => _code;
  List<WallpaperIndustry> get industries => _industries;

  WallpaperCategory.map(dynamic obj){

    _code       = obj[GlobalUtils.DB_SETTINGS_WALLPAPER_CODE];
    obj[GlobalUtils.DB_SETTINGS_WALLPAPER_INDUSTRIES]?.forEach((industry){
      _industries.add(WallpaperIndustry.map(industry));
    });
    
  }
}
class WallpaperIndustry{
  
  String _code;
  List<String> _wallpapers = List();
  String get code  => _code;
  List<String> get wallapapers => _wallpapers;

  WallpaperIndustry.map(dynamic obj){
    _code       = obj[GlobalUtils.DB_SETTINGS_WALLPAPER_CODE];
    obj[GlobalUtils.DB_SETTINGS_WALLPAPER_WALLPAPERS]?.forEach((wallpaper){
      _wallpapers.add(wallpaper);
    });
  }
  
}
