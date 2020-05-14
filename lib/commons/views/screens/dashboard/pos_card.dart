import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:payever/commons/views/screens/dashboard/dashboard_app_installed.dart';
import 'package:provider/provider.dart';

import '../../../models/models.dart';
import '../../../network/network.dart';
import '../../../utils/utils.dart';
import '../../../view_models/view_models.dart';
import '../../custom_elements/custom_elements.dart';

import '../../../../pos/view_models/pos_state_model.dart';
import '../../../../pos/network/network.dart';
import '../../../../pos/views/pos_products_list_screen.dart';

import 'dashboard_screen_ref.dart';
import 'dashboard_card.dart';
import 'dashboard_card_ref.dart';

class POSCard extends StatefulWidget {
  final String _appName;
  final ImageProvider _imageProvider;
  final String _help;

  POSCard(this._appName, this._imageProvider, this._help);

  @override
  createState() => _POSCardState();
}

class _POSCardState extends State<POSCard> {
  GlobalStateModel globalStateModel;

  Business _business;
  POSCardParts _parts;
  POSNavigation _posNavigation;

  @override
  void initState() {
    super.initState();

    setState(() {
      _parts = POSCardParts(widget._help, _business);
      _posNavigation = POSNavigation(_parts);
    });
  }

  fetchData() {
    RestDataSource api = RestDataSource();
    api
        .getTerminal(_business.id, GlobalUtils.activeToken.accessToken, context)
        .then((terminals) {
      terminals.forEach((terminal) {
        _parts._terminals.add(Terminal.toMap(terminal));
      });
      if (terminals.isEmpty) {
        _parts._noTerminals = true;
        _parts._mainCardLoading.value = false;
      }
    }).then((_) {
      api
          .getChannelSet(
              _business.id, GlobalUtils.activeToken.accessToken, context)
          .then((channelSets) {
        channelSets.forEach((channelSet) {
          _parts._chSets.add(ChannelSet.toMap(channelSet));
        });
      }).then((_) {
        _parts.terminals.forEach((terminal) {
          _parts._chSets.forEach((channelSett) {
            if (terminal.channelSet == channelSett.id) {
              api
                  .getCheckoutIntegration(_business.id, channelSett.checkout,
                      GlobalUtils.activeToken.accessToken, context)
                  .then((paymentMethods) {
                paymentMethods.forEach((pm) {
                  terminal.paymentMethods.add(pm);
                });
                api
                    .getLastWeek(_business.id, channelSett.id,
                        GlobalUtils.activeToken.accessToken, context)
                    .then((days) {
                  int length = days.length - 1;
                  for (int i = length; i > length - 7; i--) {
                    terminal.lastWeekAmount += Day.map(days[i]).amount;
                  }
                  days.forEach((day) {
                    terminal.lastWeek.add(Day.map(day));
                  });
                  api
                      .getPopularWeek(_business.id, channelSett.id,
                          GlobalUtils.activeToken.accessToken, context)
                      .then((products) {
                    products.forEach((product) {
                      terminal.bestSales.add(Product.toMap(product));
                    });
                  }).then((_) {
                    _parts._secondCardLoading.value = false;
                  });
                });
              }).then((_) {
                for (int i = 0; i < _parts._terminals.length; i++) {
                  _parts._terminalCards.add(TerminalCard(_parts, i));
                  _parts._salesCards.add(ProductCard(_parts, i));
                }
                _parts.index.value =
                    _parts._terminals.indexWhere((term) => term.active);
                print("${_parts.terminals.last.id} = ${terminal.id}");
                //if((terminal.id == widget._parts.terminals.last.id) && (widget._parts._chSets.last.id == channelSet.id) ){
                if ((terminal.id == _parts.terminals.last.id)) {
                  _parts._mainCardLoading.value = false;
                }
                CardParts.currentTerminal =
                    _parts._terminals[_parts.index.value];
                DashboardStateModel dashboardStateModel =
                    Provider.of<DashboardStateModel>(context);
                dashboardStateModel
                    .setActiveTerminal(_parts._terminals[_parts.index.value]);
              });
            }
          });
        });
        //setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    globalStateModel = Provider.of<GlobalStateModel>(context);
    _business = globalStateModel.currentBusiness;
    _parts._wallpaper = globalStateModel.currentWallpaper;
    fetchData();
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        _parts._isPortrait =
            Orientation.portrait == MediaQuery.of(context).orientation;
        Measurements.height = (_parts._isPortrait
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.width);
        Measurements.width = (_parts._isPortrait
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.height);
        _parts._isTablet = Measurements.width < 600 ? false : true;
        return DashboardCard(
            widget._appName,
            widget._imageProvider,
            MainPOSCard(_parts),
            POSSecondCard(_parts),
            _posNavigation,
            !_parts._noTerminals,
            false);
      },
    );
  }
}

class POSCardParts {
  Business business;
  String _wallpaper;
  List<Terminal> _terminals = List();
  List<TerminalCard> _terminalCards = List();

  List<Terminal> get terminals => _terminals;
  List<ProductCard> _salesCards = List();

  List<ProductCard> get salesCards => _salesCards;

  num _lastWeek = 0;

  List<ChannelSet> _chSets = List();

  List<ChannelSet> get chSets => _chSets;

  List<String> _paymentMethods = List();

  List<String> get paymentMethods => _paymentMethods;

  var _mainCardLoading = ValueNotifier(true);
  var _secondCardLoading = ValueNotifier(true);
  var index = ValueNotifier(0);

//  Widget _mainCard;
//  Widget _secondCard;

  bool _isTablet = false;
  bool _isPortrait = true;
  bool _noTerminals = false;

  String imageBase = Env.storage + 'assets/images/';
  String help;

  String numberFilter(double n, bool chart) {
    var million = NumberFormat("##0.00", "en_US");
    var thousand = NumberFormat("##0.0", "en_US");
    var hundred = NumberFormat("##0.0", "en_US");
    bool dec;
    if (!chart) {
      print(_wallpaper);
      print(_lastWeek);
      if (n >= 10000 && n < 1000000) {
        n = (n / 1000);
        dec = n.truncate() - n == 0.0;
        return thousand.format(n) + "k";
      } else if (n > 1000000) {
        n = n / 1000000;
        return million.format(n) + "M";
      } else {
        dec = n.truncate() - n == 0.0;
        print(dec);
        return hundred.format(n);
      }
    } else {
      if (n > 1000 && n < 1000000) {
        n = (n / 1000);
        return thousand.format(n) + "k";
      } else if (n > 1000000) {
        n = n / 1000000;
        return million.format(n) + "M";
      } else {
        return hundred.format(n);
      }
    }
  }

  POSCardParts(this.help, this.business);
}

class POSNavigation implements CardContract {
  POSCardParts _parts;

  POSNavigation(this._parts);

  @override
  void loadScreen(BuildContext context, ValueNotifier state) {
    state.value = false;
//    Navigator.push(context, PageTransition(child:NativePosScreen(terminal:_parts._terminals[_parts.index.value],business:Provider.of<GlobalStateModel>(context).currentBusiness),type:PageTransitionType.fade));
    Navigator.push(
        context,
        PageTransition(
            child: PosProductsListScreen(
                terminal: _parts._terminals[_parts.index.value],
                business:
                    Provider.of<GlobalStateModel>(context).currentBusiness),
            type: PageTransitionType.fade));
  }

  @override
  String learnMore() {
    return _parts.help;
  }
}

class MainPOSCard extends StatefulWidget {
  final POSCardParts _parts;

  MainPOSCard(this._parts);

  @override
  createState() => _MainPOSCardState();
}

class _MainPOSCardState extends State<MainPOSCard> {
  double _cardSize;

  @override
  void initState() {
    super.initState();
    widget._parts._mainCardLoading.addListener(listener);
    widget._parts.index.addListener(listener);

    setState(() {
      _cardSize = Measurements.height * (widget._parts._isTablet ? 0.03 : 0.07);
    });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        widget._parts._isPortrait =
            Orientation.portrait == MediaQuery.of(context).orientation;
        return !widget._parts._noTerminals
            ? Container(
                height: _cardSize * (widget._parts._isTablet ? 2.5 : 2),
                child: (!widget._parts._mainCardLoading.value &&
                        widget._parts.index.value != -1)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          widget
                              ._parts._terminalCards[widget._parts.index.value],
                          InkWell(
                            child: Container(
                              width: Measurements.width * 0.1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  widget._parts._terminals.length > 1
                                      ? SvgPicture.asset(
                                          "images/arrowposicon.svg",
                                          color: Colors.white.withOpacity(0.6),
                                          height: (_cardSize *
                                              (widget._parts._isTablet
                                                  ? 2.5
                                                  : 2) *
                                              0.5),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                if (widget._parts._terminals.length > 1) {
                                  widget._parts.index.value = widget
                                              ._parts.index.value ==
                                          (widget._parts._terminals.length - 1)
                                      ? widget._parts.index.value = 0
                                      : widget._parts.index.value + 1;
                                }
                              });
                            },
                          ),
                        ],
                      )
                    : Center(child: CircularProgressIndicator()),
              )
            : !widget._parts._mainCardLoading.value
                ? NoTerminalWidget(widget._parts)
                : Center(child: CircularProgressIndicator());
      },
    );
  }

  void listener() {
    setState(() {});
  }
}

class TerminalCard extends StatefulWidget {
  final POSCardParts _parts;
  final int index;

  TerminalCard(this._parts, this.index);

  @override
  _TerminalCardState createState() => _TerminalCardState();
}

class _TerminalCardState extends State<TerminalCard> {
  String initials(String name) {
    String displayName;
    if (name.contains(" ")) {
      displayName = name.substring(0, 1);
      displayName = displayName + name.split(" ")[1].substring(0, 1);
    } else {
      displayName = name.substring(0, 1) + name.substring(name.length - 1);
    }
    return displayName = displayName.toUpperCase();
  }

  double _cardSize;

  @override
  void initState() {
    super.initState();

    setState(() {
      _cardSize = Measurements.height * (widget._parts._isTablet ? 0.07 : 0.13);
    });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        widget._parts._isPortrait =
            Orientation.portrait == MediaQuery.of(context).orientation;
        var cardRadius = _cardSize / (widget._parts._isTablet ? 2.5 : 2.8);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            widget._parts._terminals[widget.index].logo != null
                ? CircleAvatar(
                    backgroundColor: Colors.grey.withOpacity(0.5),
                    radius: cardRadius,
                    backgroundImage: NetworkImage(widget._parts.imageBase +
                        widget._parts._terminals[widget.index].logo),
                  )
                : CircleAvatar(
                    backgroundColor: Colors.grey.withOpacity(0.5),
                    radius: cardRadius,
                    child: Container(
                      child: Container(
                        child: Text(
                          initials(widget._parts._terminals[widget.index].name),
                          style: widget._parts._isTablet
                              ? Styles.noAvatarTablet
                              : Styles.noAvatarPhone,
                        ),
                      ),
                    ),
                  ),
            Padding(padding: EdgeInsets.only(left: Measurements.width * 0.02)),
            Container(
              width: Measurements.width *
                  (widget._parts._isTablet
                      ? (0.22)
                      : (widget._parts._isPortrait ? 0.26 : 0.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AutoSizeText(
                    "${widget._parts.terminals[widget.index].name}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: widget._parts._isTablet ? 20 : 15),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: Measurements.width *
                            (widget._parts._isTablet ? 0.02 : 0.025)),
                  ),
                  InkWell(
                    child: Container(
                      child: Text(
                        Language.getConnectStrings("actions.edit"),
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: Measurements.width * 0.005,
                          horizontal: Measurements.width * 0.03),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey.withOpacity(0.6)),
                    ),
                    onTap: () {
//                      Navigator.push(
//                          context,
//                          PageTransition(
//                              child: EditTerminal(
//                                  widget._parts._wallpaper,
//                                  widget
//                                      ._parts
//                                      ._terminals[widget._parts.index.value]
//                                      .name,
//                                  widget
//                                      ._parts
//                                      ._terminals[widget._parts.index.value]
//                                      .logo,
//                                  widget._parts
//                                      ._terminals[widget._parts.index.value].id,
//                                  widget
//                                      ._parts
//                                      ._terminals[widget._parts.index.value]
//                                      .business,
//                                  widget._parts._terminals[_parts.index.value],
//                                  widget._parts.business),
//                              type: PageTransitionType.fade));
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: Measurements.width *
                  (widget._parts._isTablet
                      ? (0.2)
                      : (widget._parts._isPortrait ? 0.22 : 0.4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      width: Measurements.width *
                          (widget._parts._isTablet
                              ? (0.2)
                              : (widget._parts._isPortrait ? 0.22 : 0.4)),
                      child: AutoSizeText(
                        Language.getWidgetStrings(
                            "widgets.pos.payment-methods"),
                        minFontSize: 8,
                        maxLines: 1,
                      )),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: Measurements.width *
                            (widget._parts._isTablet ? 0.02 : 0.025)),
                  ),
                  PaymentMethods(
                      widget._parts.terminals[widget.index].paymentMethods,
                      widget._parts._isTablet),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class PaymentMethods extends StatefulWidget {
  final List<String> pm;
  final bool _isTablet;

  PaymentMethods(this.pm, this._isTablet);

  @override
  createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods> {
  List<String> pmCleanD = List();

  @override
  Widget build(BuildContext context) {
    widget.pm.sort();
    List<Widget> pmIcons = List();
    pmCleanD = List();
    for (int i = 0; i < widget.pm.length; i++) {
      if (!pmCleanD.contains(Measurements.paymentType(widget.pm[i]))) {
        pmIcons.add(Container(
            padding: EdgeInsets.only(left: Measurements.width * 0.01),
            child: SvgPicture.asset(
              Measurements.paymentType(widget.pm[i]),
              height: Measurements.width * (widget._isTablet ? 0.025 : 0.04),
            )));
        pmCleanD.add(Measurements.paymentType(widget.pm[i]));
      }
    }

    return Container(
        child: Container(
            child: widget.pm.length == 0
                ? AutoSizeText(
                    Language.getWidgetStrings("widgets.pos.no-payments"),
                    maxLines: 2,
                    minFontSize: 10,
                    style: TextStyle(fontSize: 13),
                  )
                : Row(
                    children: pmIcons.sublist(
                        0, pmIcons.length < 5 ? pmIcons.length : 4))));
  }
}

class NoTerminalWidget extends StatelessWidget {
  final POSCardParts _parts;

  NoTerminalWidget(this._parts);

  @override
  Widget build(BuildContext context) {
    double _cardSize = Measurements.height * (_parts._isTablet ? 0.07 : 0.13);
    return Container(
      child: Container(
        padding: EdgeInsets.only(
            bottom: Measurements.width * 0.05,
            left: Measurements.width * 0.03,
            right: Measurements.width * 0.03),
        height: _cardSize,
        child: Center(
          child: InkWell(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: (_cardSize) / 2,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.white.withOpacity(0.1),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Start accepting payments locally 14 days for free",
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.7)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class POSSecondCard extends StatefulWidget {
  final POSCardParts _parts;

  POSSecondCard(this._parts);

  @override
  createState() => _POSSecondCardState();
}

class _POSSecondCardState extends State<POSSecondCard> {
  @override
  void initState() {
    super.initState();
    widget._parts.index.addListener(listener);
    widget._parts._secondCardLoading.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return !widget._parts._secondCardLoading.value
        ? Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        width: Measurements.width * 0.3,
                        child: Text(
                          Language.getWidgetStrings("widgets.pos.sale-7-days"),
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.5)),
                        )),
                    Text(
                      Language.getWidgetStrings(
                          "widgets.pos.top-sale-products"),
                      style: TextStyle(
                          fontSize: 13, color: Colors.white.withOpacity(0.5)),
                    ),
                  ],
                ),
                widget._parts.terminals[widget._parts.index.value].bestSales
                            .length <=
                        0
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.bottomLeft,
                              height: Measurements.width *
                                  (widget._parts._isTablet ? 0.04 : 0.09),
                              width: Measurements.width * 0.3,
                              child: Text(
                                "${widget._parts.terminals[widget._parts.index.value].lastWeekAmount > 0 ? (widget._parts.numberFilter(widget._parts.terminals[widget._parts.index.value].lastWeekAmount.toDouble(), false) + Measurements.currency(widget._parts.terminals[0].lastWeek[0].currency)) : "0.00 €"}",
                                style: TextStyle(fontSize: 20),
                              )),
                          Container(
                              alignment: Alignment.bottomCenter,
                              height: Measurements.width *
                                  (widget._parts._isTablet ? 0.04 : 0.09),
                              child: Text(
                                Language.getWidgetStrings(
                                    "widgets.store.no-products"),
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w300),
                              )),
                        ],
                      )
                    : widget._parts.salesCards[widget._parts.index.value],
              ],
            ),
          )
        : CircularProgressIndicator();
  }

  void listener() {
    setState(() {});
  }
}

class ProductCard extends StatefulWidget {
  final POSCardParts _parts;
  final num index;

  ProductCard(this._parts, this.index);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  List<ProductItem> topSales = List();
  var size = Measurements.width * 0.05;

  @override
  Widget build(BuildContext context) {
    topSales = List();
    int long =
        widget._parts.terminals[widget._parts.index.value].bestSales.length > 3
            ? 3
            : 1;
    for (int i = 0; i < long; i++) {
      topSales.add(ProductItem(
          widget._parts.terminals[widget._parts.index.value].bestSales[i]
              .thumbnail,
          widget._parts.terminals[widget._parts.index.value].bestSales[i],
          size,
          widget._parts._isTablet));
    }
    return Container(
      padding: EdgeInsets.only(top: Measurements.width * 0.01),
      child: Row(
        children: <Widget>[
          Container(
              width: Measurements.width * 0.3,
              child: Text(
                "${widget._parts.numberFilter(widget._parts.terminals[widget._parts.index.value].lastWeekAmount.toDouble(), false)} ${Measurements.currency(widget._parts.terminals[widget.index].lastWeek[0].currency)}",
                style: TextStyle(fontSize: 20),
              )),
          Container(
            child: Expanded(
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: topSales),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final String url;
  final Product _product;
  final num size;
  final bool _isTablet;

  ProductItem(this.url, this._product, this.size, this._isTablet);

  @override
  Widget build(BuildContext context) {
    print(_product);

    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: Measurements.width * 0.03),
          child: Container(
            height: size.toDouble() * (_isTablet ? 0.9 : 1.8),
            width: size.toDouble() * (_isTablet ? 0.9 : 1.8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              image: url != null
                  ? DecorationImage(image: NetworkImage(url))
                  : DecorationImage(image: AssetImage("")),
            ),
            child: url == null
                ? SvgPicture.asset("assets/images/noimage.svg")
                : Container(),
          ),
        ),
      ],
    );
  }
}

class SimplifyTerminal extends StatefulWidget {
  final String _appName;
  final ImageProvider _imageProvider;
  final bool dashboardApp;

  SimplifyTerminal(this._appName, this._imageProvider, {this.dashboardApp = false});

  @override
  createState() => _SimplifyTerminalState();
}

class _SimplifyTerminalState extends State<SimplifyTerminal> {
  int index = 0;

  List<Terminal> _terminals = List();
  List<SimpleTerminal> _terminalList = List();
  int active = 0;
  bool noTerminals = false;

  @override
  Widget build(BuildContext context) {
    index = 0;
    DashboardStateModel dashboardStateModel =
        Provider.of<DashboardStateModel>(context);
    if (!noTerminals) {
      if (dashboardStateModel.terminalList.isEmpty) {
        RestDataSource()
            .getTerminal(
                Provider.of<GlobalStateModel>(context).currentBusiness.id,
                GlobalUtils.activeToken.accessToken,
                context)
            .then((terminals) {
          terminals.forEach((terminal) {
            Terminal term = Terminal.toMap(terminal);
            if (term.active)
              active = index;
            else
              index++;
            _terminals.add(term);
            _terminalList.add(SimpleTerminal(Terminal.toMap(terminal)));
            SimpleTerminal temp = _terminalList.removeAt(active);
            _terminalList.insert(0, temp);
          });
          noTerminals = _terminals.isEmpty;
          dashboardStateModel.setTerminalList(_terminals);
          setState(() {
            print("SetState");
          });
        });
      } else {
        _terminals = dashboardStateModel.terminalList;
        _terminalList.clear();
        _terminals.forEach((terminal) {
          if (terminal.active) {
            active = index;
            dashboardStateModel.setActiveTerminal(terminal);
          } else
            index++;

          _terminalList.add(SimpleTerminal(terminal));
        });
        SimpleTerminal temp = _terminalList.removeAt(active);
        _terminalList.insert(0, temp);
      }
    }
    if (widget.dashboardApp == true) {
      return DashboardAppInstalled(
        widget._appName,
        widget._imageProvider,
        noTerminals
            ? NoItemsCard(
                Text(Language.getWidgetStrings("widgets.pos.install-app")), () {
                print("Click");
              })
            : _terminals.isNotEmpty
                ? _terminalList[0]
                : Center(child: CircularProgressIndicator()),
        body: _terminals.isEmpty
            ? null
            : _terminals.length > 1
                ? ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: _terminalList.sublist(1),
                  )
                : null,
      );
    }
    return DashboardCardRef(
      widget._appName,
      widget._imageProvider,
      noTerminals
          ? NoItemsCard(
              Text(Language.getWidgetStrings("widgets.pos.install-app")), () {
              print("Click");
            })
          : _terminals.isNotEmpty
              ? _terminalList[0]
              : Center(child: CircularProgressIndicator()),
      body: _terminals.isEmpty
          ? null
          : _terminals.length > 1
              ? ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: _terminalList.sublist(1),
                )
              : null,
    );
  }
}

class SimpleTerminal extends StatelessWidget {
  final Terminal currentTerminal;

//  bool active;

  SimpleTerminal(this.currentTerminal);

  @override
  Widget build(BuildContext context) {

    GlobalStateModel globalStateModel =
    Provider.of<GlobalStateModel>(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: currentTerminal.active ? 0 : 10),
      child: InkWell(
        highlightColor: Colors.transparent,
        child: AvatarDescriptionCard(
          currentTerminal.logo != null
              ? CachedNetworkImageProvider(
                  Env.storage + '/images/' + currentTerminal.logo)
              : null,
          currentTerminal.name,
          "Click to Open",
          imageTitle:
              currentTerminal.logo != null ? null : currentTerminal.name,
        ),
        onTap: () {
//          Navigator.push(context, PageTransition(child:NativePosScreen(terminal:currentTerminal,business:Provider.of<GlobalStateModel>(context).currentBusiness),type:PageTransitionType.fade));

          Navigator.push(
              context,
              PageTransition(
                  child: ChangeNotifierProvider<PosStateModel>(
                    builder: (BuildContext context) =>
                        PosStateModel(globalStateModel, PosApi()),
                    child: PosProductsListScreen(
                        terminal: currentTerminal,
                        business: globalStateModel.currentBusiness),
                  ),
                  type: PageTransitionType.fade,
                  duration: Duration(milliseconds: 50)));
        },
      ),
    );
  }
}
