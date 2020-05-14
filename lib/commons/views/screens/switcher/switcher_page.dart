import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../../view_models/view_models.dart';
import '../../../models/models.dart';
import '../../../network/network.dart';
import '../../../utils/utils.dart';
import '../dashboard/dashboard_screen_ref.dart';
import 'loader.dart';

const double _heightFactorTablet = 0.05;
const double _heightFactorPhone = 0.07;
//const double _widthFactorTablet = 2.0;
//const double _widthFactorPhone = 1.1;
//const double _paddingText = 16.0;

bool _isTablet = false;
bool _isPortrait = true;

SwitchParts parts = SwitchParts();

String imageBase = Env.storage + '/images/';
String wallpaperBase = Env.storage + '/wallpapers/';

class SwitcherScreen extends StatefulWidget {
  SwitcherScreen();

  @override
  createState() => _SwitcherScreenState();
}

class _SwitcherScreenState extends State<SwitcherScreen>
    implements LoadStateListener, AuthStateListener {
//  String _userLogo = "";
  bool _moreSelected = false;
  bool _loadPersonal = false;
  bool _loadBusiness = false;

//  bool _businessActiveImage = false;
  bool _isLoad = false;

  _SwitcherScreenState() {
    print("Switcher");
    var auth = AuthStateProvider();
    auth.subscribe(this);
    var load = LoadStateProvider();
    load.subscribe(this);
  }

  @override
  void initState() {
    super.initState();
    parts = SwitchParts();
  }

  @override
  Widget build(BuildContext context) {
    _isPortrait = Orientation.portrait == MediaQuery.of(context).orientation;
    Measurements.height = (_isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width);
    Measurements.width = (_isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height);
    _isTablet = Measurements.width < 600 ? false : true;

    return Stack(
      children: <Widget>[
        Positioned(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          top: 0.0,
          child: Image.asset(
            "assets/images/loginverticaltablet.png",
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedOpacity(
            child: _isLoad ? Switcher() : Wait(),
            duration: Duration(milliseconds: 500),
            opacity: 1.0,
          ),
        )
      ],
    );
  }

  @override
  void onLoadStateChanged(LoadState state) {
    setState(() => _isLoad = true);
  }

  @override
  void onAuthStateChanged(AuthState state) {}

  Future getBusiness() async {
    SharedPreferences.getInstance().then((preferences) {
      String token = preferences.getString(GlobalUtils.TOKEN);
      if (token.length > 0) {
        return RestDataSource().getUser(token, context).then((dynamic result) {
          parts._logUser = User.map(result);
          preferences.setString(GlobalUtils.LANGUAGE, parts._logUser.language);
          Language.language = parts._logUser.language;
          Language(context);
          Measurements.loadImages(context);
          return RestDataSource()
              .getBusinesses(token, context)
              .then((dynamic result) {
            result.forEach((item) {
              parts.businesses.add(Business.map(item));
            });
            return true;
          }).catchError((e) {});
        }).catchError((e) {
          print('handle error on getMenuProfileData $e');
        });
      } else {
        return false;
      }
    });
  }
}

class GridItems extends StatefulWidget {
  final Business business;

  GridItems({this.business});

  @override
  createState() => _GridItemsState();
}

class _GridItemsState extends State<GridItems> {
  double itemsHeight = (Measurements.height * 0.08);

  bool haveImage;
  bool _isLoading = false;
  String imageURL;

  @override
  void initState() {
    super.initState();

    setState(() {
      haveImage = (widget.business.logo == null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: itemsHeight,
      child: InkWell(
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                        vertical: Measurements.height * 0.01),
                    child: CustomCircleAvatar(
                        widget.business.logo != null
                            ? widget.business.logo
                            : "business",
                        widget.business.name)),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Container(),
              ],
            ),
            Container(
                alignment: Alignment.center,
                child: Text(
                  widget.business.name,
                  textAlign: TextAlign.center,
                ))
          ],
        ),
        onTap: () {
          setState(() {
            _isLoading = true;
          });
          parts.fetchWallpaper(widget.business.id, context).then((img) {
            parts.getWidgets(widget.business.id, context).then((onValue) {
              parts.getAppsData(widget.business.id).then((onData) {
                Provider.of<GlobalStateModel>(context)
                    .setCurrentBusiness(widget.business);
                SharedPreferences.getInstance().then((p) {
                  Provider.of<GlobalStateModel>(context)
                      .setCurrentWallpaper(p.getString(GlobalUtils.WALLPAPER));

                  Navigator.pushReplacement(
                      context,
                      PageTransition(
                          //child:DashboardScreen(GlobalUtils.ActiveToken,img,widget.business,parts._widgets,null),
                          child: DashboardScreen(appWidgets: parts._widgets, appData: parts._appsData),
                          type: PageTransitionType.fade));
                });
              });
            });
          });
        },
      ),
    );
  }
}

class Wait extends StatefulWidget {
  @override
  _WaitState createState() => _WaitState();
}

class _WaitState extends State<Wait> implements LoadStateListener {
  _WaitState() {
    RestDataSource api = RestDataSource();
//    Future<NetworkImage> getImage(String url) async {
//      return NetworkImage(url);
//    }

    SharedPreferences.getInstance().then((preferences) {
      String token = preferences.getString(GlobalUtils.TOKEN);
      if (token.length > 0) {
        api.getUser(token, context).then((dynamic result) {
          parts._logUser = User.map(result);
          preferences.setString(GlobalUtils.LANGUAGE, parts._logUser.language);
          Language.language = parts._logUser.language;
          Language(context);
          Measurements.loadImages(context);
          api.getBusinesses(token, context).then((dynamic result) {
            result.forEach((item) {
              parts.businesses.add(Business.map(item));
            });
            if (parts.businesses != null) {
              parts.businesses.forEach((b) {
                if (b.active) {
                  parts._active = b;
                }
                parts._busWidgets.add(GridItems(business: b));
              });
            }
            parts.grid = new CustomGrid();
            var authStateProvider = LoadStateProvider();
            authStateProvider.notify(LoadState.LOADED).then((bool r) {
              var authStateProvider = LoadStateProvider();
              authStateProvider.dispose(this);
            });
          });
        }).catchError((e) {
          print('handle error on getMenuProfileData $e');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Text(""),
        )
      ],
    );
  }

  @override
  void onLoadStateChanged(LoadState state) {
    print("Loaded");
  }
}

class Switcher extends StatefulWidget {
  Switcher();

  @override
  _SwitcherState createState() => _SwitcherState();
}

class _SwitcherState extends State<Switcher> {
  bool _moreSelected = false;
  bool _loadPersonal = false;
  bool _loadBusiness = false;

//  bool _businessActiveImage = false;

  void goPersonalDashDummy() {
    setState(() => _loadPersonal = false);
  }

  void goPersonalDash() {
    String wallpaperId;
    RestDataSource api = RestDataSource();
    api
        .getWallpaperPersonal(GlobalUtils.activeToken.accessToken, context)
        .then((dynamic obj) {
      wallpaperId = obj[GlobalUtils.CURRENT_WALLPAPER];
      print(wallpaperId);
      api
          .getWidgetsPersonal(GlobalUtils.activeToken.accessToken, context)
          .then((dynamic obj) {
        obj.forEach((item) {
          parts._widgets.add(AppWidget.map(item));
        });
        Navigator.pushReplacement(
            context,
            PageTransition(
                child: DashboardScreen(appWidgets: parts._widgets),
                // child:DashboardScreen(
                //   GlobalUtils.ActiveToken,
                //   wallpaperId.isEmpty? NetworkImage(WALLPAPER_BASE + wallpaperId):AssetImage("images/loginHorizontalTablet.png"),
                //   null,
                //   parts._widgets,
                //   parts._logUser),
                type: PageTransitionType.fade));
      }).catchError((onError) {
        print("wigets $onError");
      });
    }).catchError((onError) {
      print("wallpaper $onError");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AnimatedContainer(
          curve: Curves.fastLinearToSlowEaseIn,
          duration: Duration(milliseconds: 700),
          padding: EdgeInsets.only(
              top: (Measurements.height *
                  (!_moreSelected
                      ? (_isTablet ? 0.3 : _isPortrait ? 0.3 : 0.1)
                      : (_isTablet ? 0.1 : _isPortrait ? 0.1 : 0.05)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text("Personal"),
                    Padding(
                      padding: EdgeInsets.only(
                          top: (Measurements.height *
                                  (_isTablet
                                      ? _heightFactorTablet
                                      : _heightFactorPhone)) /
                              3),
                    ),
                    InkWell(
                      highlightColor: Colors.transparent,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          CustomCircleAvatar(
                              parts._logUser.logo != null
                                  ? parts._logUser.logo
                                  : "user",
                              parts._logUser.firstName),
                          _loadPersonal
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Container(
                                      height: Measurements.height * 0.08,
                                      width: Measurements.height * 0.08,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black.withOpacity(0.2)),
                                    ),
                                    Container(
                                      child: CircularProgressIndicator(),
                                    )
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                      onTap: () {
                        print("onIconSelect - personal");
                        setState(() => _loadPersonal = true);
                        goPersonalDashDummy();
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: (Measurements.height *
                                  (_isTablet
                                      ? _heightFactorTablet
                                      : _heightFactorPhone)) /
                              3),
                    ),
                    InkWell(
                      highlightColor: Colors.transparent,
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: Text(parts._logUser.firstName),
                      ),
                      onTap: () {
                        print("onTextSelect - personal");
                        setState(() => _loadPersonal = true);
                        goPersonalDashDummy();
                      },
                    ),
                  ],
                ),
              ),
              parts.businesses != null
                  ? Container(
                      padding: EdgeInsets.only(
                          left: (Measurements.width * (_isTablet ? 0.2 : 0.2))),
                      child: Column(
                        children: <Widget>[
                          Text("Business"),
                          Padding(
                            padding: EdgeInsets.only(
                                top: (Measurements.height *
                                        (_isTablet
                                            ? _heightFactorTablet
                                            : _heightFactorPhone)) /
                                    3),
                          ),
                          InkWell(
                            highlightColor: Colors.transparent,
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                CustomCircleAvatar(
                                    parts._active.logo != null
                                        ? parts._active.logo
                                        : "business",
                                    parts._active.name),
                                _loadBusiness
                                    ? Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          Container(
                                            height: Measurements.height * 0.08,
                                            width: Measurements.height * 0.08,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black
                                                    .withOpacity(0.2)),
                                          ),
                                          Container(
                                            child: CircularProgressIndicator(),
                                          )
                                        ],
                                      )
                                    : Container(),
                              ],
                            ),
                            onTap: () {
                              print("onIconSelect - business");
                              setState(() => _loadBusiness = true);
                              parts
                                  .fetchWallpaper(parts._active.id, context)
                                  .then((img) {
                                parts
                                    .getWidgets(parts._active.id, context)
                                    .then((onValue) {
                                  parts
                                    .getAppsData(parts._active.id)
                                    .then((onData) {
                                    Provider.of<GlobalStateModel>(context)
                                        .setCurrentBusiness(parts._active);
                                    SharedPreferences.getInstance().then((p) {
                                      Provider.of<GlobalStateModel>(context)
                                          .setCurrentWallpaper(
                                              p.getString(GlobalUtils.WALLPAPER));
                                      Navigator.pushReplacement(
                                          context,
                                          PageTransition(
                                              child: DashboardScreen(
                                                  appWidgets: parts._widgets,
                                                  appData: parts._appsData,
                                                ),
                                              type: PageTransitionType.fade));
                                    });
                                  });
                                });
                              });
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: (Measurements.height *
                                        (_isTablet
                                            ? _heightFactorTablet
                                            : _heightFactorPhone)) /
                                    3),
                          ),
                          (parts.businesses != null)
                              ? InkWell(
                                  key: GlobalKeys.allButton,
                                  highlightColor: Colors.transparent,
                                  child: Chip(
                                    backgroundColor:
                                        Colors.black.withOpacity(0.4),
                                    label: parts.businesses.length > 1
                                        ? Container(
                                            child: Row(
                                              children: <Widget>[
                                                Text(
                                                    "All ${parts.businesses.length}"),
                                                Icon(!_moreSelected
                                                    ? IconData(58131,
                                                        fontFamily:
                                                            'MaterialIcons')
                                                    : IconData(58134,
                                                        fontFamily:
                                                            'MaterialIcons'))
                                              ],
                                            ),
                                          )
                                        : Container(
                                            child: Row(
                                              children: <Widget>[
                                                Text(parts._active.name),
                                                Icon(!_moreSelected
                                                    ? IconData(58131,
                                                        fontFamily:
                                                            'MaterialIcons')
                                                    : IconData(58134,
                                                        fontFamily:
                                                            'MaterialIcons'))
                                              ],
                                            ),
                                          ),
                                  ),
                                  onTap: () {
                                    print("onTextSelect - personal");
                                    setState(
                                        () => _moreSelected = !_moreSelected);
                                  },
                                )
                              : Container(),
                        ],
                      ))
                  : Container(),
            ],
          ),
        ),
        !_moreSelected ? Container() : Expanded(child: CustomGrid())
      ],
    );
  }
}

class SwitchParts {
  User _logUser;
  List<Business> businesses = List();
  Business _active;
  Widget grid;
  List<GridItems> _busWidgets = List();
  List<AppWidget> _widgets = List();
  List<BusinessApps> _appsData = List();

  Future<String> fetchWallpaper(String id, BuildContext context) async {
    String wallpaperId;
    SharedPreferences preferences;
    RestDataSource api = new RestDataSource();
    await api
        .getWallpaper(id, GlobalUtils.activeToken.accessToken, context)
        .then((obj) {
      wallpaperId = obj[GlobalUtils.CURRENT_WALLPAPER][GlobalUtils.WALLPAPER];
      SharedPreferences.getInstance().then((p) {
        preferences = p;
        preferences.setString(
            GlobalUtils.WALLPAPER, wallpaperBase + wallpaperId);
        preferences.setString(GlobalUtils.BUSINESS, id);
        print(id);
      });
    }).catchError((onError) {
      print("ERROR ---- $onError");
    });
    return wallpaperBase + wallpaperId;
  }

  Future<List<AppWidget>> getWidgets(String id, BuildContext context) async {
    RestDataSource api = RestDataSource();
    await api
        .getWidgets(id, GlobalUtils.activeToken.accessToken, context)
        .then((dynamic obj) {
      parts._widgets = List();
      obj.forEach((item) {
        parts._widgets.add(AppWidget.map(item));
      });
    }).catchError((onError) {
      print("ERROR ---- $onError");
    });

    return parts._widgets;
  }

  Future<List<BusinessApps>> getAppsData(String id) async {
    RestDataSource api = RestDataSource();
    await api
        .getAppsBusiness(id, GlobalUtils.activeToken.accessToken)
        .then((dynamic obj) {
      parts._appsData = List();
      obj.forEach((item) {
        if ((item['dashboardInfo']?.isEmpty ?? true) == false) {
          parts._appsData.add(BusinessApps.fromMap(item));
        }
      });
    }).catchError((onError) {
      print("ERROR ---- $onError");
    });

    return parts._appsData;
  }
}

class CustomCircleAvatar extends StatelessWidget {
  final String url;
  final String name;

  CustomCircleAvatar(this.url, this.name);

  @override
  Widget build(BuildContext context) {
    ImageProvider image;
    bool _haveImage;
    String displayName;

    if (url.contains("user") || url.contains("business")) {
      _haveImage = false;
      if (name.contains(" ")) {
        displayName = name.substring(0, 1);
        displayName = displayName + name.split(" ")[1].substring(0, 1);
      } else {
        displayName = name.substring(0, 1) + name.substring(name.length - 1);
        displayName = displayName.toUpperCase();
      }
    } else {
      _haveImage = true;
      image = CachedNetworkImageProvider(imageBase + url);
    }

    return Container(
      child: CircleAvatar(
        radius: Measurements.height * 0.04,
        backgroundColor:
            _haveImage ? Colors.transparent : Colors.grey.withOpacity(0.4),
        child: _haveImage
            ? CircleAvatar(
                radius: Measurements.height * 0.08,
                backgroundImage: image,
                backgroundColor: Colors.transparent,
              )
            : Text(displayName,
                style:
                    _isTablet ? Styles.noAvatarTablet : Styles.noAvatarPhone),
      ),
    );
  }
}

class CustomGrid extends StatefulWidget {
  @override
  _CustomGridState createState() => _CustomGridState();
}

class _CustomGridState extends State<CustomGrid> {
  @override
  Widget build(BuildContext context) {
    List<Widget> business = List();
    int index = 0;
    business.add(
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Container(
        child: Text("Business"),
        padding: EdgeInsets.symmetric(vertical: Measurements.height * 0.01),
      )
    ]));
    parts.businesses.forEach((f) {
      business.add(Container(
          key: Key("$index.switcher.icon"),
          child: GridItems(
            business: f,
          )));
      index++;
    });
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Wrap(
          spacing: Measurements.width * 0.075,
          runSpacing: Measurements.width * 0.01,
          alignment: WrapAlignment.center,
          direction: Axis.horizontal,
          children: business,
        ),
      ],
    );
  }
}

//___
