import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/utils.dart';

class DashboardCard extends StatefulWidget {
  final String _appName;
  final ImageProvider _imageProvider;
  final Widget mainCard;
  final Widget secondCard;
  final dynamic handler;
  final bool _active;
  final bool isSingleActionButton;

  DashboardCard(this._appName, this._imageProvider, this.mainCard,
      this.secondCard, this.handler, this._active, this.isSingleActionButton);

  @override
  _DashboardCardState createState() =>
      _DashboardCardState(_appName, _imageProvider, mainCard, secondCard);
}

class _DashboardCardState extends State<DashboardCard>
    with TickerProviderStateMixin {
  bool _open = false;
  var _isLoading = ValueNotifier(false);
  String _appName;
  Widget mainCard;
  Widget secondCard;
  num pad;

  ImageProvider _imageProvider;

  _DashboardCardState(
      this._appName, this._imageProvider, this.mainCard, this.secondCard);

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    _isLoading.addListener(listen);
  }

  @override
  Widget build(BuildContext context) {
    bool _isPortrait =
        Orientation.portrait == MediaQuery.of(context).orientation;
    Measurements.height = (_isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width);
    Measurements.width = (_isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height);
    bool _isTablet = Measurements.width < 600 ? false : true;
    double _cardSize = Measurements.height * (_isTablet ? 0.04 : 0.065);
    pad = _isTablet ? 0.02 : 0.04;

    if (!widget._active) _open = false;
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return Container(
          padding: EdgeInsets.all(Measurements.width * 0.02),
          child: Column(
            children: <Widget>[
              AnimatedContainer(
                duration: Duration(milliseconds: 50),
                width: Measurements.width *
                    (_isTablet ? 0.7 : (_isPortrait ? 0.9 : 1.3)),
                child: Container(
                  child: ClipRRect(
                    borderRadius: !_open
                        ? BorderRadius.circular(12)
                        : BorderRadius.only(
                            topRight: Radius.circular(12),
                            topLeft: Radius.circular(12)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 16),
                      child: Container(
                        color: Colors.black.withOpacity(0.2),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                left: Measurements.width * pad,
                                top: Measurements.width * pad,
                                right: Measurements.width * pad,
                                bottom: Measurements.width * pad / 2,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                          height:
                                              AppStyle.iconDashboardCardSize(
                                                  _isTablet),
                                          child: Image(image: _imageProvider)),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: Measurements.width *
                                                (_isTablet ? 0.01 : 0.02)),
                                      ),
                                      Text(Language.getWidgetStrings(
                                          "widgets.${widget._appName}.title")),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        child: ClipRect(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              widget.isSingleActionButton
//                                                  ? singleActionButtonWidget(
//                                                      context, _isTablet)
                                                  ? Container()
                                                  : actionButtonsWidget(
                                                      context,
                                                      _isTablet,
                                                      widget._active),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: Measurements.width * 0.02),
                                      ),
                                      widget._active
                                          ? InkWell(
                                              radius: _isTablet
                                                  ? Measurements.height * 0.02
                                                  : Measurements.width * 0.07,
                                              splashColor: Colors.transparent,
                                              child: widget.isSingleActionButton
                                                  ? Container()
                                                  : Container(
                                                      height: _isTablet
                                                          ? Measurements
                                                                  .height *
                                                              0.02
                                                          : Measurements.width *
                                                              0.06,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical:
                                                                  _isTablet
                                                                      ? 3
                                                                      : 4),
                                                      child: Text(_open
                                                          ? Language
                                                              .getWidgetStrings(
                                                                  "widgets.actions.less")
                                                          : Language
                                                              .getWidgetStrings(
                                                                  "widgets.actions.more"))),
                                              onTap: () {
                                                setState(() => _open = !_open);
                                              },
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.only(
                                    bottom: Measurements.width * pad,
                                    left: Measurements.width * pad,
                                    right: Measurements.width * pad),
                                child: mainCard),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                padding: EdgeInsets.all(0.01),
                height: _open && widget._active
                    ? (_cardSize * (_isTablet ? 2.2 : 1.6))
                    : 0,
                width: Measurements.width *
                    (_isTablet ? 0.7 : (_isPortrait ? 0.9 : 1.3)),
                child: Container(
                  margin: EdgeInsets.all(0.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 8),
                      child: Container(
                        color: Colors.black.withOpacity(0.25),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Container(
                                padding:
                                    EdgeInsets.all(Measurements.width * pad),
                                child:
                                    widget._active ? secondCard : Container()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                duration: Duration(milliseconds: 100),
              )
            ],
          ),
        );
      },
    );
  }

  void listen() {
    setState(() {});
  }

  Widget singleActionButtonWidget(BuildContext context, bool _isTablet) {
    return InkWell(
      radius:
          _isTablet ? Measurements.height * 0.02 : Measurements.width * 0.07,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: Measurements.width * 0.02),
          //width: widget._active ?50:120,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
          ),
          height: _isTablet
              ? Measurements.height * 0.02
              : Measurements.width * 0.07,
          child: Center(
            child:
                // _isLoading.value
                //     ? Container(
                //     constraints: BoxConstraints(
                //       maxWidth: _isTablet
                //           ? Measurements.height * 0.01
                //           : Measurements.width * 0.04,
                //       maxHeight: _isTablet
                //           ? Measurements.height * 0.01
                //           : Measurements.width * 0.04,
                //     ),
                //     child: CircularProgressIndicator(
                //       strokeWidth: 2,
                //     ))
                //     :
                Container(
                    alignment: Alignment.center,
                    child: Text(Language.getConnectStrings("actions.open"))),
          )),
      onTap: () {
        setState(() {
          // _isLoading.value = true;
          widget.handler.loadScreen(context, _isLoading);
        });
      },
    );
  }

  Widget actionButtonsWidget(
      BuildContext context, bool _isTablet, bool isActive) {
    //print("${widget._appName}.card.open");
    return isActive
        ? InkWell(
            key: Key("${widget._appName}.card.open"),
            radius: _isTablet
                ? Measurements.height * 0.02
                : Measurements.width * 0.07,
            child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: Measurements.width * 0.02),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                height: _isTablet
                    ? Measurements.height * 0.02
                    : Measurements.width * 0.07,
                child: Center(
                  child:
                      // _isLoading.value
                      //     ? Container(
                      //     constraints: BoxConstraints(
                      //       maxWidth: _isTablet
                      //           ? Measurements.height * 0.01
                      //           : Measurements.width * 0.04,
                      //       maxHeight: _isTablet
                      //           ? Measurements.height * 0.01
                      //           : Measurements.width * 0.04,
                      //     ),
                      //     child: CircularProgressIndicator(
                      //       strokeWidth: 2,
                      //     ))
                      //     :
                      Container(
                          alignment: Alignment.center,
                          child:
                              Text(Language.getConnectStrings("actions.open"))),
                )),
            onTap: () {
              setState(() {
                // _isLoading.value = true;
                widget.handler.loadScreen(context, _isLoading);
              });
            },
          )
        : Container(
            child: InkWell(
            child: Container(
                height: _isTablet
                    ? Measurements.height * 0.02
                    : Measurements.width * 0.07,
                child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.asset(
                          "images/launchicon.svg",
                          height:
                              Measurements.width * (_isTablet ? 0.015 : 0.03),
                          color: Colors.white.withOpacity(0.7),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: Measurements.width * 0.008),
                        ),
                        Text(
                          "Learn more",
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                      ],
                    ))),
            onTap: () {
              setState(() {
                isActive
                    ? widget.handler.loadScreen(context, _isLoading)
                    : _launchURL(widget.handler.learnMore());
              });
            },
          ));
  }
}

abstract class CardContract {
  void loadScreen(BuildContext context, ValueNotifier state);

  String learnMore();
}
