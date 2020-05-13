import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import '../network/network.dart';
import '../utils/utils.dart';
import 'new_product.dart';

class ProductMainRow extends StatefulWidget {
  NewProductScreenParts parts;
  bool onSale;
  String currentImage;
  bool haveImage = false;
  ProductMainRow({@required this.parts});
  get isMainRowOK {
    parts.product.hidden = parts.product.hidden??true;
    return !(parts.nameError || parts.priceError || parts.descriptionError) &&
        !(!parts.product.hidden && parts.onSaleError);
  }
  @override
  _ProductMainRowState createState() => _ProductMainRowState();
}

class _ProductMainRowState extends State<ProductMainRow> {


  @override
  void initState() {
    super.initState();
    if(widget.parts.editMode){
      widget.haveImage = widget.parts.product.images.length>0;
      if(widget.haveImage){
        widget.currentImage = widget.parts.product.images[0];
        widget.parts.images = widget.parts.product.images;
      }
    }
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(imageQuality: 80,source: ImageSource.gallery);
    if (image.existsSync())
      setState(() {
        ProductsApi api = ProductsApi();
        api.postImage(image, widget.parts.business, GlobalUtils.activeToken.accessToken).then((dynamic res) {
          print(res["blobName"]);
          widget.parts.images.add(res["blobName"]);
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
    widget.onSale = !(widget.parts.product.hidden??true);
    bool _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    Measurements.height = _isPortrait?MediaQuery.of(context).size.height:MediaQuery.of(context).size.width;
    Measurements.width = !_isPortrait?MediaQuery.of(context).size.height:MediaQuery.of(context).size.width;
    print("Portrait: $_isPortrait");
    widget.haveImage = widget.parts.images.isNotEmpty;
    if(widget.haveImage){
        widget.currentImage = widget.parts.images[0];
      }
    return Expanded(
      child: Column(
        children: <Widget>[
        Container(
        height: Measurements.height * 0.3,
      child: !widget.haveImage
        ? InkWell(child:Column(
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
                    Language.getProductStrings("pictures.add_image"),
                    style: TextStyle(
                        fontSize: AppStyle.fontSizeTabTitle(),
                        fontWeight: FontWeight.bold,
                        decoration:
                            TextDecoration.underline
                            ),
                  ),
                  onTap: () {
                    getImage();
                  },
                ),
              ),
            ],
          ),onTap: () => getImage(),)
        : Container(
            height: Measurements.height * 0.3,
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(16)),
                  height: Measurements.height * 0.19,
                  width: Measurements.width * 0.9,
                  child: Image.network(
                    Env.storage +
                        "/products/" +
                        widget.currentImage,
                    fit: BoxFit.contain,
                  ),
                ),
                Container(
                  height: Measurements.height * 0.09,
                  width: Measurements.width * 0.9,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        widget.parts.images.length + 1,
                    itemBuilder: (BuildContext context,
                        int index) {
                      return index !=
                              widget.parts.images.length
                          ? Stack(
                            alignment: Alignment.topRight,
                            children:<Widget>[
                            Container(
                              padding: EdgeInsets.all(
                                  Measurements.width *
                                      0.02),
                              child: InkWell(
                                child: Container(
                                  height: Measurements.height * 0.07,
                                  width: Measurements.height  * 0.07,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(image: NetworkImage(Env.storage +
                                        "/products/" +
                                        widget.parts
                                                .images[
                                            index])),
                                      color:
                                          Colors.white,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  8)),
                                  
                                ),
                                onTap: () {
                                  setState(() {
                                    widget.currentImage =
                                        widget.parts
                                                .images[
                                            index];
                                  });
                                },
                              )),
                              InkWell(
                                child: Container(
                                  alignment: Alignment.center,
                                  height:Measurements.height * 0.03,
                                  width:Measurements.height * 0.03,
                                  decoration: BoxDecoration(color:Colors.black,shape: BoxShape.circle),
                                  child: Icon(Icons.close,size:Measurements.height * 0.02,)),
                                onTap: () {
                                  setState(() {
                                    widget.parts.images.removeAt(index);
                                    if(widget.parts.images.length==0){
                                      widget.haveImage =false;
                                    }
                                  });
                                },),])
                          : Container(
                              padding: EdgeInsets.all(Measurements.width *
                                      0.02),
                              child: Container(
                                  height: Measurements.height * 0.07,
                                  width: Measurements.height  * 0.07,
                                  decoration: BoxDecoration(
                                      color: Colors
                                          .white
                                          .withOpacity(
                                              0.1),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  8)),
                                  child: InkWell(
                                    child: Icon(
                                      Icons.add,
                                      color: Colors
                                          .white
                                          .withOpacity(
                                              0.7),
                                    ),
                                    onTap: () {
                                      getImage();
                                    },
                                  )),
                            );
                    },
                  ),
                )
              ],
            ),
          )),
          Container(
            //width: Measurements.width * 0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: Measurements.width * 0.025),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(16))),
                    height: Measurements.height *
                        (widget.parts.isTablet ? 0.05 : 0.07),
                    child: TextFormField(style: TextStyle(fontSize: AppStyle.fontSizeTabContent()),
                      initialValue: widget.parts.editMode?widget.parts.product.title:"",
                      inputFormatters: [WhitelistingTextInputFormatter(RegExp("[a-z A-Z 0-9]"))],
                      decoration: InputDecoration(
                        hintText: Language.getProductStrings("name.title"),
                        hintStyle: TextStyle(
                            color: widget.parts.nameError
                                ? Colors.red
                                : Colors.white.withOpacity(0.5)),
                        border: InputBorder.none,
                      ),
                      onSaved: (name) {
                        widget.parts.product.title = name;

                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          setState(() {
                            widget.parts.nameError = true;
                          });
                          return;
                        } else {
                          setState(() {
                            widget.parts.nameError = false;
                          });
                        }
                      },
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 2.5),),
                Expanded(
                  flex: 2,
                  child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: Measurements.width * 0.025),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius:
                              BorderRadius.only(topRight: Radius.circular(16))),
                      height: Measurements.height *
                          (widget.parts.isTablet ? 0.05 : 0.07),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                            //width: (Measurements.width * 0.2475)*2/3,
                            child: AutoSizeText(Language.getProductStrings("price.sale"),style: TextStyle(fontSize: AppStyle.fontSizeTabContent()))),
                          Switch(
                            activeColor: widget.parts.switchColor,
                            value: !(widget.parts.product.hidden??true),
                            onChanged: (value) {
                              setState(() {
                                widget.parts.product.hidden = !value;
                              });
                            },
                          )
                        ],
                      )),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 2.5),
          ),
          Container(
            //width: Measurements.width * 0.9,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: Measurements.width * 0.025),
                    alignment: Alignment.center,
                    color: Colors.white.withOpacity(0.05),
                    width: Measurements.width * 0.4475,
                    height: Measurements.height *
                        (widget.parts.isTablet ? 0.05 : 0.07),
                    child: TextFormField(
                      style: TextStyle(fontSize: AppStyle.fontSizeTabContent()),
                      initialValue: widget.parts.editMode?widget.parts.product.price.toString():"",
                      inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
                      decoration: InputDecoration(
                        hintText: Language.getProductStrings("price.placeholders.price"),
                        hintStyle: TextStyle(
                            color: widget.parts.priceError
                                ? Colors.red
                                : Colors.white.withOpacity(0.5)),
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (price) {
                        widget.parts.product.price = num.parse(price);
                      },
                      validator: (value) {
                        if (value.isEmpty || num.parse(value) >= 1000000) {
                          setState(() {
                            widget.parts.priceError = true;
                          });
                          return;
                        } else if(value.split(".").length>2){
                            setState(() {
                              widget.parts.priceError = true;
                            });
                          }else {
                          setState(() {
                            widget.parts.priceError = false;
                          });
                        }
                      },
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 2.5),),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: Measurements.width * 0.025),
                    alignment: Alignment.center,
                    color: Colors.white.withOpacity(0.05),
                    width: Measurements.width * 0.4475,
                    height: Measurements.height *
                        (widget.parts.isTablet ? 0.05 : 0.07),
                    child: TextFormField(
                      style: TextStyle(fontSize:AppStyle.fontSizeTabContent()),
                      initialValue: widget.parts.editMode?widget.parts.product.salePrice==null?"":widget.parts.product.salePrice.toString():"",
                      inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: Language.getProductStrings("placeholders.salePrice"),
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                            color: (widget.onSale && widget.parts.onSaleError)
                                ? Colors.red
                                : Colors.white.withOpacity(0.5)),
                      ),
                      onSaved: (saleprice) {
                        
                        widget.parts.product.salePrice =
                            saleprice.isEmpty ? null : num.parse(saleprice);
                      },
                      validator: (value) {
                        if (widget.onSale) {
                          if (value.isEmpty) {
                            setState(() {
                              widget.parts.onSaleError = true;
                            });
                            return;
                          } else if(value.split(".").length>2){
                              setState(() {
                                widget.parts.onSaleError = true;
                              });
                            }else {
                            setState(() {
                              widget.parts.onSaleError = false;
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
            padding: EdgeInsets.only(top: 2.5),
          ),
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: Measurements.height *0.20,
                    padding:
                        EdgeInsets.symmetric(horizontal: Measurements.width * 0.025),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16))),
                    width: Measurements.width * 0.9,
                    child: TextFormField(
                      style: TextStyle(fontSize: AppStyle.fontSizeTabContent()),
                      initialValue: widget.parts.editMode?widget.parts.product.description:"",
                      inputFormatters: [WhitelistingTextInputFormatter(RegExp("[a-z A-Z 0-9]"))],
                      maxLines: 99,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                              color: widget.parts.descriptionError
                                  ? Colors.red
                                  : Colors.white.withOpacity(0.5)),
                          labelText: Language.getProductStrings("mainSection.form.description.label")),
                      onSaved: (description) {
                        widget.parts.product.description = description;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          setState(() {
                            widget.parts.descriptionError = true;
                          });
                          return;
                        } else {
                          setState(() {
                            widget.parts.descriptionError = false;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}