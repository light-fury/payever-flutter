import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../view_models/view_models.dart';
import '../network/network.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'webview_section.dart';

class OrderSection extends StatefulWidget {
  final Color textColor = Colors.black.withOpacity(0.7);
  final Color textColorOUT = Colors.orangeAccent;
  final PosStateModel parts;
  final ValueNotifier<bool> checkStock = ValueNotifier(false);
  final int index;
  final List<DropdownMenuItem<int>> quantities = List();

  OrderSection({@required this.parts, this.index});

  @override
  createState() => _OrderSectionState();
}

class _OrderSectionState extends State<OrderSection> {
  bool isPortrait = true;
  bool isTablet = false;

  @override
  void initState() {
    super.initState();
    widget.checkStock.addListener(listener);
  }

  listener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    PosCartStateModel cartStateModel = Provider.of<PosCartStateModel>(context);

    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    isTablet = isPortrait
        ? MediaQuery.of(context).size.width > 600
        : MediaQuery.of(context).size.height > 600;

    widget.quantities.clear();
    for (int i = 1; i < 100; i++) {
      final number = DropdownMenuItem(
        value: i,
        child: Text("$i"),
      );
      widget.quantities.add(number);
    }

    print("widget.parts.shoppingCart: ${widget.parts.shoppingCart}");

    return Column(
      children: <Widget>[
        Container(
          height: Measurements.height * 0.05,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: Text(
                Language.getCartStrings(
                    "checkout_cart_edit.form.label.product"),
                style: TextStyle(color: widget.textColor),
              )),
              Container(
                  alignment: Alignment.center,
                  width: Measurements.width * 0.15,
                  child: Text(
                    Language.getCartStrings(
                        "checkout_cart_edit.form.label.qty"),
                    style: TextStyle(color: widget.textColor),
                  )),
              Container(
                  alignment: Alignment.center,
                  width: Measurements.width * 0.2,
                  child: Text(
                    Language.getCartStrings(
                        "checkout_cart_edit.form.label.price"),
                    style: TextStyle(color: widget.textColor),
                  )),
            ],
          ),
        ),
        Divider(
          color: Colors.black.withOpacity(0.2),
          height: Measurements.height * 0.01,
        ),
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.parts.shoppingCart.items.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: <Widget>[
                Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        width: Measurements.width * 0.05,
                        height: Measurements.height * 0.1,
                        child: Center(
                            child: SvgPicture.asset(
                          "assets/images/xsinacircle.svg",
                          width: Measurements.width * (isTablet ? 0.02 : 0.04),
                        )),
                      ),
                      onTap: () {
                        print("click delete");
                        setState(() {
                          widget.parts.deleteProduct(index);

                          if (widget.parts.shoppingCart.items.isEmpty) {
                            cartStateModel.updateCart(false);
                          }
                        });
                      },
                    ),
                    Container(
                      height: Measurements.height * 0.09,
                      width: Measurements.height * 0.09,
                      padding: EdgeInsets.all(Measurements.width * 0.01),
                      child: widget.parts.shoppingCart.items[index].image !=
                              null
                          ? CachedNetworkImage(
                              imageUrl: Env.storage +
                                  "/products/" +
                                  widget.parts.shoppingCart.items[index].image,
                              placeholder: (context, url) => Container(),
                              errorWidget: (context, url, error) =>
                                  new Icon(Icons.error, color: Colors.black),
                              fit: BoxFit.contain,
                            )
                          : Center(
                              child: SvgPicture.asset(
                                "assets/assets/images/noimage.svg",
                                color: Colors.grey.withOpacity(0.7),
                                height: Measurements.height * 0.05,
                              ),
                            ),
                    ),
                    Expanded(
                        child: AutoSizeText(
                      widget.parts.shoppingCart.items[index].name,
                      style: TextStyle(
                          color: widget.parts.shoppingCart.items[index].inStock
                              ? widget.textColor
                              : widget.textColorOUT),
                    )),
                    Row(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: Theme(
                            data: ThemeData.light(),
                            child: Container(
                                child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton(
                                value: widget
                                    .parts.shoppingCart.items[index].quantity,
                                items: widget.quantities,
                                onChanged: (value) {
                                  setState(() {
                                    print(value);
                                    widget.parts.updateQty(
                                        index: index, quantity: value);
                                  });
                                },
                              ),
                            )),
                          ),
                        ),
                        Container(
                            alignment: Alignment.center,
                            width: Measurements.width * 0.2,
                            child: AutoSizeText(
                              "${Measurements.currency(widget.parts.getBusiness.currency)}${widget.parts.f.format(widget.parts.shoppingCart.items[index].price)}",
                              maxLines: 1,
                              style: TextStyle(color: widget.textColor),
                            )),
                      ],
                    ),
                  ],
                )),
                Divider(
                  color: Colors.black.withOpacity(0.2),
                  height: Measurements.height * 0.01,
                ),
              ],
            );
          },
        ),
        widget.parts.shoppingCart.items.isNotEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    height: Measurements.height * 0.06,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: Measurements.width * 0.01),
                            child: Text(
                                Language.getCartStrings(
                                    "checkout_cart_edit.form.label.subtotal"),
                                style: TextStyle(color: widget.textColor))),
                        Container(
                            alignment: Alignment.center,
                            width: Measurements.width * 0.2,
                            child: AutoSizeText(
                              "${Measurements.currency(widget.parts.getBusiness.currency)}${widget.parts.f.format(widget.parts.shoppingCart.total)}",
                              maxLines: 1,
                              style: TextStyle(color: widget.textColor),
                            )),
                      ],
                    ),
                  ),
                ],
              )
            : Container(
                height: Measurements.height * 0.1,
                alignment: Alignment.centerLeft,
                child: Container(
                    child: Text(
                        Language.getCartStrings(
                            "checkout_cart_edit.error.card_is_empty"),
                        style: TextStyle(color: widget.textColor))),
              ),
        Divider(
          color: Colors.black.withOpacity(0.2),
          height: Measurements.height * 0.01,
        ),
        widget.parts.shoppingCart.items.isNotEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    height: Measurements.height * 0.06,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: Measurements.width * 0.01),
                            child: Text(
                                Language.getCartStrings(
                                    "checkout_cart_edit.form.label.total"),
                                style: TextStyle(
                                    color: widget.textColor,
                                    fontWeight: FontWeight.bold))),
                        Container(
                            alignment: Alignment.center,
                            width: Measurements.width * 0.2,
                            child: AutoSizeText(
                              "${Measurements.currency(widget.parts.getBusiness.currency)}${widget.parts.f.format(widget.parts.shoppingCart.total)}",
                              maxLines: 1,
                              style: TextStyle(
                                  color: widget.textColor,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),
                ],
              )
            : Container(),
        Container(
          width: Measurements.width * (isTablet ? 0.6 : 0.9),
          height: Measurements.height * (isTablet ? 0.08 : 0.1),
          padding: EdgeInsets.symmetric(
              vertical: Measurements.height * (isTablet ? 0.01 : 0.02)),
          child: InkWell(
            child: Container(
                decoration: BoxDecoration(
                    color: widget.parts.shoppingCart.items.isNotEmpty
                        ? Colors.black
                        : Colors.grey.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: widget.checkStock.value
                      ? CircularProgressIndicator()
                      : Text(
                          Language.getCustomStrings(
                              "checkout_cart_edit.checkout"),
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                )),
            onTap: () {
              if (widget.parts.shoppingCart.items.isEmpty) {
                print("block");
              } else {
                if (!widget.checkStock.value) {
                  nextStep();
                }
              }
            },
          ),
        ),
      ],
    );
  }

  nextStep() {
    print("next Step ");
    widget.checkStock.value = true;
    bool ok2Checkout = true;
    widget.parts.shoppingCart.items.forEach((item) {
      PosApi()
          .getInventory(widget.parts.getBusiness.id,
              GlobalUtils.activeToken.accessToken, item.sku, context)
          .then((inv) {
        InventoryModel currentInv = InventoryModel.toMap(inv);

        bool isOut = currentInv.isTrackable
            ? (currentInv.stock - (currentInv.reserved ?? 0)) > item.quantity
            : true;

        if (!isOut) {
          ok2Checkout = false;
          item.inStock = false;
        } else {
          item.inStock = true;
        }
        if (item.sku == widget.parts.shoppingCart.items.last.sku) {
          if (ok2Checkout) {
            PosApi()
                .postStorageSimple(
                    GlobalUtils.activeToken.accessToken,
                    Cart.items2MapSimple(widget.parts.shoppingCart.items),
                    null,
                    true,
                    true,
                    "widget.phone.replaceAll(" "," ")",
                    DateTime.now()
                        .subtract(Duration(hours: 2))
                        .add(Duration(minutes: 1))
                        .toIso8601String(),
                    widget.parts.currentTerminal.channelSet,
                    widget.parts.smsEnabled)
                .then((obj) {
              widget.parts.shoppingCartID = obj["id"];
              Navigator.push(
                  context,
                  PageTransition(
                      child: WebViewPayments(
                        posStateModel: widget.parts,
                        url: widget.parts.url = Env.wrapper +
                            "/pay/restore-flow-from-code/" +
                            obj["id"] +
                            "?noHeaderOnLoading=true",
                      ),
                      type: PageTransitionType.fade));
            });
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text(Language.getCartStrings(
                  "checkout_cart_edit.error.products_not_available")),
            ));
          }
          widget.checkStock.value = false;
        }
      });
    });
  }
}
