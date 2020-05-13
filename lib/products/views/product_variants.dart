import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

import '../models/models.dart';
import '../network/network.dart';
import '../utils/utils.dart';
import '../../commons/views/custom_elements/custom_elements.dart';
import 'product_inventory.dart';
import 'new_product.dart';

class ProductVariantsRow extends StatefulWidget {
  final NewProductScreenParts parts;

  ProductVariantsRow({@required this.parts});

  @override
  createState() => _VariantRowState();
}

class _VariantRowState extends State<ProductVariantsRow> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.parts.product.variants.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  highlightColor: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        height: Measurements.height *
                            (widget.parts.isTablet ? 0.05 : 0.07),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                                width: Measurements.width * 0.4,
                                child: Text(
                                  "${widget.parts.product.variants[index].title}",
                                  overflow: TextOverflow.ellipsis,
                                )),
                            Container(
                                width: Measurements.width * 0.18,
                                child: Text(
                                    "${widget.parts.product.variants[index].price} ${Measurements.currency(widget.parts.currency)}")),
                            InkWell(
                              highlightColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                  padding: EdgeInsets.all(16),
                                  child: SvgPicture.asset(
                                      "assets/images/xsinacircle.svg")),
                              onTap: () {
                                setState(() {
                                  widget.parts.product.variants.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                          child: VariantPopUp(
                            parts: widget.parts,
                            wallpaper: widget.parts.wallpaper,
                            onEdit: true,
                            editVariant: widget.parts.product.variants[index],
                            index: index,
                          ),
                          duration: Duration(milliseconds: 100),
                          type: PageTransitionType.fade,
                        ));
                  },
                );
              },
            )),
            Container(
              child: InkWell(
                highlightColor: Colors.transparent,
                child: Container(
                    padding: EdgeInsets.all(16),
                    child: Center(
                        child: Text(
                      Language.getProductStrings("variantEditor.add_variant"),
                      style: TextStyle(fontSize: AppStyle.fontSizeTabContent()),
                    ))),
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                        child: VariantPopUp(
                          parts: widget.parts,
                          wallpaper: widget.parts.wallpaper,
                          onEdit: false,
                          editVariant: Variants(),
                        ),
                        duration: Duration(milliseconds: 100),
                        type: PageTransitionType.fade,
                      ));
                },
              ),
            )
          ]),
    );
  }
}

class VariantPopUp extends StatefulWidget {
  NewProductScreenParts parts;
  InventoryModel _inventoryModel;
  String wallpaper;
  bool skuError = false;
  bool onSale = false;
  bool nameError = false;
  bool priceError = false;
  bool onSaleError = false;
  bool trackInv = false;
  TextEditingController textEditingController;

  var inv = 0;
  var originalStock;
  bool descriptionError = false;
  bool onEdit = false;
  int index;
  num amount;
  Variants editVariant;
  final fKey = GlobalKey<FormState>();
  final scKey = GlobalKey<ScaffoldState>();
  Variants currentVariant = Variants();

  List<String> variantImages = List();
  String currentImage;

  bool haveImage = false;

  VariantPopUp(
      {@required this.parts,
      @required this.wallpaper,
      @required this.onEdit,
      @required this.editVariant,
      this.index}) {
    print(" Variant title ${editVariant.title} => is Editing on? $onEdit");
    if (onEdit) {
      variantImages = editVariant.images;
      currentVariant = editVariant;
      haveImage = variantImages.isNotEmpty;
      if (haveImage) currentImage = variantImages[0];
    }
  }

  @override
  _VariantPopUpState createState() => _VariantPopUpState();
}

class _VariantPopUpState extends State<VariantPopUp> {
  @override
  initState() {
    //if(widget.parts.editMode)
    super.initState();
    ProductsApi api = ProductsApi();
    widget.textEditingController = TextEditingController(text: "0");
    api
        .getInventory(
            widget.parts.business,
            GlobalUtils.activeToken.accessToken,
            widget.currentVariant.sku,
            context)
        .then((obj) {
      InventoryModel inventory = InventoryModel.toMap(obj);
      widget._inventoryModel = inventory;
      widget.inv = inventory.stock;
      widget.originalStock = inventory.stock;
      widget.trackInv = inventory.isTrackable;
      print("inventory.stock:${inventory.stock}");
      widget.textEditingController = TextEditingController(
          text: (widget.parts.editMode
              ? (inventory.stock?.toString() ?? "0")
              : "0"));
      setState(() {});
    });
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image.existsSync())
      setState(() {
        ProductsApi api = ProductsApi();
        api
            .postImage(image, widget.parts.business,
                GlobalUtils.activeToken.accessToken)
            .then((dynamic res) {
          widget.variantImages.add(res["blobName"]);
          if (widget.currentImage == null) {
            widget.currentImage = res["blobName"];
          }
          setState(() {
            widget.haveImage = true;
          });
        }).catchError((onError) {
          setState(() {
            print(onError);
          });
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        widget.parts.isPortrait = orientation == Orientation.portrait;
        widget.parts.isTablet = widget.parts.isPortrait
            ? MediaQuery.of(context).size.width > 600
            : MediaQuery.of(context).size.height > 600;
        return BackgroundBase(
          true,
          appBar: AppBar(
            title: Text(!widget.onEdit
                ? Language.getProductStrings("variantEditor.title")
                : Language.getProductStrings("variantEditor.edit_variant")),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: <Widget>[
              InkWell(
                // sav PopUp
                child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(right: Measurements.width * 0.02),
                    child: Text(Language.getProductStrings("save"))),
                onTap: () {
                  widget.fKey.currentState.validate();
                  if (!(widget.priceError ||
                          widget.skuError ||
                          widget.descriptionError ||
                          widget.nameError) &&
                      !(widget.onSale && widget.onSaleError)) {
                    widget.fKey.currentState.save();
                    if (!widget.onEdit) {
                      ProductsApi api = ProductsApi();
                      api
                          .checkSKU(
                              widget.parts.business,
                              GlobalUtils.activeToken.accessToken,
                              widget.currentVariant.sku)
                          .then((onValue) {
                        widget.skuError = true;
                        widget.scKey.currentState.showSnackBar(SnackBar(
                          content: Text("Sku already exist"),
                        ));
                      }).catchError((onError) {
                        print(onError);
                        widget.currentVariant.images = widget.variantImages;
                        widget.parts.product.variants
                            .add(widget.currentVariant);
                        print("inventory Stock ${widget.amount}");
                        widget.parts.invManager.addInventory(Inventory(
                            newAmount: widget.amount,
                            barcode: widget.currentVariant.barcode,
                            sku: widget.currentVariant.sku,
                            tracking: widget.trackInv));
                        Navigator.pop(context);
                      });
                    } else {
                      widget.parts.invManager.addInventory(Inventory(
                          amount: widget.originalStock,
                          newAmount: widget.amount,
                          barcode: widget.currentVariant.barcode,
                          sku: widget.currentVariant.sku,
                          tracking: widget.trackInv));
                      widget.currentVariant.images = widget.variantImages;
                      widget.parts.product.variants.removeAt(widget.index);
                      widget.parts.product.variants
                          .insert(widget.index, widget.currentVariant);
                      Navigator.pop(context);
                    }
                  }
                },
              )
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: InkWell(
            onTap: () => _removeFocus(context),
            child: Container(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                      height: Measurements.height * 0.4,
                      child: !widget.haveImage
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                    child: SvgPicture.asset(
                                  "assets/images/insertimageicon.svg",
                                  height: Measurements.height * 0.1,
                                  color: Colors.white.withOpacity(0.7),
                                )),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: Measurements.height * 0.05),
                                ),
                                Container(
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    child: Text(
                                      Language.getProductStrings(
                                          "pictures.add_image"),
                                      style: TextStyle(
                                          fontSize: AppStyle.fontSizeTabTitle(),
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline),
                                    ),
                                    onTap: () {
                                      getImage();
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              height: Measurements.height * 0.4,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    height: Measurements.height * 0.29,
                                    child: Image.network(
                                      Env.storage +
                                          "/products/" +
                                          widget.currentImage,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Container(
                                    height: Measurements.height * 0.1,
                                    width: Measurements.width * 0.75,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          widget.variantImages.length + 1,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return index !=
                                                widget.variantImages.length
                                            ? Stack(
                                                alignment: Alignment.topRight,
                                                children: <Widget>[
                                                    Container(
                                                        padding: EdgeInsets.all(
                                                            Measurements.width *
                                                                0.02),
                                                        child: InkWell(
                                                          child: Container(
                                                            height: Measurements
                                                                    .height *
                                                                0.07,
                                                            width: Measurements
                                                                    .height *
                                                                0.07,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                            child:
                                                                Image.network(
                                                              Env.storage +
                                                                  "/products/" +
                                                                  widget.variantImages[
                                                                      index],
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            setState(() {
                                                              widget.currentImage =
                                                                  widget.variantImages[
                                                                      index];
                                                            });
                                                          },
                                                        )),
                                                    InkWell(
                                                      child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          height: Measurements
                                                                  .height *
                                                              0.03,
                                                          width: Measurements
                                                                  .height *
                                                              0.03,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.black,
                                                              shape: BoxShape
                                                                  .circle),
                                                          child: Icon(
                                                            Icons.close,
                                                            size: Measurements
                                                                    .height *
                                                                0.02,
                                                          )),
                                                      onTap: () {
                                                        setState(() {
                                                          widget.variantImages
                                                              .removeAt(index);
                                                          if (widget
                                                                  .variantImages
                                                                  .length ==
                                                              0) {
                                                            widget.haveImage =
                                                                false;
                                                          }
                                                        });
                                                      },
                                                    )
                                                  ])
                                            : Container(
                                                padding: EdgeInsets.all(
                                                    Measurements.width * 0.02),
                                                child: Container(
                                                    height:
                                                        Measurements.height *
                                                            0.07,
                                                    width: Measurements.height *
                                                        0.07,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
                                                    child: InkWell(
                                                      child: Icon(
                                                        Icons.add,
                                                        color: Colors.white
                                                            .withOpacity(0.7),
                                                      ),
                                                      onTap: () {
                                                        getImage();
                                                      },
                                                    )),
                                              );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: Measurements.width * 0.05),
                    child: Container(
                      child: Form(
                        key: widget.fKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              Measurements.width * 0.025),
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(16))),
                                      width: Measurements.width * 0.5475,
                                      height: Measurements.height *
                                          (widget.parts.isTablet ? 0.05 : 0.07),
                                      child: TextFormField(
                                        style: TextStyle(
                                            fontSize:
                                                AppStyle.fontSizeTabContent()),
                                        initialValue: widget.onEdit
                                            ? widget.currentVariant.title
                                            : "",
                                        inputFormatters: [
                                          WhitelistingTextInputFormatter(
                                              RegExp("[a-z A-Z 0-9]"))
                                        ],
                                        decoration: InputDecoration(
                                          hintText: Language.getProductStrings(
                                              "variantEditor.placeholders.name"),
                                          hintStyle: TextStyle(
                                              color: widget.nameError
                                                  ? Colors.red
                                                  : Colors.white
                                                      .withOpacity(0.5)),
                                          border: InputBorder.none,
                                        ),
                                        onSaved: (name) {
                                          widget.currentVariant.title = name;
                                          widget.currentVariant.hidden =
                                              !widget.onSale;
                                        },
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            setState(() {
                                              widget.nameError = true;
                                            });
                                            return;
                                          } else {
                                            setState(() {
                                              widget.nameError = false;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 2.5),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                Measurements.width * 0.025),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.05),
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(16))),
                                        width: Measurements.width * 0.3475,
                                        height: Measurements.height *
                                            (widget.parts.isTablet
                                                ? 0.05
                                                : 0.07),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Container(
                                                child: AutoSizeText(
                                                    Language.getProductStrings(
                                                        "price.sale"),
                                                    style: TextStyle(
                                                        fontSize: AppStyle
                                                            .fontSizeTabContent()))),
                                            Switch(
                                              activeColor:
                                                  widget.parts.switchColor,
                                              value: widget.onSale,
                                              onChanged: (value) {
                                                setState(() {
                                                  widget.onSale = value;
                                                });
                                              },
                                            )
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                              // width: Measurements.width *0.9,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 2.5),
                            ),
                            Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              Measurements.width * 0.025),
                                      alignment: Alignment.center,
                                      color: Colors.white.withOpacity(0.05),
                                      height: Measurements.height *
                                          (widget.parts.isTablet ? 0.05 : 0.07),
                                      child: TextFormField(
                                        style: TextStyle(
                                            fontSize:
                                                AppStyle.fontSizeTabContent()),
                                        initialValue: widget.onEdit
                                            ? widget.currentVariant.price
                                                .toString()
                                            : "",
                                        decoration: InputDecoration(
                                          hintText: Language.getProductStrings(
                                              "variantEditor.placeholders.price"),
                                          hintStyle: TextStyle(
                                              color: widget.priceError
                                                  ? Colors.red
                                                  : Colors.white
                                                      .withOpacity(0.5)),
                                          border: InputBorder.none,
                                        ),
                                        inputFormatters: [
                                          WhitelistingTextInputFormatter(
                                              RegExp("[0-9.]"))
                                        ],
                                        keyboardType: TextInputType.number,
                                        onSaved: (price) {
                                          widget.currentVariant.price =
                                              num.parse(price);
                                        },
                                        validator: (value) {
                                          if (value.isEmpty ||
                                              num.parse(value) >= 1000000) {
                                            setState(() {
                                              widget.priceError = true;
                                            });
                                            return;
                                          } else if (value.split(".").length >
                                              2) {
                                            setState(() {
                                              widget.priceError = true;
                                            });
                                          } else {
                                            setState(() {
                                              widget.priceError = false;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 2.5),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              Measurements.width * 0.025),
                                      alignment: Alignment.center,
                                      color: Colors.white.withOpacity(0.05),
                                      height: Measurements.height *
                                          (widget.parts.isTablet ? 0.05 : 0.07),
                                      child: TextFormField(
                                        style: TextStyle(
                                            fontSize:
                                                AppStyle.fontSizeTabContent()),
                                        inputFormatters: [
                                          WhitelistingTextInputFormatter(
                                              RegExp("[0-9.]"))
                                        ],
                                        keyboardType: TextInputType.number,
                                        initialValue: widget.onEdit &&
                                                widget.currentVariant
                                                        .salePrice !=
                                                    null
                                            ? widget.currentVariant.salePrice
                                                .toString()
                                            : "",
                                        decoration: InputDecoration(
                                          hintText: Language.getProductStrings(
                                              "variantEditor.placeholders.sale_price"),
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(
                                              color: (widget.onSale &&
                                                      widget.onSaleError)
                                                  ? Colors.red
                                                  : Colors.white
                                                      .withOpacity(0.5)),
                                        ),
                                        onSaved: (saleprice) {
                                          widget.currentVariant.salePrice =
                                              saleprice.isEmpty
                                                  ? null
                                                  : num.parse(saleprice);
                                        },
                                        validator: (value) {
                                          if (widget.onSale) {
                                            if (value.isEmpty) {
                                              setState(() {
                                                widget.onSaleError = true;
                                              });
                                              return;
                                            } else if (value.split(".").length >
                                                2) {
                                              setState(() {
                                                widget.onSaleError = true;
                                              });
                                            } else {
                                              setState(() {
                                                widget.onSaleError = false;
                                              });
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: Measurements.width * 0.005),
                            ),
                            Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              Measurements.width * 0.025),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                      ),
                                      height: Measurements.height *
                                          (widget.parts.isTablet ? 0.05 : 0.07),
                                      child: TextFormField(
                                        style: TextStyle(
                                            fontSize:
                                                AppStyle.fontSizeTabContent()),
                                        onSaved: (sku) {
                                          widget.currentVariant.sku = sku;
                                        },
                                        validator: (sku) {
                                          if (sku.isEmpty) {
                                            setState(() {
                                              widget.skuError = true;
                                            });
                                          } else {
                                            setState(() {
                                              widget.skuError = false;
                                            });
                                          }
                                        },
                                        initialValue: widget.onEdit
                                            ? widget.currentVariant.sku
                                            : "",
                                        inputFormatters: [
                                          WhitelistingTextInputFormatter(
                                              RegExp("[a-z A-Z 0-9]"))
                                        ],
                                        decoration: InputDecoration(
                                          hintText: Language.getProductStrings(
                                              "variantEditor.placeholders.sku"),
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(
                                              color: widget.skuError
                                                  ? Colors.red
                                                  : Colors.white
                                                      .withOpacity(0.5)),
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
                                          horizontal:
                                              Measurements.width * 0.025),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                      ),
                                      height: Measurements.height *
                                          (widget.parts.isTablet ? 0.05 : 0.07),
                                      child: TextFormField(
                                        style: TextStyle(
                                            fontSize:
                                                AppStyle.fontSizeTabContent()),
                                        onSaved: (bar) {
                                          widget.currentVariant.barcode = bar;
                                        },
                                        initialValue: widget.onEdit
                                            ? widget.currentVariant.barcode
                                            : "",
                                        inputFormatters: [
                                          WhitelistingTextInputFormatter(
                                              RegExp("[a-z A-Z 0-9]"))
                                        ],
                                        decoration: InputDecoration(
                                          hintText: Language.getProductStrings(
                                              "variantEditor.placeholders.barcode"),
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
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                Measurements.width * 0.025),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                        ),
                                        height: Measurements.height *
                                            (widget.parts.isTablet
                                                ? 0.05
                                                : 0.07),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Switch(
                                              activeColor:
                                                  widget.parts.switchColor,
                                              value: widget.trackInv,
                                              onChanged: (bool value) {
                                                setState(() {
                                                  widget.trackInv = value;
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
                                      ),
                                      height: Measurements.height *
                                          (widget.parts.isTablet ? 0.05 : 0.07),
                                      child: TextFormField(
                                        style: TextStyle(
                                            fontSize:
                                                AppStyle.fontSizeTabContent()),
                                        inputFormatters: [
                                          WhitelistingTextInputFormatter(
                                              RegExp("[0-9.]"))
                                        ],
                                        onFieldSubmitted: (qtt) {
                                          widget.inv = num.parse(qtt ?? "0");
                                        },
                                        onSaved: (value) {
                                          print("value =  $value");
                                          widget.amount = num.parse(value);
                                        },
                                        textAlign: TextAlign.center,
                                        // controller: TextEditingController(
                                        //   text: "${widget.inv ?? 0}",
                                        // ),
                                        controller:
                                            widget.textEditingController,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          prefixIcon: IconButton(
                                            icon: Icon(Icons.remove),
                                            onPressed: () {
                                              setState(() {
                                                if (num.parse(widget
                                                        .textEditingController
                                                        .text) >
                                                    0)
                                                  widget.textEditingController
                                                      .text = (num.parse(widget
                                                              .textEditingController
                                                              .text) -
                                                          1)
                                                      .toString();
                                              });
                                            },
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(Icons.add),
                                            onPressed: () {
                                              setState(() {
                                                widget.textEditingController
                                                    .text = (num.parse(widget
                                                            .textEditingController
                                                            .text) +
                                                        1)
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
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: Measurements.width * 0.005),
                            ),
                            Container(
                              height: Measurements.height * 0.2,
                              padding: EdgeInsets.symmetric(
                                  horizontal: Measurements.width * 0.025),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(16),
                                      bottomLeft: Radius.circular(16))),
                              child: TextFormField(
                                style: TextStyle(
                                    fontSize: AppStyle.fontSizeTabContent()),
                                inputFormatters: [
                                  WhitelistingTextInputFormatter(
                                      RegExp("[a-z A-Z 0-9]"))
                                ],
                                initialValue: widget.onEdit
                                    ? widget.currentVariant.description
                                    : "",
                                maxLines: 100,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    labelStyle: TextStyle(
                                        color: widget.descriptionError
                                            ? Colors.red
                                            : Colors.white.withOpacity(0.5)),
                                    labelText: Language.getProductStrings(
                                        "variantEditor.placeholders.description")),
                                onSaved: (description) {
                                  widget.currentVariant.description =
                                      description;
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    setState(() {
                                      widget.descriptionError = true;
                                    });
                                    return;
                                  } else {
                                    setState(() {
                                      widget.descriptionError = false;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _removeFocus(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
