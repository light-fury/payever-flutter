import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/models.dart';
import '../network/network.dart';
import '../utils/utils.dart';
import 'new_product.dart';

class ProductChannelsRow extends StatefulWidget {
  final NewProductScreenParts parts;

  ProductChannelsRow({this.parts});

  @override
  createState() => _ProductChannelsRowState();
}

class _ProductChannelsRowState extends State<ProductChannelsRow> {
  @override
  void initState() {
    super.initState();

    ProductsApi api = ProductsApi();
    widget.parts.terminals.clear();
    api
        .getTerminal(
            widget.parts.business, GlobalUtils.activeToken.accessToken, context)
        .then((terminals) {
      terminals.forEach((term) {
        widget.parts.terminals.add(Terminal.toMap(term));
      });
      setState(() {
        widget.parts.havePOS = terminals.isNotEmpty;
      });
    }).catchError((onError) {
      print(onError);
    });
    widget.parts.shops.clear();
    api
        .getShop(
            widget.parts.business, GlobalUtils.activeToken.accessToken, context)
        .then((shops) {
      shops.forEach((shop) {
        widget.parts.shops.add(Shop.toMap(shop));
      });
      setState(() {
        widget.parts.haveShop = shops.isNotEmpty;
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //POS
            widget.parts.havePOS
                ? Container(
                    height: Measurements.height *
                        (widget.parts.isTablet ? 0.05 : 0.07),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SvgPicture.asset(
                          "assets/images/posicon.svg",
                          height: AppStyle.iconTabSize(widget.parts.isTablet),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(right: Measurements.width * 0.02),
                        ),
                        Text(Language.getWidgetStrings("widgets.pos.title"),
                            style: TextStyle(
                                fontSize: AppStyle.fontSizeTabTitle()))
                      ],
                    ),
                  )
                : Container(),
            widget.parts.havePOS
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: widget.parts.terminals.length,
                        itemBuilder: (BuildContext context, int index) {
                          bool channelEnabled = false;
                          widget.parts.channels.forEach((ch) {
                            if (ch.id ==
                                widget.parts.terminals[index].channelSet)
                              channelEnabled = true;
                          });

                          return Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Measurements.width * 0.025),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(index ==
                                              (widget.parts.terminals.length -
                                                  1)
                                          ? 16
                                          : 0),
                                      bottomRight: Radius.circular(index ==
                                              (widget.parts.terminals.length -
                                                  1)
                                          ? 16
                                          : 0),
                                      topLeft:
                                          Radius.circular(index == 0 ? 16 : 0),
                                      topRight:
                                          Radius.circular(index == 0 ? 16 : 0)),
                                ),
                                height: Measurements.height *
                                    (widget.parts.isTablet ? 0.05 : 0.07),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(widget.parts.terminals[index].name,
                                        style: TextStyle(
                                            fontSize:
                                                AppStyle.fontSizeTabContent())),
                                    Switch(
                                      activeColor: widget.parts.switchColor,
                                      value: channelEnabled,
                                      onChanged: (bool value) {
                                        var term =
                                            widget.parts.terminals[index];
                                        if (value) {
                                          widget.parts.channels.add(ChannelSet(
                                              term.channelSet,
                                              term.name,
                                              GlobalUtils.CHANNEL_POS));
                                        } else {
                                          widget.parts.channels.removeWhere(
                                              (ch) => term.channelSet == ch.id);
                                        }
                                        setState(() {
                                          channelEnabled = value;
                                        });
                                      },
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: Measurements.width * 0.005),
                              ),
                            ],
                          );
                        },
                      ),
                    ))
                : Container(),
            //-----
            //SHOP
            widget.parts.haveShop
                ? Container(
                    height: Measurements.height *
                        (widget.parts.isTablet ? 0.05 : 0.07),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SvgPicture.asset(
                          "assets/images/shopicon.svg",
                          height: AppStyle.iconTabSize(widget.parts.isTablet),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(right: Measurements.width * 0.02),
                        ),
                        Text(Language.getWidgetStrings("widgets.store.title"),
                            style: TextStyle(
                                fontSize: AppStyle.fontSizeTabTitle()))
                      ],
                    ),
                  )
                : Container(),
            widget.parts.haveShop
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.parts.shops.length,
                      itemBuilder: (BuildContext context, int index) {
                        bool shopEnabled = false;
                        widget.parts.channels.forEach((ch) {
                          if (ch.id == widget.parts.shops[index].channelSet)
                            shopEnabled = true;
                        });
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Measurements.width * 0.025),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(
                                        index == (widget.parts.shops.length - 1)
                                            ? 16
                                            : 0),
                                    bottomRight: Radius.circular(
                                        index == (widget.parts.shops.length - 1)
                                            ? 16
                                            : 0),
                                    topLeft:
                                        Radius.circular(index == 0 ? 16 : 0),
                                    topRight:
                                        Radius.circular(index == 0 ? 16 : 0)),
                              ),
                              height: Measurements.height *
                                  (widget.parts.isTablet ? 0.05 : 0.07),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(widget.parts.shops[index].name,
                                      style: TextStyle(
                                          fontSize:
                                              AppStyle.fontSizeTabContent())),
                                  Switch(
                                    activeColor: widget.parts.switchColor,
                                    value: shopEnabled,
                                    onChanged: (bool value) {
                                      var shop = widget.parts.shops[index];
                                      if (value) {
                                        widget.parts.channels.add(ChannelSet(
                                            shop.channelSet,
                                            shop.name,
                                            GlobalUtils.CHANNEL_SHOP));
                                      } else {
                                        widget.parts.channels.removeWhere(
                                            (ch) => shop.channelSet == ch.id);
                                      }
                                      setState(() {
                                        shopEnabled = value;
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: Measurements.width * 0.005),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : Container(),
          ]),
    );
  }
}
