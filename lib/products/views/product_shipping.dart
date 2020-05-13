import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/utils.dart';
import 'new_product.dart';

class ProductShippingRow extends StatefulWidget {
  NewProductScreenParts parts;

  ProductShippingRow({@required this.parts});

  get isShippingRowOK {
    return !(parts.weightError ||
        parts.widthError ||
        parts.lengthError ||
        parts.heightError);
  }

  @override
  _ProductShippingRowState createState() => _ProductShippingRowState();
}

class _ProductShippingRowState extends State<ProductShippingRow> {
  List<Widget> wlh;
  Widget length;
  Widget hight;
  Widget width;

  @override
  void initState() {
    super.initState();
    //if(widget.parts.editMode){
    widget.parts.product.shipping.free =
        widget.parts.product.shipping.free ?? false;
    widget.parts.product.shipping.general =
        widget.parts.product.shipping.general ?? false;
    //}
  }

  @override
  Widget build(BuildContext context) {
    wlh = List();
    width = Container(
      padding: EdgeInsets.only(left: Measurements.width * 0.025),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(widget.parts.isTablet ? 16 : 0)),
        color: Colors.white.withOpacity(0.05),
      ),
      // height: Measurements.height * (widget.parts.isTablet ? 0.05 : 0.07),
      child: TextFormField(
        style: TextStyle(fontSize: AppStyle.fontSizeTabContent()),
        validator: (value) {
          if (value.isEmpty) {
            setState(() {
              widget.parts.widthError = true;
            });
          } else if (value.split(".").length > 2) {
            setState(() {
              widget.parts.widthError = true;
            });
          } else {
            setState(() {
              widget.parts.widthError = false;
            });
          }
        },
        onSaved: (value) {
          widget.parts.product.shipping.width = num.parse(value);
        },
        initialValue: widget.parts.editMode
            ? widget.parts.product.shipping.width?.toString() ?? ""
            : "",
        inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
        decoration: InputDecoration(
          hintText: Language.getProductStrings("shipping.placeholders.width"),
          border: InputBorder.none,
          hintStyle: TextStyle(
              color: widget.parts.widthError
                  ? Colors.red
                  : Colors.white.withOpacity(0.5)),
          suffixIcon: Container(
            color: Colors.white.withOpacity(0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(Language.getProductStrings("shippingSection.measure.cm"),
                    style: TextStyle(color: Colors.white.withOpacity(0.6))),
              ],
            ),
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
    hight = Container(
      padding: EdgeInsets.only(left: Measurements.width * 0.025),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(widget.parts.isTablet ? 0 : 16)),
        color: Colors.white.withOpacity(0.05),
      ),
      // height: Measurements.height * (widget.parts.isTablet ? 0.05 : 0.07),
      child: TextFormField(
        style: TextStyle(fontSize: AppStyle.fontSizeTabContent()),
        validator: (value) {
          if (value.isEmpty) {
            setState(() {
              widget.parts.heightError = true;
            });
          } else if (value.split(".").length > 2) {
            setState(() {
              widget.parts.heightError = true;
            });
          } else {
            setState(() {
              widget.parts.heightError = false;
            });
          }
        },
        onSaved: (value) {
          widget.parts.product.shipping.height = num.parse(value);
        },
        keyboardType: TextInputType.number,
        inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
        initialValue: widget.parts.editMode
            ? widget.parts.product.shipping.height?.toString() ?? ""
            : "",
        decoration: InputDecoration(
          hintText: Language.getProductStrings("shipping.placeholders.height"),
          hintStyle: TextStyle(
              color: widget.parts.heightError
                  ? Colors.red
                  : Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
          suffixIcon: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(16)),
              color: Colors.white.withOpacity(0.1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(Language.getProductStrings("shippingSection.measure.cm"),
                    style: TextStyle(color: Colors.white.withOpacity(0.6))),
              ],
            ),
          ),
        ),
      ),
    );
    length = Container(
      padding: EdgeInsets.only(left: Measurements.width * 0.025),
      alignment: Alignment.center,
      color: Colors.white.withOpacity(0.05),
      // height: Measurements.height * (widget.parts.isTablet ? 0.05 : 0.07),
      child: TextFormField(
        style: TextStyle(fontSize: AppStyle.fontSizeTabContent()),
        validator: (value) {
          if (value.isEmpty) {
            setState(() {
              widget.parts.lengthError = true;
            });
          } else if (value.split(".").length > 2) {
            setState(() {
              widget.parts.lengthError = true;
            });
          } else {
            setState(() {
              widget.parts.lengthError = false;
            });
          }
        },
        onSaved: (value) {
          widget.parts.product.shipping.length = num.parse(value);
        },
        keyboardType: TextInputType.number,
        inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
        initialValue: widget.parts.editMode
            ? widget.parts.product.shipping.length?.toString() ?? ""
            : "",
        decoration: InputDecoration(
          hintText: Language.getProductStrings("shipping.placeholders.length"),
          hintStyle: TextStyle(
              color: widget.parts.lengthError
                  ? Colors.red
                  : Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
          suffixIcon: Container(
            color: Colors.white.withOpacity(0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(Language.getProductStrings("shippingSection.measure.cm"),
                    style: TextStyle(color: Colors.white.withOpacity(0.6))),
              ],
            ),
          ),
        ),
      ),
    );
    wlh = <Widget>[
      widget.parts.isTablet ? Expanded(child: width) : width,
      widget.parts.isTablet
          ? Padding(
              padding: EdgeInsets.only(left: 2.5),
            )
          : Padding(
              padding: EdgeInsets.only(top: 2.5),
            ),
      widget.parts.isTablet
          ? Expanded(
              child: length,
            )
          : length,
      widget.parts.isTablet
          ? Padding(
              padding: EdgeInsets.only(left: 2.5),
            )
          : Padding(
              padding: EdgeInsets.only(top: 2.5),
            ),
      widget.parts.isTablet
          ? Expanded(
              child: hight,
            )
          : hight,
    ];

    ///BUILD
    return Expanded(
      child: Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Measurements.width * 0.025),
                        alignment: Alignment.center,
                        height: Measurements.height *
                            (widget.parts.isTablet ? 0.05 : 0.07),
                        child: Text(
                          Language.getProductStrings(
                              "shippingSection.form.free.label"),
                          style: TextStyle(
                              fontSize: AppStyle.fontSizeTabContent()),
                        )),
                    Switch(
                      activeColor: widget.parts.switchColor,
                      value: widget.parts.product.shipping.free ?? false,
                      onChanged: (bool value) {
                        setState(() {
                          widget.parts.product.shipping.free = value;
                        });
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 2.5),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Measurements.width * 0.025),
                        alignment: Alignment.center,
                        height: Measurements.height *
                            (widget.parts.isTablet ? 0.05 : 0.07),
                        child: Text(
                          Language.getProductStrings(
                              "shippingSection.form.general.label"),
                          style: TextStyle(
                              fontSize: AppStyle.fontSizeTabContent()),
                        )),
                    Switch(
                      activeColor: widget.parts.switchColor,
                      value: widget.parts.product.shipping.general ?? false,
                      onChanged: (bool value) {
                        setState(() {
                          widget.parts.product.shipping.general = value;
                        });
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top:2.5),
              ),
              Container(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.only(left: Measurements.width * 0.025),
                        alignment: Alignment.center,
                        color: Colors.white.withOpacity(0.05),
                        // height: Measurements.height *
                        //     (widget.parts.isTablet ? 0.05 : 0.07),
                        child: TextFormField(
                          style: TextStyle(
                              fontSize: AppStyle.fontSizeTabContent()),
                          validator: (value) {
                            if (value.isEmpty) {
                              setState(() {
                                widget.parts.weightError = true;
                              });
                            } else if (value.split(".").length > 2) {
                              setState(() {
                                widget.parts.weightError = true;
                              });
                            } else {
                              setState(() {
                                widget.parts.weightError = false;
                              });
                            }
                          },
                          onSaved: (value) {
                            widget.parts.product.shipping.weight =
                                num.parse(value);
                          },
                          inputFormatters: [
                            WhitelistingTextInputFormatter(RegExp("[0-9.]"))
                          ],
                          initialValue: widget.parts.editMode
                              ? widget.parts.product.shipping.weight
                                      ?.toString() ??
                                  ""
                              : "",
                          decoration: InputDecoration(
                            hintText: Language.getProductStrings(
                                "shippingSection.form.weight.label"),
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                                color: widget.parts.weightError
                                    ? Colors.red
                                    : Colors.white.withOpacity(0.5)),
                            suffixIcon: Container(
                              color: Colors.white.withOpacity(0.1),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                      Language.getProductStrings(
                                          "shippingSection.measure.kg"),
                                      style: TextStyle(
                                          color:
                                              Colors.white.withOpacity(0.6))),
                                ],
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top:2.5),
              ),
              Container(
                child: widget.parts.isTablet
                    ? Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: wlh,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: wlh,
                      ),
              ),
            ]),
      ),
    );
  }
}
