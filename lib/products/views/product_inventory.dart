import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:payever/products/views/product_screen.dart';

import '../models/models.dart';
import '../network/network.dart';
import '../view_models/view_models.dart';
import '../utils/utils.dart';
import 'new_product.dart';

class InventoryManagement {
  List<Inventory> inventories = List();

  addInventory(Inventory currentInv) {
    List<Inventory> _inventories = List();
    Inventory temp =
        Inventory(amount: null, barcode: null, sku: null, tracking: null);
    inventories.forEach((inv) {
      print(inv.sku);
      if (inv.sku != currentInv.sku) {
        _inventories.add(inv);
      } else {
        temp.amount = inv.amount;
      }
    });
    currentInv.amount = currentInv.amount ?? temp.amount ?? 0;
    _inventories.add(currentInv);
    inventories
      ..clear()
      ..addAll(_inventories);
  }

  printAll() {
    print("________________________");
    print("Invetories");
    inventories.forEach((inv) {
      print("Sku:       ${inv.sku}");
      print("NewAmount: ${inv.newAmount}");
      print("amount:    ${inv.amount}");
    });
    print("_______________________");
  }

  saveInventories(String businessID, BuildContext context,
      GlobalStateModel globalStateModel, bool isFromDashboardCard) {
    inventories.forEach((inventory) {
      num dif = (inventory.newAmount ?? 0) - (inventory.amount ?? 0);
      print("num dif = (inventory.newAmount??0) - (inventory.amount??0)");
      print("$dif = (${inventory.newAmount}) - (${inventory.amount})");
      print(dif);
      ProductsApi()
          .checkSKU(
        businessID,
        GlobalUtils.activeToken.accessToken,
        inventory.sku,
      )
          .then((onValue) async {
        if (inventory.newAmount != null)
          await ProductsApi()
              .patchInventory(businessID, GlobalUtils.activeToken.accessToken,
                  inventory.sku, inventory.barcode, inventory.tracking)
              .then((_) async {
            //if( dif != 0 && (inventory.newAmount != 0)){
            if (dif != 0) {
              dif > 0
                  ? await add(dif, inventory.sku, businessID)
                  : await sub(dif.abs(), inventory.sku, businessID);
            }
          });
        if (inventories.last.sku == inventory.sku) {
          Navigator.pop(context);
          Navigator.pop(context);
          if (!isFromDashboardCard) {
           Navigator.pop(context);
           Navigator.push(
               context,
               PageTransition(
                   child: ProductScreen(
                     wallpaper: globalStateModel.currentWallpaper,
                     business:  globalStateModel.currentBusiness,
                     posCall: false,
                   ),
                   type: PageTransitionType.fade));
          }
        }
      }).catchError((onError) {
        if (onError.toString().contains("404")) {
          ProductsApi()
              .postInventory(businessID, GlobalUtils.activeToken.accessToken,
                  inventory.sku, inventory.barcode, inventory.tracking)
              .then((_) {
            if (dif != 0 && (inventory.newAmount != 0)) {
              dif > 0
                  ? add(dif, inventory.sku, businessID)
                  : sub(dif.abs(), inventory.sku, businessID);
            }
            if (inventories.last.sku == inventory.sku) {
              Navigator.pop(context);
              Navigator.pop(context);
              if (!isFromDashboardCard) {
               Navigator.pop(context);
               Navigator.push(
                   context,
                   PageTransition(
                       child: ProductScreen(
                         wallpaper: globalStateModel.currentWallpaper,
                         business:  globalStateModel.currentBusiness,
                         posCall: false,
                       ),
                       type: PageTransitionType.fade));
              }
            }
          });
        }
      });
    });
  }

  Future add(num dif, String sku, String id) async {
    return ProductsApi()
        .patchInventoryAdd(id, GlobalUtils.activeToken.accessToken, sku, dif)
        .then((result) {
      print("$dif added");
    });
  }

  Future sub(num dif, String sku, String id) async {
    return ProductsApi()
        .patchInventorySubtract(
            id, GlobalUtils.activeToken.accessToken, sku, dif)
        .then((result) {
      print("$dif substracted");
    });
  }
}

class Inventory {
  String sku;
  String barcode;
  bool tracking;
  num amount;
  num newAmount;

  Inventory(
      {@required this.sku,
      @required this.barcode,
      this.amount,
      @required this.tracking,
      this.newAmount});
}

class ProductInventoryRow extends StatefulWidget {
  final NewProductScreenParts parts;

  ProductInventoryRow({@required this.parts});

  bool get isInventoryRowOK {
    return parts.product.variants.length > 0
        ? true
        : !parts.skuError;
  }

  @override
  createState() => _ProductInventoryRowState();
}

class _ProductInventoryRowState extends State<ProductInventoryRow> {


  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    print("widget.parts.business: ${widget.parts.business}");
    print("widget.parts.product: ${widget.parts.product}");
    _controller = TextEditingController(text: "0");
    if (widget.parts.editMode)
      ProductsApi()
          .getInventory(
              widget.parts.business,
              GlobalUtils.activeToken.accessToken,
              widget.parts.product.sku,
              context)
          .then((inv) {
        var _inv = InventoryModel.toMap(inv);
        widget.parts.invManager.inventories.add(Inventory(
            barcode: _inv.barcode,
            sku: _inv.sku,
            tracking: _inv.isTrackable,
            amount: _inv.stock));
        setState(() {
          widget.parts.prodTrackInv = _inv.isTrackable ?? false;
          widget.parts.prodStock = _inv.stock ?? 0;
          _controller = TextEditingController(
              text: widget.parts.editMode
                  ? widget.parts.prodStock.toString()
                  : "");
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Measurements.width * 0.025),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16))),
                        width: Measurements.width * 0.4475,
                        height: Measurements.height *
                            (widget.parts.isTablet ? 0.05 : 0.07),
                        child: TextFormField(
                          style: TextStyle(
                              fontSize: AppStyle.fontSizeTabContent()),
                          //controller: widget._controller,
                          initialValue: widget.parts.editMode
                              ? widget.parts.product.sku
                              : "",
                          inputFormatters: [
                            WhitelistingTextInputFormatter(
                                RegExp("[a-z A-Z 0-9 _]")),
                          ],
                          onSaved: (sku) {
                            print("sku");
                            widget.parts.product.sku = sku;
                          },
                          validator: (sku) {
                            if (sku.isEmpty) {
                              setState(() {
                                widget.parts.skuError = true;
                              });
                            } else {
                              setState(() {
                                widget.parts.skuError = false;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            hintText: Language.getProductStrings(
                                "variants.placeholders.skucode"),
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                                color: widget.parts.skuError
                                    ? Colors.red
                                    : Colors.white.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 2.5),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Measurements.width * 0.025),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(16))),
                        width: Measurements.width * 0.4475,
                        height: Measurements.height *
                            (widget.parts.isTablet ? 0.05 : 0.07),
                        child: TextFormField(
                          style: TextStyle(
                              fontSize: AppStyle.fontSizeTabContent()),
                          onSaved: (bar) {
                            print("barcode");
                            widget.parts.product.barcode = bar;
                          },
                          decoration: InputDecoration(
                            hintText: Language.getProductStrings(
                                "price.placeholders.barcode"),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 2.5),
              ),
              Container(
                //width: Measurements.width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              horizontal: Measurements.width * 0.025),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16))),
                          height: Measurements.height *
                              (widget.parts.isTablet ? 0.05 : 0.07),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Switch(
                                activeColor: widget.parts.switchColor,
                                value: widget.parts.prodTrackInv,
                                onChanged: (bool value) {
                                  setState(() {
                                    widget.parts.prodTrackInv = value;
                                  });
                                },
                              ),
                              Expanded(
                                child: AutoSizeText(
                                  Language.getProductStrings(
                                      "info.placeholders.inventoryTrackingEnabled"),
                                  minFontSize: 12,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 2.5),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(16))),
                        width: Measurements.width * 0.3375,
                        height: Measurements.height *
                            (widget.parts.isTablet ? 0.05 : 0.07),
                        child: TextFormField(
                          style: TextStyle(
                              fontSize: AppStyle.fontSizeTabContent()),
                          inputFormatters: [
                            WhitelistingTextInputFormatter(RegExp("[0-9]"))
                          ],
                          onSaved: (value) {
                            print("on save $value");
                            widget.parts.invManager.addInventory(Inventory(
                                newAmount: num.parse(value),
                                barcode: widget.parts.product.barcode ?? "",
                                sku: widget.parts.product.sku,
                                tracking: widget.parts.prodTrackInv));
                          },
                          textAlign: TextAlign.center,
                          controller: _controller,
                          onFieldSubmitted: (qtt) {
                            widget.parts.prodStock = num.parse(qtt);
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (num.parse(_controller.text) > 0) {
                                    _controller.text =
                                        (num.parse(_controller.text) - 1)
                                            .toString();
                                  }
                                  //if (widget.parts.prodStock > 0) widget.parts.prodStock--;
                                });
                              },
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  _controller.text =
                                      (num.parse(_controller.text) + 1)
                                          .toString();
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ]),
      ),
    );
  }
}
