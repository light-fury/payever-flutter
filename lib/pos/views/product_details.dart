import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oktoast/oktoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../commons/views/custom_elements/custom_elements.dart';
import '../view_models/view_models.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'pos_cart.dart';

CustomCarouselSlider customCarouselSlider;

class ProductDetailsScreen extends StatefulWidget {
  final PosStateModel parts;
  final ProductsModel currentProduct;
  final int index;

  ProductDetailsScreen({this.parts, this.currentProduct, this.index});

  @override
  createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool isPortrait = true;
  bool isTablet = false;

  @override
  Widget build(BuildContext context) {

    PosCartStateModel cartStateModel = Provider.of<PosCartStateModel>(context);

    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    isTablet = isPortrait
        ? MediaQuery.of(context).size.width > 600
        : MediaQuery.of(context).size.height > 600;

    return OKToast(
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            "Product details",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            IconButton(
              icon: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  SvgPicture.asset(
                    "assets/images/shopicon.svg",
                    color: Colors.black,
                    height: Measurements.height * 0.035,
                  ),
                  Container(
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Container(),
                        ),
                        cartStateModel.getCartHasItems
                            ? Icon(Icons.brightness_1,
                                color: Color(0XFF0084FF),
                                size: Measurements.height *
                                    (isTablet ? 0.01 * 1 : 0.01 * 1.2))
                            : Container(),
                        Expanded(
                          flex: 2,
                          child: Container(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: POSCart(
                          parts: widget.parts,
                        ),
                        type: PageTransitionType.fade,
                        duration: Duration(milliseconds: 10)));
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
            child: DetailedProduct(
          currentProduct: widget.currentProduct,
          parts: widget.parts,
          cartStateModel: cartStateModel,
          defaultVariantIndex: widget.index,
        )),
      ),
    );
  }
}

class DetailedProduct extends StatefulWidget {
  final ProductsModel currentProduct;
  final PosStateModel parts;
  final ValueNotifier<bool> stockCount = ValueNotifier(false);
  final PosCartStateModel cartStateModel;
  final int defaultVariantIndex;

  DetailedProduct(
      {@required this.currentProduct,
      @required this.parts,
      @required this.cartStateModel,
      @required this.defaultVariantIndex});

  @override
  _DetailedProductState createState() => _DetailedProductState();
}

class _DetailedProductState extends State<DetailedProduct> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Measurements.width * 0.05),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              DetailsInfo(
                parts: widget.parts,
                currentProduct: widget.currentProduct,
                haveVariants: widget.currentProduct.variants.isNotEmpty,
                stockCount: widget.stockCount,
                cartStateModel: widget.cartStateModel,
                defaultVariantIndex: widget.defaultVariantIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailsInfo extends StatefulWidget {
  final PosStateModel parts;
  final ProductsModel currentProduct;
  final bool haveVariants;
  final ValueNotifier<bool> stockCount;
  final PosCartStateModel cartStateModel;
  final int defaultVariantIndex;

  DetailsInfo(
      {@required this.parts,
      @required this.currentProduct,
      @required this.haveVariants,
      @required this.stockCount,
      @required this.cartStateModel,
      @required this.defaultVariantIndex});

  @override
  _DetailsInfoState createState() => _DetailsInfoState();
}

class _DetailsInfoState extends State<DetailsInfo> {
  List<String> imagesVariants = List();
  List<String> imagesBase = List();
  bool onSale, haveVariants;

  ValueNotifier<int> currentVariant = ValueNotifier(0);

  num price, salePrice;
  String description;
  List<PopupMenuItem<String>> products;
  List<String> productsList = List<String>();
  TextStyle textStyle = TextStyle(color: Colors.black);

  String selectedVariantName = "";

  int selectedIndex = 0;

  bool isPortrait = true;
  bool isTablet = false;

  listener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.stockCount.addListener(listener);
    currentVariant.addListener(listener);

//    widget.currentVariant.value =
//        widget.cartStateModel.getCurrentSelectedVariant;

    currentVariant.value = widget.defaultVariantIndex;

    setState(() {
      imagesBase = widget.currentProduct.images;
//      haveVariants = widget.haveVariants;
      haveVariants = widget.currentProduct.variants.isNotEmpty;

      selectedVariantName = haveVariants
          ? "- ${widget.currentProduct.variants[currentVariant.value].title}"
          : "";
    });
  }

  @override
  Widget build(BuildContext context) {
    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    isTablet = isPortrait
        ? MediaQuery.of(context).size.width > 600
        : MediaQuery.of(context).size.height > 600;

    if (widget.haveVariants) {
      imagesVariants = imagesBase +
          widget.currentProduct.variants[currentVariant.value].images;
    } else {
      imagesVariants = imagesBase;
    }

    if (widget.haveVariants) {
      var index = 0;
      products = List();
      productsList = [];

      widget.currentProduct.variants.forEach((f) {
//        var temp = widget.parts.getProductStock[f.sku];

//        if (temp != null) {
//          if (((temp.contains("null") ? 0 : int.parse(temp ?? "0")) > 0)) {
        PopupMenuItem<String> variant = PopupMenuItem(
          value: "$index",
          child: Container(
            width: Measurements.width,
            child: ListTile(
              dense: true,
              title: Container(
                width: Measurements.width,
                child: Text(
                  f.title,
                  style: textStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
        products.add(variant);
        productsList.add(f.title);
//          }
//        }
        index++;
      });
//      if (widget.currentVariant.value == 0 && products.length > 0) {
//        widget.currentVariant.value = int.parse(products.first.value);
//      }
      price = widget.currentProduct.variants[currentVariant.value].price;
      salePrice =
          widget.currentProduct.variants[currentVariant.value].salePrice;
      onSale = !widget.currentProduct.variants[currentVariant.value].hidden;
      description =
          widget.currentProduct.variants[currentVariant.value].description;

      selectedVariantName =
          "- ${widget.currentProduct.variants[currentVariant.value].title}";
    } else {
      price = widget.currentProduct.price;
      salePrice = widget.currentProduct.salePrice;
      onSale = !widget.currentProduct.hidden;
      description = widget.currentProduct.description;
    }

    String _stc = widget.haveVariants
        ? widget.currentProduct.variants[currentVariant.value].sku
        : widget.currentProduct.sku;

//    return Center(child: Text("Hello", style: TextStyle(color: Colors.red),),);

    return Container(
      width: Measurements.height * 0.4,
      child: CustomFutureBuilder<int>(
          future: getInventoryState(widget.parts, _stc),
          errorMessage: "Error loading product details",
          onDataLoaded: (results) {

            print("results: $results");

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                //for sale
                Container(
                    alignment: Alignment.center,
                    height: Measurements.height * 0.05,
                    child: onSale
                        ? Text(
                            "Sale",
                            style: TextStyle(color: widget.parts.saleColor),
                          )
                        : Container()),
                //name
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "${widget.currentProduct.title} $selectedVariantName",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                //price
                Container(
                  height: Measurements.height * 0.05,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "${widget.parts.f.format(price)}${Measurements.currency(widget.parts.getBusiness.currency)}",
                        style: TextStyle(
                            fontSize: 17,
                            color: widget.parts.titleColor.withOpacity(0.5),
                            fontWeight: FontWeight.w300,
                            decoration: onSale
                                ? TextDecoration.lineThrough
                                : TextDecoration.none),
                      ),
                      onSale
                          ? Text(
                              "  ${widget.parts.f.format(salePrice)}${Measurements.currency(widget.parts.getBusiness.currency)}",
                              style: TextStyle(
                                  fontSize: 17,
                                  color: widget.parts.saleColor,
                                  fontWeight: FontWeight.w300),
                            )
                          : Container(),
                    ],
                  ),
                ),
                //Stock
                Container(
                  child: StockText(
                    parts: widget.parts,
                    stc: results,
                    productStock: results,
                  ),
                ),
                //images
                DetailImage(
                  currentVariant: currentVariant,
                  parts: widget.parts,
                  images: imagesVariants,
                  index: (widget.haveVariants &&
                          (widget.currentProduct.variants[currentVariant.value]
                              .images.isNotEmpty))
                      ? imagesBase.length
                      : 0,
                ),
                //variant Picker
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: Measurements.height * 0.01),
                ),

                widget.haveVariants
                    ? Container(
//                  padding: EdgeInsets.symmetric(
//                      horizontal: Measurements.width *
//                          (widget.parts.isTablet ? 0.15 : 0)),
                        height: Measurements.height * 0.07,
                        child: Theme(
                          data: ThemeData.light(),
                          child: Container(
//                      width: Measurements.width * 0.9,
                            width: isTablet
                                ? Measurements.width * 0.5
                                : Measurements.width * 0.9,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
//                        color: Colors.grey.withOpacity(0.2),
                              border: Border.all(
                                  width: 1,
                                  color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: DropDownMenu(
                              backgroundColor: Colors.white,
                              fontColor: Colors.black.withOpacity(0.6),
                              optionsList: productsList,
//                  defaultValue: products[0].value,
//                        defaultValue: "Something",
                              placeHolderText:
                                  productsList[widget.defaultVariantIndex],
                              onChangeSelection: (String value, int index) {
                                setState(() {
                                  currentVariant.value = index;

//                            widget.cartStateModel.updateCurrentVariant(index);

//                            widget.currentVariant.value =
//                                widget.cartStateModel.getCurrentSelectedVariant;

                                  if (imagesBase != null &&
                                      imagesBase.length >= 0) {
                                    print(
                                        "imagesBase.length: ${imagesBase.length}");
                                    print(widget
                                            .currentProduct
                                            .variants[currentVariant.value]
                                            .images
                                            .length >
                                        0);
                                    if (widget
                                            .currentProduct
                                            .variants[currentVariant.value]
                                            .images
                                            .length >
                                        0) {
                                      customCarouselSlider
                                          .jumpToPage(imagesBase.length);

                                      getInventoryState(
                                          widget.parts,
                                          widget
                                              .currentProduct
                                              .variants[currentVariant.value]
                                              .sku);
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: Measurements.height * 0.01),
                ),
                Container(
                  alignment: Alignment.center,
                  height: Measurements.height * 0.08,
                  width: isTablet
                      ? Measurements.width * 0.8
                      : Measurements.width * 0.9,
                  padding: EdgeInsets.symmetric(
                      vertical: Measurements.height * 0.01,
                      horizontal: Measurements.width * (isTablet ? 0.15 : 0)),
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: results == 0 ? Colors.grey : Colors.black,
                      ),
                      child: Center(
                          child: Text(
                        Language.getCustomStrings("checkout_cart_add_to_cart"),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      )),
                    ),
                    onTap: () {
                      if(widget.cartStateModel.getIsButtonAvailable) {
                        if (results != 0) {
                          if (widget.haveVariants) {
                            var image = widget
                                .currentProduct
                                .variants[currentVariant.value]
                                .images
                                .isNotEmpty
                                ? widget.currentProduct
                                .variants[currentVariant.value].images[0]
                                : widget.currentProduct.images.isNotEmpty
                                ? widget.currentProduct.images[0]
                                : null;
                            widget.parts.add2cart(
                                id: widget.currentProduct
                                    .variants[currentVariant.value].id,
                                image: image,
                                uuid: widget.currentProduct
                                    .variants[currentVariant.value].id,
                                name: widget.currentProduct
                                    .variants[currentVariant.value].title,
                                price: onSale
                                    ? widget.currentProduct
                                    .variants[currentVariant.value].salePrice
                                    : widget.currentProduct
                                    .variants[currentVariant.value].price,
                                qty: 1,
                                sku: widget.currentProduct
                                    .variants[currentVariant.value].sku);

                          } else {
                            var image = widget.currentProduct.images.isNotEmpty
                                ? widget.currentProduct.images[0]
                                : null;
                            widget.parts.add2cart(
                                id: widget.currentProduct.uuid,
                                image: image,
                                uuid: widget.currentProduct.uuid,
                                name: widget.currentProduct.title,
                                price: onSale
                                    ? widget.currentProduct.salePrice
                                    : widget.currentProduct.price,
                                qty: 1,
                                sku: widget.currentProduct.sku);
                          }
                          widget.cartStateModel.updateBuyButton(false);
                          widget.cartStateModel.updateCart(true);
                          ToastFuture toastFuture = showToastWidget(
                            CustomToastNotification(
                              icon: Icons.check_circle_outline,
                              toastText: "Product added to Bag",
                            ),
                            duration: Duration(seconds: 2),
                            onDismiss: () {
                              print("The toast was dismised");
                              widget.cartStateModel.updateBuyButton(true);
                            },
                          );

                          Future.delayed(Duration(seconds: 2), () {
                            toastFuture.dismiss();
                          });

//                  Navigator.pop(context);
                        }
                      }

                    },
                  ),
                ),

                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(
                      bottom: Measurements.height * 0.04,
                      top: Measurements.height * 0.02),
                  // child: Text(
                  //   "$description",
                  //   style: TextStyle(color: Colors.black, fontSize: 13),
                  // )
                  child: Html(
                    data: description,
                    defaultTextStyle:
                        TextStyle(color: Colors.black, fontSize: 13),
                  ),
                ),
//          ColorButtonGrid(
//            colors: <Color>[
//              Colors.red,
//              Colors.blue,
//              Colors.green,
//              Colors.deepOrange,
//              Colors.red,
//              Colors.blue,
//              Colors.green,
//              Colors.deepOrange,
//              Colors.red,
//              Colors.blue,
//              Colors.green,
//              Colors.deepOrange
//            ],
//            controller: controller,
//            size: Measurements.height * 0.03,
//          ),
//          ColorButtonContainer(
//            displayColor: Colors.red,
//            size: Measurements.height * 0.03,
//            controller: controller,
//          ),
                isTablet
                    ? Padding(
                        padding:
                            EdgeInsets.only(bottom: Measurements.height * 0.02),
                      )
                    : Container(),
              ],
            );
          }),
    );
  }

  ColorButtonController controller = ColorButtonController();

  Future<int> getInventoryState(
      PosStateModel posStateModel, String productSku) async {
    print("getInventoryState: $posStateModel");
    var inventory;
    try {
      inventory = await posStateModel.getInventory(productSku);
      print("inventoryInfo: $inventory");
    } catch(e) {
      print("error: $e");
    }

    var inventoryData = InventoryModel.toMap(inventory);
    print("inventoryData: ${inventoryData.stock}");

    int stockData = 0;

    if (inventoryData.isTrackable) {
      if (inventoryData.stock != null) {
        if (inventoryData.stock <= 0) {
          stockData = 0;
        } else {
          stockData = inventoryData.stock;
        }
      } else {
        stockData = 0;
      }
    } else {
      stockData = 10;
    }

    return stockData;
  }
}

class StockText extends StatefulWidget {
  final PosStateModel parts;
  final String sku;
  final productStock;
  final int stc;

  StockText({this.parts, this.sku, @required this.productStock, this.stc});

  @override
  _StockTextState createState() => _StockTextState();
}

class _StockTextState extends State<StockText> {
  String value = "";
  Color color = Colors.white;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    value = (widget.stc > 0)
        ? Language.getProductListStrings("filters.quantity.inStock")
        : Language.getProductListStrings("filters.quantity.outStock");
    color = (widget.stc > 6)
        ? Colors.green
        : widget.stc > 0 ? Colors.orangeAccent : Colors.red;
    return Text(value, style: TextStyle(color: color));
  }
}

class DetailImage extends StatefulWidget {
  final ValueNotifier<int> currentVariant;

  final PosStateModel parts;
  final List<String> images;
  final int index;
  final bool haveVariants;

  DetailImage({
    @required this.currentVariant,
    @required this.parts,
    @required this.images,
    @required this.index,
    this.haveVariants,
  });

  @override
  createState() => _DetailImageState();
}

class _DetailImageState extends State<DetailImage> {
  ProductsModel currentProduct;
  int imageIndex;

  bool isPortrait = true;
  bool isTablet = false;

  @override
  void initState() {
    super.initState();
    widget.currentVariant.addListener(listener);

    setState(() {
      imageIndex = widget.index;
    });
  }

  listener() {
    setState(() {});
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    isTablet = isPortrait
        ? MediaQuery.of(context).size.width > 600
        : MediaQuery.of(context).size.height > 600;

    List<Widget> images = List();
    widget.images.forEach((f) {
      images.add(Container(
//        color: Colors.red,
        height:
            isTablet ? Measurements.width * 0.45 : Measurements.height * 0.4,
        width: isTablet ? Measurements.width * 0.45 : Measurements.height * 0.4,
        child: CachedNetworkImage(
          imageUrl: Env.storage + "/products/" + f,
          placeholder: (context, url) => Container(),
          errorWidget: (context, url, error) => Icon(Icons.error),
          fit: BoxFit.contain,
        ),
      ));
    });

    int _currentImage = imageIndex;

    customCarouselSlider = CustomCarouselSlider(
      realPage: imageIndex,
      startingPage: imageIndex,
      items: images,
      enableInfiniteScroll: false,
      viewportFraction: 1.0,
      aspectRatio: 1,
      scrollDirection: Axis.horizontal,
      onPageChanged: (index) {
        setState(() {
          _currentImage = index;
          imageIndex = index;
          print(_currentImage);
        });
      },
    );

    return Container(
      child: Column(
        children: <Widget>[
          Container(
//            color: Colors.green,
            height: isTablet
                ? Measurements.width * 0.45
                : Measurements.height * 0.4,
            width: isTablet
                ? Measurements.width * 0.45
                : Measurements.height * 0.4,
            child: customCarouselSlider,
//            child: Stack(children: [
//              customCarouselSlider,
//              images.length > 1
//                  ? Positioned(
////                      top: 0.0,
//                      left: 0,
//                      right: 0,
//                      bottom: -10,
//                      child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: map<Widget>(images, (index, url) {
//                          return Container(
//                            width: 8,
//                            height: 8,
//                            margin: EdgeInsets.symmetric(
//                                vertical: 10, horizontal: 2),
//                            decoration: BoxDecoration(
//                                shape: BoxShape.circle,
//                                color: _currentImage == index
//                                    ? Color.fromRGBO(0, 0, 0, 0.9)
//                                    : Color.fromRGBO(0, 0, 0, 0.4)),
//                          );
//                        }),
//                      ))
//                  : Container()
//            ]),
          ),
          Container(
            width: isTablet
                ? Measurements.width * 0.45
                : Measurements.height * 0.4,
            height: Measurements.height * 0.1,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: widget.images.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  child: Container(
                      height: Measurements.height * 0.1,
                      width: Measurements.height * 0.1,
                      padding: EdgeInsets.all(Measurements.width * 0.01),
                      child: CachedNetworkImage(
                        imageUrl:
                            Env.storage + "/products/" + widget.images[index],
                        placeholder: (context, url) => Container(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.contain,
                      )),
                  onTap: () {
                    setState(() {
                      imageIndex = index;
                      customCarouselSlider.jumpToPage(imageIndex);
                    });
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
