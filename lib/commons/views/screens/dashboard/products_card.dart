import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../../utils/utils.dart';
import '../../../models/models.dart';
import '../../../network/network.dart';
import '../../../view_models/view_models.dart';
import 'dashboard_card.dart';

import '../../../../products/views/views.dart';

class ProdParts {
  double _cardSize;
  bool _isTablet;
  bool _noProd = false;

  String help;
  String _wallpaper;

  Business business;
  Products _week;
  Products _month;
  List<Products> _lastSales = List();

  ValueNotifier _isLoadingLW = ValueNotifier(true);
  ValueNotifier _isLoadingLM = ValueNotifier(true);
  ValueNotifier _isLoadingLS = ValueNotifier(true);
  ValueNotifier _noProducts = ValueNotifier(false);
}

class ProdNavigation implements CardContract {
  ProdParts parts;

  ProdNavigation(this.parts);

  @override
  String learnMore() {
    return parts.help;
  }

  @override
  void loadScreen(BuildContext context, ValueNotifier state) {
//    RestDataSource api = RestDataSource();
    state.value = false;
    Navigator.push(
        context,
        PageTransition(
            child: ProductScreen(
              business: parts.business,
              wallpaper: parts._wallpaper,
              posCall: false,
            ),
            type: PageTransitionType.fade));
  }
}

class ProductsCard extends StatefulWidget {
  final String _appName;
  final ImageProvider _imageProvider;
  final String help;

  ProductsCard(this._appName, this._imageProvider, this.help);

  @override
  createState() => _ProductsCardState();
}

class _ProductsCardState extends State<ProductsCard> {
  String _wallpaper;
  Business _business;
  ProdParts parts;
//  ProdNavigation _posNavigation;

  @override
  void initState() {
    super.initState();
    setState(() {
      parts = ProdParts();
      parts.help = widget.help;
      parts.business = _business;
      parts._isLoadingLW.value = true;
      parts._isLoadingLM.value = true;
      parts._wallpaper = _wallpaper;
    });
  }

  fetchData() async {
    RestDataSource api = RestDataSource();
    api
        .getProductsPopularWeek(
            parts.business.id, GlobalUtils.activeToken.accessToken, context)
        .then((weekRes) {
      if (weekRes.isNotEmpty) {
        parts._week = Products.toMap(weekRes[0]);
        parts._isLoadingLW.value = false;
      } else {}
    });
    api
        .getProductsPopularMonth(
            parts.business.id, GlobalUtils.activeToken.accessToken, context)
        .then((monthRes) {
      if (monthRes.isNotEmpty) {
        parts._month = Products.toMap(monthRes[0]);
        parts._isLoadingLM.value = false;
      } else {
        parts._noProducts.value = true;
        parts._noProd = true;
      }
    });
    api
        .getProductLastSold(
            parts.business.id, GlobalUtils.activeToken.accessToken, context)
        .then((lastSales) {
      if (lastSales.isNotEmpty) {
        lastSales.forEach((sale) {
          if (parts._lastSales.length < 3)
            parts._lastSales.add(Products.toMap(sale));
        });
        parts._isLoadingLS.value = false;
      } else {
        parts._noProducts.value = true;
      }
    });
  }

  GlobalStateModel globalStateModel;

  @override
  Widget build(BuildContext context) {
    globalStateModel = Provider.of<GlobalStateModel>(context);
    parts.business = globalStateModel.currentBusiness;
    parts._isTablet = Measurements.width > 600;
    parts._cardSize = Measurements.height * (parts._isTablet ? 0.03 : 0.055);
    fetchData();
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return DashboardCard(
            widget._appName,
            widget._imageProvider,
            MainProductCard(parts),
            SecondProductCard(parts),
            ProdNavigation(parts),
            !parts._noProd,
            false);
      },
    );
  }
}

class MainProductCard extends StatefulWidget {
  final ProdParts parts;

  MainProductCard(this.parts);

  @override
  createState() => _MainProductCardState();
}

class _MainProductCardState extends State<MainProductCard> {
  bool _isPortrait;
  TextStyle style;

  _MainProductCardState();

  @override
  void initState() {
    super.initState();
    widget.parts._isLoadingLW.addListener(listener);
    widget.parts._isLoadingLM.addListener(listener);
    widget.parts._noProducts.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        _isPortrait =
            MediaQuery.of(context).orientation == Orientation.portrait;
        style = TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: widget.parts._isTablet ? 17 : 16,
            fontWeight: FontWeight.bold);
        List<Widget> listW;
        List<Widget> listM;
        if (!widget.parts._isLoadingLW.value)
          listW = widList(widget.parts._week.thumbnail, widget.parts._week.name,
              widget.parts._week.quantity, false);
        if (!widget.parts._isLoadingLM.value)
          listM = widList(widget.parts._month.thumbnail,
              widget.parts._month.name, widget.parts._month.quantity, true);
        return widget.parts._noProducts.value
            ? NoProducts(widget.parts)
            : Container(
                height: widget.parts._cardSize *
                    (widget.parts._isTablet ? 2.5 : _isPortrait ? 2.3 : 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      width: (Measurements.width *
                          (widget.parts._isTablet
                              ? 0.125
                              : (_isPortrait ? 0.21 : 0.24))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AutoSizeText(
                              Language.getWidgetStrings(
                                  "widgets.products.most-popular"),
                              style: style),
                        ],
                      ),
                    ),
                    VerticalDivider(),
                    widget.parts._isLoadingLW.value
                        ? Container()
                        : productsCardPart(listW, widget.parts._isLoadingLW),
                    widget.parts._isLoadingLM.value
                        ? Container()
                        : productsCardPart(listM, widget.parts._isLoadingLM),
                  ],
                ),
              );
      },
    );
  }

  void listener() {
    setState(() {});
  }

  Container productsCardPart(List<Widget> list, loading) {
    double imageSize =
        Measurements.width * (widget.parts._isTablet ? 0.05 : 0.1);
    return Container(
      width: (Measurements.width *
          (widget.parts._isTablet ? 0.25 : (_isPortrait ? 0.28 : 0.5))),
      child: !widget.parts._isTablet && _isPortrait
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: loading.value
                  ? <Widget>[
                      Container(
                          padding: EdgeInsets.all(Measurements.width * 0.05),
                          width: imageSize,
                          height: imageSize,
                          child: CircularProgressIndicator())
                    ]
                  : list,
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: loading.value
                  ? <Widget>[
                      Container(
                          padding: EdgeInsets.all(Measurements.width * 0.05),
                          width: imageSize,
                          height: imageSize,
                          child: CircularProgressIndicator())
                    ]
                  : list,
            ),
    );
  }

  List<Widget> widList(thumbnail, name, quantity, month) {
    return <Widget>[
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          image: thumbnail != null
              ? DecorationImage(
                  image: NetworkImage(!thumbnail.toString().contains("https://")
                      ? Env.storage + "/products/" + thumbnail
                      : thumbnail))
              : DecorationImage(image: AssetImage("")),
        ),
        width: (Measurements.width *
            (widget.parts._isTablet ? 0.08 : (_isPortrait ? 0.13 : 0.15))),
        height: (Measurements.width *
            (widget.parts._isTablet ? 0.08 : (_isPortrait ? 0.13 : 0.15))),
        child: thumbnail == null
            ? Center(
                child: SvgPicture.asset(
                "assets/images/noimage.svg",
                color: Colors.black.withOpacity(0.3),
              ))
            : Container(),
      ),
      Padding(
        padding: widget.parts._isTablet
            ? EdgeInsets.all(Measurements.width * 0.005)
            : EdgeInsets.zero,
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
            style: TextStyle(
                fontSize: widget.parts._isTablet ? 17 : 12,
                fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                "$quantity ",
                style: TextStyle(
                    fontSize: widget.parts._isTablet ? 23 : 13,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                quantity == 1
                    ? Language.getWidgetStrings("widgets.store.product.item")
                    : Language.getWidgetStrings("widgets.store.product.items"),
                style: TextStyle(fontSize: widget.parts._isTablet ? 18 : 12),
              ),
            ],
          ),
          widget.parts._isTablet
              ? Padding(
                  padding: EdgeInsets.all(Measurements.width * 0.001),
                )
              : Container(),
          Text(
            month
                ? Language.getWidgetStrings(
                    "widgets.products.popular-lastMonth")
                : Language.getWidgetStrings(
                    "widgets.products.popular-lastWeek"),
            style: TextStyle(
                fontSize: widget.parts._isTablet ? 15 : 12,
                color: Colors.white.withOpacity(0.7)),
          ),
        ],
      )
    ];
  }
}

class SecondProductCard extends StatefulWidget {
  final ProdParts parts;

  SecondProductCard(this.parts);

  @override
  createState() => _SecondProductCardState();
}

class _SecondProductCardState extends State<SecondProductCard> {
  List<Widget> sales = List();

  _SecondProductCardState();

  @override
  void initState() {
    super.initState();
    widget.parts._isLoadingLS.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.parts._isLoadingLS.value) sales = List();
    widget.parts._lastSales.forEach((sale) {
      sales.add(ProdLastSale(widget.parts, sale));
    });
    return Container(
      child: widget.parts._isLoadingLS.value
          ? CircularProgressIndicator()
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: sales),
    );
  }

  void listener() {
    setState(() {});
  }
}

class ProdLastSale extends StatefulWidget {
  final ProdParts parts;
  final Products current;

  ProdLastSale(this.parts, this.current);

  @override
  createState() => _ProdLastSaleState();
}

class _ProdLastSaleState extends State<ProdLastSale> {
  @override
  Widget build(BuildContext context) {
    bool _isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    var thumbnail = widget.current.thumbnail;
    return Container(
      width: (Measurements.width *
              (widget.parts._isTablet ? 0.7 : (_isPortrait ? 0.9 : 1.3))) /
          3.3,
      child: Row(
        children: <Widget>[
          Container(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                image: thumbnail != null
                    ? DecorationImage(
                        image: NetworkImage(!widget.current.thumbnail
                                .toString()
                                .contains("https://")
                            ? Env.storage +
                                "/products/" +
                                widget.current.thumbnail
                            : widget.current.thumbnail))
                    : DecorationImage(image: AssetImage("")),
              ),
              width: (Measurements.width *
                  (widget.parts._isTablet ? 0.05 : (_isPortrait ? 0.1 : 0.15))),
              height: (Measurements.width *
                  (widget.parts._isTablet ? 0.05 : (_isPortrait ? 0.1 : 0.15))),
              child: thumbnail == null
                  ? Center(
                      child: SvgPicture.asset(
                      "assets/images/noimage.svg",
                      color: Colors.black.withOpacity(0.3),
                    ))
                  : Container(),
            ),
          ),
          Padding(padding: EdgeInsets.only(left: Measurements.width * 0.01)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  width: ((Measurements.width *
                              (widget.parts._isTablet
                                  ? 0.7
                                  : (_isPortrait ? 0.9 : 1.3))) /
                          3.3) -
                      ((Measurements.width *
                              (widget.parts._isTablet
                                  ? 0.05
                                  : (_isPortrait ? 0.1 : 0.15))) +
                          (Measurements.width * 0.01)),
                  child: Text(
                    "${widget.current.name}",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  )),
              Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "${widget.current.quantity} ",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(
                        widget.current.quantity == 1
                            ? Language.getWidgetStrings(
                                "widgets.store.product.item")
                            : Language.getWidgetStrings(
                                "widgets.store.product.items"),
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              Container(
                  width: ((Measurements.width *
                              (widget.parts._isTablet
                                  ? 0.7
                                  : (_isPortrait ? 0.9 : 1.3))) /
                          3.3) -
                      ((Measurements.width *
                              (widget.parts._isTablet
                                  ? 0.05
                                  : (_isPortrait ? 0.1 : 0.15))) +
                          (Measurements.width * 0.01)),
                  child: Text("${widget.current.lastSaleDays}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11, color: Colors.white.withOpacity(0.8)))),
            ],
          )
        ],
      ),
    );
  }
}

class NoProducts extends StatelessWidget {
  final ProdParts parts;

  NoProducts(this.parts);

  @override
  Widget build(BuildContext context) {
    double _cardSize = Measurements.height * (parts._isTablet ? 0.03 : 0.07);
    return Container(
      child: Container(
        padding: EdgeInsets.only(
            bottom: Measurements.width * 0.05,
            left: Measurements.width * 0.03,
            right: Measurements.width * 0.03),
        height: _cardSize * (parts._isTablet ? 2.5 : 2),
        child: Center(
          child: InkWell(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: (_cardSize * (parts._isTablet ? 2.5 : 2)) / 2,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.white.withOpacity(0.1),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Start adding your first product",
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
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      child: ProductScreen(
                        business: parts.business,
                        wallpaper: parts._wallpaper,
                        posCall: false,
                      ),
                      type: PageTransitionType.fade));
            },
          ),
        ),
      ),
    );
  }
}
