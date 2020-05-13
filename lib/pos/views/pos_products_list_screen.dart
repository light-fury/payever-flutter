import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../commons/views/custom_elements/custom_future_builder.dart';
import '../view_models/view_models.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'product_details.dart';
import 'webview_section.dart';
import 'pos_cart.dart';

class PosProductsListScreen extends StatefulWidget {
  final Terminal terminal;
  final Business business;

  PosProductsListScreen({@required this.terminal, @required this.business});

  @override
  createState() => _PosProductsListScreenState();
}

class _PosProductsListScreenState extends State<PosProductsListScreen> {
  bool isPortrait = true;
  bool isTablet = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PosStateModel posStateModel = Provider.of<PosStateModel>(context);
    PosCartStateModel posCartStateModel =
        Provider.of<PosCartStateModel>(context);
    GlobalStateModel globalStateModel = Provider.of<GlobalStateModel>(context);

    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    isTablet = isPortrait
        ? MediaQuery.of(context).size.width > 600
        : MediaQuery.of(context).size.height > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        height: posStateModel.getLoadMore ? Measurements.height * 0.0001 : 0,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            posStateModel.getLoadMore
                ? PosProductsLoader(posStateModel, globalStateModel)
                : Container(),
          ],
        ),
      ),
      appBar: AppBar(
        brightness: Brightness.light,
        leading: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black,
            ),
            onPressed: () {
              posCartStateModel.updateCart(false);
              Navigator.pop(context);
            }),
        centerTitle: true,
        title: Container(
          child: Text(
            widget.terminal?.name ?? "",
            style: TextStyle(color: Colors.black),
          ),
        ),
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
                        posCartStateModel.getCartHasItems
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
                      child: POSCart(parts: posStateModel),
                      type: PageTransitionType.fade,
                      duration: Duration(milliseconds: 10)));
            },
          ),
        ],
      ),
      body: widget.terminal != null
          ? CustomFutureBuilder<Object>(
              future: posStateModel.loadPosProductsList(widget.terminal),
              errorMessage: "Error loading products",
              loadingWidget: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black,
                ),
              ),
              onDataLoaded: (results) {
//          posStateModel.updateIsLoading(true);
                return posStateModel.isLoading
                    ? PosProductsLoader(
                        posStateModel,
                        globalStateModel,
                      )
                    : PosBody(posStateModel, globalStateModel);
              },
            )
          : Container(),
    );
  }
}

class PosBody extends StatefulWidget {
  final PosStateModel posStateModel;
  final GlobalStateModel globalStateModel;

  PosBody(this.posStateModel, this.globalStateModel);

  @override
  createState() => _PosBodyState();
}

class _PosBodyState extends State<PosBody> {
  ScrollController controller;

  void _scrollListener() {
    if (controller.position.extentAfter < 20) {
      if (widget.posStateModel.getPage < widget.posStateModel.getPageCount &&
          !widget.posStateModel.getLoadMore) {
        widget.posStateModel.updateLoadMore(true);
//        widget.posStateModel.updateFetchValues(false, true);
        widget.posStateModel.updatePage();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(_scrollListener);
  }

  bool isPortrait;
  bool isTablet;

  Future<void> _refresh() async {
    widget.posStateModel.refreshPage();
    widget.posStateModel.updateLoadMore(true);
    widget.posStateModel.updateProductList();
    widget.posStateModel
        .loadPosProductsList(widget.posStateModel.currentTerminal);
  }

  @override
  Widget build(BuildContext context) {
    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    isTablet = isPortrait
        ? MediaQuery.of(context).size.width > 600
        : MediaQuery.of(context).size.height > 600;

    List<Widget> prodList = List<Widget>();
    prodList = [];

    widget.posStateModel.getProductList.forEach((prod) {
//      var temp = widget.posStateModel.productStock[prod.sku] ?? "0";
      var _variants = prod.variants;
      bool oneVariant = true;
      if (_variants.isNotEmpty) {
        var _varEmpty =
            widget.posStateModel.productStock[_variants[0].sku] ?? "0";
        oneVariant =
            ((_varEmpty.contains("null") ? 0 : int.parse(_varEmpty ?? "0")) >
                0);
//        print(oneVariant);
      }
//      if(!(!((temp.contains("null")? 0:int.parse(temp??"0")) > 0) && prod.variants.isEmpty) && !((prod.variants.length == 1) && !oneVariant))
      prodList.add(ProductItem(
        currentProduct: prod,
        posStateModel: widget.posStateModel,
        globalStateModel: widget.globalStateModel,
      ));
    });

    return RefreshIndicator(
      onRefresh: _refresh,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: Measurements.width * (isTablet ? 0.03 : 0.05)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: Measurements.height * (isTablet ? 0.05 : 0.1),
              width: Measurements.width * (isTablet ? 0.3 : 0.8),
              padding: EdgeInsets.symmetric(
                  vertical: Measurements.height * (isTablet ? 0.01 : 0.02)),
              child: InkWell(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: Text(
                        Language.getCustomStrings("checkout_cart_type_amount"),
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          child: WebViewPayments(
                            posStateModel: widget.posStateModel,
                            url: null,
                          ),
                          type: PageTransitionType.fade,
                          duration: Duration(milliseconds: 10)));
                },
              ),
            ),
            //testing search
            // TextFormField(
            //   decoration: InputDecoration(
            //     hintText: "Search",
            //     border: InputBorder.none,
            //     icon: Container(child:SvgPicture.asset("assets/images/searchIcon.svg",height: Measurements.height * 0.0175,color:Colors.white,))
            //   ),
            //   onFieldSubmitted: (doc){
            //     widget.parts.productList.clear();
            //     widget.parts.search = doc;
            //     widget.parts.page = 1;
            //     widget.parts.searching.value = true;
            //   },
            // ),
            //
            //widget.parts.searching.value?Center(child:CircularProgressIndicator()):
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: Measurements.height * 0.02),
                child: !isTablet
                    ? ListView.builder(
                        controller: controller,
                        shrinkWrap: true,
                        itemCount: prodList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return prodList[index];
                        },
                      )
                    : GridView.builder(
                        controller: controller,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isPortrait ? 3 : 4,
                            childAspectRatio: 0.65),
                        itemCount: prodList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return prodList[index];
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductItem extends StatefulWidget {
  final ProductsModel currentProduct;
  final PosStateModel posStateModel;
  final GlobalStateModel globalStateModel;

  ProductItem({this.currentProduct, this.posStateModel, this.globalStateModel});

  @override
  createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  bool isPortrait;
  bool isTablet;
  int index;
  num price;
  Variants _variant;
  bool onSale;

  @override
  Widget build(BuildContext context) {
    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    isTablet = isPortrait
        ? MediaQuery.of(context).size.width > 600
        : MediaQuery.of(context).size.height > 600;
    if (widget.currentProduct.variants.isNotEmpty) {
      int i = 0;
      price = widget.currentProduct.variants[0].price;
      widget.currentProduct.variants.forEach((variant) {
        if (variant.price <= price) {
          price = variant.price;
          _variant = variant;
          index = i;
          onSale = !variant.hidden;
        }
        i++;
      });
    } else {
      index = null;
      onSale = !widget.currentProduct.hidden;
    }
    return Card(
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        child: Container(
          width:
              Measurements.width * (isTablet ? (isPortrait ? 0.3 : 0.3) : 0.8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    height: Measurements.width *
                        (isTablet ? (isPortrait ? 0.3 : 0.3) : 0.8),
                    width: Measurements.width *
                        (isTablet ? (isPortrait ? 0.3 : 0.3) : 0.8),
                    decoration: BoxDecoration(
                      color: widget.currentProduct.images.isEmpty
                          ? Colors.black.withOpacity(0.35)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(
                          widget.currentProduct.images.isEmpty ? 0 : 12),
                    ),
                  ),
                  widget.currentProduct.images.isEmpty
                      ? Center(
                          child: SvgPicture.asset(
                            "assets/images/noimage.svg",
                            color: Colors.white.withOpacity(0.7),
                            height: Measurements.width * (isTablet ? 0.1 : 0.2),
                          ),
                        )
                      : Container(
                          height: Measurements.width * (isTablet ? 0.3 : 0.8),
                          width: Measurements.width * (isTablet ? 0.3 : 0.8),
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: CachedNetworkImageProvider(
                              Env.storage +
                                  "/products/" +
                                  widget.currentProduct.images[0],
                            ),
                          )),
                          // child: CachedNetworkImage(
                          //   imageUrl: Env.Storage +
                          //       "/products/" +
                          //       widget.currentProduct.images[0],
                          //   placeholder: (context, url) => Container(),
                          //   errorWidget: (context, url, error) =>
                          //       Icon(Icons.error),
                          //   fit: BoxFit.contain,
                          // ),
                        ),
                ],
              ),
              onSale
                  ? Container(
                      alignment: Alignment.bottomCenter,
                      height: Measurements.height * 0.03,
                      child: Text(
                        "Sale",
                        style: TextStyle(
                            fontSize: 15,
                            color: widget.posStateModel.saleColor,
                            fontWeight: FontWeight.w300),
                      ),
                    )
                  : Container(
                      height: Measurements.height * 0.03,
                    ),
              Container(
                height: Measurements.height * 0.03,
                width: Measurements.width * (isTablet ? 0.4 : 0.8),
                alignment: Alignment.center,
                child: Text(
                  "${widget.currentProduct.title}",
                  style: TextStyle(
                      fontSize: 15,
                      color: widget.posStateModel.titleColor,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Container(
                  height: Measurements.height * 0.03,
                  alignment: Alignment.center,
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          index == null
                              ? "${widget.posStateModel.f.format(widget.currentProduct.price)}${Measurements.currency(widget.globalStateModel.currentBusiness.currency)}"
                              : "${widget.posStateModel.f.format(_variant.price)}${Measurements.currency(widget.globalStateModel.currentBusiness.currency)}",
                          style: TextStyle(
                              fontSize: 15,
                              color: widget.posStateModel.titleColor,
                              fontWeight: FontWeight.w400,
                              decoration: onSale
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none),
                        ),
                        onSale
                            ? Text(
                                index == null
                                    ? "  ${widget.posStateModel.f.format(widget.currentProduct.salePrice)}${Measurements.currency(widget.globalStateModel.currentBusiness.currency)}"
                                    : "  ${widget.posStateModel.f.format(_variant.salePrice)}${Measurements.currency(widget.globalStateModel.currentBusiness.currency)}",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: widget.posStateModel.saleColor,
                                    fontWeight: FontWeight.w400),
                              )
                            : Container(),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        onTap: () {

          Navigator.push(
              context,
              PageTransition(
                  child: ProductDetailsScreen(
                    parts: widget.posStateModel,
                    currentProduct: widget.currentProduct,
                    index: index,
                  ),
                  type: PageTransitionType.fade,
                  duration: Duration(milliseconds: 10)));
        },
      ),
    );
  }
}

class PosProductsLoader extends StatefulWidget {
  final PosStateCommonsModel posStateModel;
  final GlobalStateModel globalStateModel;

  PosProductsLoader(this.posStateModel, this.globalStateModel);

  @override
  createState() => _PosProductsLoaderState();
}

class _PosProductsLoaderState extends State<PosProductsLoader> {
//  int page = 1;
  int limit = 36;

  //int limit = 8;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var queryDocument = ''' 
              query {
                  getProductsByChannelSet(businessId: "${widget.globalStateModel.currentBusiness.id}", channelSetId: "${widget.posStateModel.currentTerminal?.channelSet ?? null}",search: "${widget.posStateModel.getSearch}",existInChannelSet: true, paginationLimit: $limit, pageNumber: ${widget.posStateModel.getPage}) {
                        products {      
                          images
                          uuid
                          title
                          description
                          hidden
                          price
                          salePrice
                          sku
                          barcode
                          variants {
                            id
                            images
                            title
                            description
                            hidden
                            price
                            salePrice
                            sku
                            barcode
                          }
                        }
                        info {
                          pagination {
                          page
                          page_count
                          per_page
                          item_count
                          }
                        }  
                  }
                }
              ''';

    return widget.posStateModel.getCurrentTerminal == null
        ? Center(
            child: const CircularProgressIndicator(
              backgroundColor: Colors.black,
            ),
          )
        : GraphQLProvider(
            client: widget.posStateModel.client,
            child: Query(
              options: QueryOptions(
                  variables: <String, dynamic>{}, document: queryDocument),
              builder: (QueryResult result, {VoidCallback refetch}) {
                if (result.errors != null) {
                  print(result.errors);
                  return Center(child: Text("Error while fetching data"));
                }
                if (result.loading) {
                  return Center(
                    child: const CircularProgressIndicator(
                      backgroundColor: Colors.black,
                    ),
                  );
                }

                result.data["getProductsByChannelSet"]["products"]
                    .forEach((prod) {
                  var tempProduct = ProductsModel.toMap(prod);
                  // if (widget.posStateModel.productList
                  //         .indexWhere((test) => test.sku == tempProduct.sku) <
                  //     0)
                  widget.posStateModel.addProductList(tempProduct);
                });
                if (widget.posStateModel.productList.isNotEmpty) {
                  Future.delayed(Duration(microseconds: 1)).then((_) {
                    widget.posStateModel.updatePageCount(
                        result.data["getProductsByChannelSet"]["info"]
                            ["pagination"]["page_count"]);
//                    widget.posStateModel.updateFetchValues(true, false);
                    widget.posStateModel.updateIsLoading(false);
                    widget.posStateModel.updateLoadMore(false);

                    result = null;
                  });
                }

//                return PosBody(widget.posStateModel, widget.globalStateModel);
                return Container();
              },
            ),
          );
  }
}
