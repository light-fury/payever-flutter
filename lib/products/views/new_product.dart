import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../network/network.dart';
import '../utils/utils.dart';
import '../view_models/view_models.dart';
import '../../commons/views/custom_elements/custom_elements.dart';
import '../../commons/views/screens/login/login.dart';
import 'product_screen.dart';
import 'product_categories.dart';
import 'product_channels.dart';
import 'product_inventory.dart';
import 'product_main.dart';
import 'product_shipping.dart';
import 'product_tax.dart';
import 'product_type.dart';
import 'product_variants.dart';
import 'product_visibility.dart';

ValueNotifier<GraphQLClient> clientForNewProduct({
  @required String uri,
  String subscriptionUri,
}) {
  Link link = HttpLink(uri: uri);
  if (subscriptionUri != null) {
    WebSocketLink webSocketLink = WebSocketLink(
        config: SocketClientConfig(
          autoReconnect: true,
          inactivityTimeout: Duration(seconds: 30),
        ),
        url: uri);
    print(webSocketLink);
    final AuthLink authLink = AuthLink(
      getToken: () => 'Bearer ${GlobalUtils.activeToken.accessToken}',
    );
    link = authLink.concat(link);
  }

  return ValueNotifier<GraphQLClient>(
    GraphQLClient(
      cache: InMemoryCache(),
      link: link,
    ),
  );
}

class NewProductScreenParts {
  bool isPortrait;
  bool isTablet;
  bool editMode;
  bool shippingRowOK = false;
  bool enabled = true;
  Color switchColor = Color(0XFF0084ff);
  ValueNotifier isLoading;
  bool havePOS = false;
  bool haveShop = false;
  String wallpaper;

  List<String> categoryList = List();
  List<String> images = List();
  List<Categories> categories = List();
  List<Inventory> inventories = List();
  List<Terminal> terminals = List();
  List<Shop> shops = List();
  List<ChannelSet> channels = List();

  var qKey = GlobalKey();
  final GlobalKey<FormState> popUpKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final popUpScaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AutoCompleteTextFieldState<String>> atfKey = GlobalKey();

  var openedRow = ValueNotifier(0);
  String business;
  String type;
  String currency;
  Widget mainForm;
  Widget inventoryForm;
  Widget shippingForm;
  Widget visibilityForm;
  Widget taxForm;
  Widget variantForm;
  Widget categoryForm;
  Widget channelForm;
  ProductsModel product = ProductsModel();
  List<Variants> variants = List();
  InventoryManagement invManager = InventoryManagement();

  final ValueNotifier<GraphQLClient> client = clientForNewProduct(
    uri: Env.products + "/products",
  );

  //inventory
  bool skuError = false;
  bool prodTrackInv = false;
  num prodStock = 0;

  //--
  //main
  bool nameError = false;
  bool priceError = false;
  bool descriptionError = false;
  bool onSaleError = false;
  bool onSale = false;

  //--
  //shipping
  bool weightError = false;
  bool widthError = false;
  bool lengthError = false;
  bool heightError = false;
//--
}

class NewProductScreen extends StatefulWidget {
  NewProductScreenParts _parts;
  String wallpaper;
  String business;
  String currency;
  State view;
  bool editMode;
  bool isFromDashboardCard;
  ValueNotifier isLoading;
  ProductsModel productEdit;
  String initialState;

  NewProductScreen({
    @required this.wallpaper,
    @required this.business,
    @required this.view,
    @required this.isFromDashboardCard,
    this.currency,
    this.editMode,
    this.productEdit,
    this.isLoading,
  });

  @override
  createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  AppBar _appBar;
  ButtonRow buttonRow;
  MainRow mainRow;

  //InventoryRow inventoryRow;
  CategoryRow categoryRow;
  ShippingRow shippingRow;
  VisibilityRow visibilityRow;
  TaxRow taxRow;
  VariantRow variantRow;
  ChannelRow channelRow;
  bool okToSave = false;

  listener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget._parts = NewProductScreenParts();
    widget._parts.wallpaper = widget.wallpaper;
    widget._parts.business = widget.business;
    widget._parts.openedRow.addListener(listener);
    widget._parts.currency = widget.currency;
    widget._parts.editMode = widget.editMode;
    widget._parts.isLoading = widget.isLoading;

    if (widget.editMode) {
      widget._parts.channels = widget.productEdit.channels;
      widget._parts.product = widget.productEdit;
      widget._parts.type = widget.productEdit.type;

      if (widget._parts.product.variants.isNotEmpty) {
        widget._parts.inventories = List();
        widget._parts.product.variants.forEach((f) {
          //Store all inventories
          ProductsApi api = ProductsApi();
          api
              .getInventory(widget.business,
                  GlobalUtils.activeToken.accessToken, f.sku, context)
              .then((inv) {
            InventoryModel currentInventory = InventoryModel.toMap(inv);
            widget._parts.invManager.addInventory(Inventory(
                amount: currentInventory.stock,
                barcode: currentInventory.barcode,
                sku: currentInventory.sku,
                tracking: currentInventory.isTrackable));
          });
        });
      } else {
        ProductsApi()
            .getInventory(widget.business, GlobalUtils.activeToken.accessToken,
                widget._parts.product.sku, context)
            .then((inv) {
          InventoryModel currentInventory = InventoryModel.toMap(inv);
          widget._parts.invManager.addInventory(Inventory(
              amount: currentInventory.stock,
              barcode: currentInventory.barcode,
              sku: currentInventory.sku,
              tracking: currentInventory.isTrackable));
        });
      }
    }
    // HERE
    buttonRow = ButtonRow(widget._parts.openedRow, widget._parts);
    mainRow = MainRow(parts: widget._parts, openedRow: widget._parts.openedRow);
    channelRow =
        ChannelRow(parts: widget._parts, openedRow: widget._parts.openedRow);
    //inventoryRow  = InventoryRow(parts: widget._parts, openedRow: widget._parts.openedRow);
    categoryRow =
        CategoryRow(parts: widget._parts, openedRow: widget._parts.openedRow);
    shippingRow =
        ShippingRow(parts: widget._parts, openedRow: widget._parts.openedRow);
    visibilityRow =
        VisibilityRow(parts: widget._parts, openedRow: widget._parts.openedRow);
//    taxRow = TaxRow();
    taxRow = TaxRow(parts: widget._parts, openedRow: widget._parts.openedRow);
    variantRow =
        VariantRow(parts: widget._parts, openedRow: widget._parts.openedRow);
  }

  Scaffold scaffold;
  ProductMainRow main;

  ProductInventoryRow inventory;

  ProductCategoryRow category;

  ProductVariantsRow variants;

  ProductShippingRow shipping;

  ProductVisibilityRow visibility;

  ProductTaxRow tax;
  ProductChannelsRow channels;
  ProductStateModel productStateModel;

  @override
  Widget build(BuildContext context) {
    GlobalStateModel globalStateModel = Provider.of<GlobalStateModel>(context);

    _appBar = AppBar(
      elevation: 0,
      actions: <Widget>[
        InkWell(
          child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(right: Measurements.width * 0.02),
              child: Text(Language.getProductStrings("save"))),
          onTap: () {
            save(widget.isFromDashboardCard);
          },
        ),
      ],
      title: Text(Language.getProductStrings("title")),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      leading: InkWell(
        radius: 20,
        child: Icon(IconData(58829, fontFamily: 'MaterialIcons')),
        onTap: () {
          if (widget.isFromDashboardCard) {
            productStateModel = Provider.of<ProductStateModel>(context);
            productStateModel.setRefresh(true);
            Navigator.pop(context);
            Navigator.push(
                context,
                PageTransition(
                    child: ProductScreen(
                      wallpaper: globalStateModel.currentWallpaper,
                      business: globalStateModel.currentBusiness,
                      posCall: false,
                    ),
                    type: PageTransitionType.fade));
          } else {
            productStateModel = Provider.of<ProductStateModel>(context);
            productStateModel.setRefresh(true);
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.push(
                context,
                PageTransition(
                    child: ProductScreen(
                      wallpaper: globalStateModel.currentWallpaper,
                      business: globalStateModel.currentBusiness,
                      posCall: false,
                    ),
                    type: PageTransitionType.fade));
          }
        },
      ),
    );
    List<Widget> rows = List();
    main = ProductMainRow(
      parts: widget._parts,
    );
    inventory = ProductInventoryRow(
      parts: widget._parts,
    );
    category = ProductCategoryRow(
      parts: widget._parts,
    );
    variants = ProductVariantsRow(
      parts: widget._parts,
    );
    channels = ProductChannelsRow(
      parts: widget._parts,
    );
    shipping = ProductShippingRow(
      parts: widget._parts,
    );
    tax = ProductTaxRow(
      parts: widget._parts,
    );
    visibility = ProductVisibilityRow(
      parts: widget._parts,
    );

    rows.add(main);
    if (widget._parts.product?.variants?.isEmpty ?? false) rows.add(inventory);
    rows.add(category);
    rows.add(variants);
    rows.add(channels);
    rows.add(shipping);
    rows.add(tax);
    rows.add(visibility);

    List<Widget> heads = List();
    heads.add(Text(
      Language.getProductStrings("sections.main"),
      style: TextStyle(fontSize: AppStyle.fontSizeTabTitle()),
    ));
    if (widget._parts.product?.variants?.isEmpty ?? false)
      heads.add(Text(
        Language.getProductStrings("sections.inventory"),
        style: TextStyle(fontSize: AppStyle.fontSizeTabTitle()),
      ));
    heads.add(Text(
      Language.getProductStrings("sections.category"),
      style: TextStyle(fontSize: AppStyle.fontSizeTabTitle()),
    ));
    heads.add(Text(
      Language.getProductStrings("sections.variants"),
      style: TextStyle(fontSize: AppStyle.fontSizeTabTitle()),
    ));
    heads.add(Text(
      Language.getProductStrings("sections.channels"),
      style: TextStyle(fontSize: AppStyle.fontSizeTabTitle()),
    ));
    heads.add(Text(
      Language.getProductStrings("sections.shipping"),
      style: TextStyle(fontSize: AppStyle.fontSizeTabTitle()),
    ));
    heads.add(Text(
      Language.getProductStrings("sections.taxes"),
      style: TextStyle(fontSize: AppStyle.fontSizeTabTitle()),
    ));
    heads.add(Text(
      Language.getProductStrings("sections.visibility"),
      style: TextStyle(fontSize: AppStyle.fontSizeTabTitle()),
    ));

    CustomExpansionTile productRowsList = CustomExpansionTile(
        isWithCustomIcon: true,
        scrollable: false,
        headerColor: Colors.transparent,
        widgetsBodyList: rows,
        widgetsTitleList: heads);
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        widget._parts.isPortrait = orientation == Orientation.portrait;
        widget._parts.isTablet = widget._parts.isPortrait
            ? MediaQuery.of(context).size.width > 600
            : MediaQuery.of(context).size.height > 600;
        return BackgroundBase(
          true,
          currentKey: widget._parts.scaffoldKey,
          appBar: _appBar,
          body: SingleChildScrollView(
            child: InkWell(
              highlightColor: Colors.transparent,
              onTap: () => _removeFocus(context),
              child: Form(
                key: widget._parts._formKey,
                child: Column(
                  children: <Widget>[
                    buttonRow,
                    productRowsList,
                  ],
                ),
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

  void save(bool fromDashboard) {
    var a = widget._parts._formKey.currentState;
    a.validate();
    okToSave = mainRow.isMainRowOK &&
        inventory.isInventoryRowOK &&
        shipping.isShippingRowOK;

    ProductsApi()
        .getBusinesses(GlobalUtils.activeToken.accessToken, context)
        .then((_) {
      if (okToSave) {
        a.save();
        String _images = "";
        widget._parts.images.forEach((name) {
          _images += '"$name"';
        });
        String variants = "";
        widget._parts.product.variants.forEach((v) {
          String images = "";
          v.images.forEach((name) {
            images += '"$name"';
          });
          String id = widget._parts.editMode && (v.id != null)
              ? '"${v.id}"'
              : '"${Uuid().v4()}"';
          if (id.contains("null")) {
            id = '"${Uuid().v4()}"';
          }
          print(
              "id: ${widget._parts.editMode && (v.id != null) ? '"${v.id}"' : '"${Uuid().v4()}"'}");
          variants +=
              '{title: "${v.title}", description: "${v.description}",price: ${v.price}, images: [$images], hidden: ${v.hidden}, salePrice: ${v.salePrice}, sku: "${v.sku}", barcode: "${v.barcode}",id: $id}';
        });
        String stringCategories = "";
        widget._parts.categoryList.forEach((f) {
          Categories c = widget._parts.categories
              .where((test) => test.title.toLowerCase() == f.toLowerCase())
              .toList()[0];
          print(c);
          stringCategories +=
              '{_id: "${c.id}", businessUuid: "${widget.business}", title: "${c.title}",slug: "${c.slug}"}';
        });

        String channels = "";
        widget._parts.channels.forEach((ch) {
          channels += '{id:"${ch.id}", type: "${ch.type}", name: "${ch.name}"}';
        });

        String doc;
        if (!widget._parts.editMode) {
          doc = '''
        mutation createProduct {
            createProduct(product: {businessUuid: "${widget._parts.business}", images: [$_images], title: "${widget._parts.product.title}", description: "${widget._parts.product.description}", hidden: ${widget._parts.product.hidden} , price: ${widget._parts.product.price}, salePrice: ${widget._parts.product.salePrice}, sku: "${widget._parts.product.sku == null ? "" : widget._parts.product.sku}", barcode: "${widget._parts.product.barcode == null ? "" : widget._parts.product.barcode}", type: "${widget._parts.type}", enabled: ${widget._parts.enabled}, channelSets: [$channels], categories: [$stringCategories], variants: [$variants], shipping: {free: ${widget._parts.product.shipping.free}, general: ${widget._parts.product.shipping.general}, weight: ${widget._parts.product.shipping.weight}, width: ${widget._parts.product.shipping.width}, length: ${widget._parts.product.shipping.length}, height:  ${widget._parts.product.shipping.height}}}) {
                title
                uuid
                }
              }
        ''';
        } else {
          doc = '''
        mutation updateProduct {
            updateProduct(product: {businessUuid: "${widget._parts.business}", images: [$_images], uuid: "${widget.productEdit.uuid}", title: "${widget._parts.product.title}", description: "${widget._parts.product.description}", hidden: ${widget._parts.product.hidden} , price: ${widget._parts.product.price}, salePrice: ${widget._parts.product.salePrice}, sku: "${widget._parts.product.sku == null ? "" : widget._parts.product.sku}", barcode: "${widget._parts.product.barcode == null ? "" : widget._parts.product.barcode}", type: "${widget._parts.type}", enabled: ${widget._parts.product.enabled}, channelSets: [$channels], categories: [$stringCategories], variants: [$variants], shipping: {free: ${widget._parts.product.shipping.free}, general: ${widget._parts.product.shipping.general}, weight: ${widget._parts.product.shipping.weight}, width: ${widget._parts.product.shipping.width}, length: ${widget._parts.product.shipping.length}, height:  ${widget._parts.product.shipping.height}}}) {
                title
                uuid
                }
              }
        ''';
        }

        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    color: Colors.transparent,
                    height: Measurements.width * 0.3,
                    width: Measurements.width * 0.3,
                    child: GraphQLProvider(
                      client: widget._parts.client,
                      child: Query(
                        options: QueryOptions(
                            variables: <String, dynamic>{}, document: doc),
                        builder: (QueryResult result, {VoidCallback refetch}) {
                          if (result.errors != null) {
                            return Column(
                              children: <Widget>[
                                Text("Error while creating/updating a product"),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.pop(context); //pop on error
                                  },
                                )
                              ],
                            );
                          }
                          if (result.loading) {
                            return Center(
                              child: const CircularProgressIndicator(),
                            );
                          }
                          return OrientationBuilder(
                            builder: (BuildContext context,
                                Orientation orientation) {
                              widget._parts.invManager.saveInventories(
                                  widget.business,
                                  context,
                                  Provider.of<GlobalStateModel>(context),
                                  widget.isFromDashboardCard);
                              return Container(
                                  height: Measurements.width * 0.3,
                                  width: Measurements.width * 0.3,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ));
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            });
      } else {
        SnackBar snackBar = SnackBar(
          backgroundColor: Colors.black.withOpacity(0.5),
          content: Text("Please fill required fields"),
          duration: Duration(seconds: 2),
        );
        //Scaffold.of(context).showSnackBar(snackBar);
        widget._parts.scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }).catchError((onError) {
      if (onError.toString().contains("401")) {
        GlobalUtils.clearCredentials();
        Navigator.pushReplacement(
            context,
            PageTransition(
                child: LoginScreen(), type: PageTransitionType.fade));
      }
    });
  }
}

class MainRow extends StatefulWidget {
  ValueNotifier openedRow;
  NewProductScreenParts parts;
  String currentImage;

  MainRow({this.openedRow, this.parts});

  get isMainRowOK {
    parts.product.hidden = parts.product.hidden ?? true;
    return !(parts.nameError || parts.priceError || parts.descriptionError) &&
        !(!parts.product.hidden && parts.onSaleError);
  }

  bool isOpen = true;
  bool haveImage = false;

  @override
  _MainRowState createState() => _MainRowState();
}

class _MainRowState extends State<MainRow> {
  listener() {
    setState(() {
      if (widget.openedRow.value == 0) {
        widget.isOpen = !widget.isOpen;
      } else {
        widget.isOpen = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.openedRow.addListener(listener);
    if (widget.parts.editMode) {
      widget.haveImage = widget.parts.product.images.length > 0;
      if (widget.haveImage) {
        widget.currentImage = widget.parts.product.images[0];
        widget.parts.images = widget.parts.product.images;
      }
    }
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
    widget.parts.mainForm = ProductMainRow(parts: widget.parts);
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          ),
          child: InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Text(Language.getProductStrings("sections.main")),
                  padding: EdgeInsets.symmetric(
                      horizontal: Measurements.width * 0.05),
                ),
                IconButton(
                  icon: Icon(widget.isOpen ? Icons.remove : Icons.add),
                  onPressed: () {
                    widget.openedRow.notifyListeners();
                    widget.openedRow.value = 0;
                  },
                ),
              ],
            ),
            onTap: () {
              widget.openedRow.notifyListeners();
              widget.openedRow.value = 0;
            },
          ),
        ),
        AnimatedContainer(
          color: Colors.white.withOpacity(0.05),
          height: widget.isOpen ? Measurements.height * 0.62 : 0,
          duration: Duration(milliseconds: 200),
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: Measurements.width * 0.025),
            color: Colors.black.withOpacity(0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            height: Measurements.height * 0.3,
                            child: !widget.haveImage
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          child: SvgPicture.asset(
                                        "images/insertimageicon.svg",
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
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                          onTap: () {
                                            getImage();
                                          },
                                        ),
                                      ),
                                    ],
                                  )
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
                                          height: Measurements.height * 0.1,
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
                                                      alignment:
                                                          Alignment.topRight,
                                                      children: <Widget>[
                                                          Container(
                                                              padding: EdgeInsets
                                                                  .all(Measurements
                                                                          .width *
                                                                      0.02),
                                                              child: InkWell(
                                                                child:
                                                                    Container(
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
                                                                          BorderRadius.circular(
                                                                              8)),
                                                                  child: Image
                                                                      .network(
                                                                    Env.storage +
                                                                        "/products/" +
                                                                        widget
                                                                            .parts
                                                                            .images[index],
                                                                    fit: BoxFit
                                                                        .contain,
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  setState(() {
                                                                    widget
                                                                        .currentImage = widget
                                                                            .parts
                                                                            .images[
                                                                        index];
                                                                  });
                                                                },
                                                              )),
                                                          InkWell(
                                                            child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height: Measurements
                                                                        .height *
                                                                    0.03,
                                                                width: Measurements
                                                                        .height *
                                                                    0.03,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .black,
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
                                                                widget.parts
                                                                    .images
                                                                    .removeAt(
                                                                        index);
                                                                if (widget
                                                                        .parts
                                                                        .images
                                                                        .length ==
                                                                    0) {
                                                                  widget.haveImage =
                                                                      false;
                                                                }
                                                              });
                                                            },
                                                          ),
                                                        ])
                                                  : Container(
                                                      padding: EdgeInsets.all(
                                                          Measurements.width *
                                                              0.02),
                                                      child: Container(
                                                          height: Measurements
                                                                  .height *
                                                              0.07,
                                                          width: Measurements
                                                                  .height *
                                                              0.07,
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
                          height: Measurements.height * 0.3,
                          child: widget.parts.mainForm,
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        //--
        Container(
            color: Colors.white.withOpacity(0.1),
            child: widget.isOpen
                ? Divider(
                    color: Colors.white.withOpacity(0),
                  )
                : Divider(
                    color: Colors.white,
                  )),
        //
      ],
    );
  }
}

// // Inventory
// class InventoryRow extends StatefulWidget {
//   ValueNotifier openedRow;
//   NewProductScreenParts parts;
//   num inv = 0;

//   bool isOpen = false;
//   bool trackInv = false;

//   bool get isInventoryRowOK {
//     return parts.product.variants.length>0?
//      true:
//      !parts.skuError;
//   }

//   InventoryRow({this.openedRow, this.parts});

//   @override
//   _InventoryRowState createState() => _InventoryRowState();
// }

// class _InventoryRowState extends State<InventoryRow> {
//   listener() {
//     setState(() {
//       if (widget.openedRow.value == 1) {
//         widget.isOpen = !widget.isOpen;
//       } else {
//         widget.isOpen = false;
//       }
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     widget.openedRow.addListener(listener);

//   }

//   @override
//   Widget build(BuildContext context) {
//     widget.parts.inventoryForm = ProductInventoryRow(parts: widget.parts);
//     return Column(children: <Widget>[
//       Container(
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.1),
//         ),
//         child: InkWell(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Container(
//                 child: Text(Language.getProductStrings("sections.inventory")),
//                 padding:
//                     EdgeInsets.symmetric(horizontal: Measurements.width * 0.05),
//               ),
//               IconButton(
//                 icon: Icon(widget.isOpen ? Icons.remove : Icons.add),
//                 onPressed: () {
//                   widget.openedRow.notifyListeners();
//                   widget.openedRow.value = 1;
//                 },
//               )
//             ],
//           ),
//           onTap: (){
//               widget.openedRow.notifyListeners();
//               widget.openedRow.value = 1;
//             },
//         ),
//       ),
//       AnimatedContainer(
//         color: Colors.white.withOpacity(0.05),
//         height: widget.isOpen
//             ? Measurements.height * (widget.parts.isTablet ? 0.12 : 0.16)
//             : 0,
//         duration: Duration(milliseconds: 200),
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: Measurements.width * 0.025),
//           color: Colors.black.withOpacity(0.05),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Row(
//                 mainAxisSize: MainAxisSize.max,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       Container(
//                         height: Measurements.height *
//                             (widget.parts.isTablet ? 0.11 : 0.15),
//                         child: widget.parts.inventoryForm,
//                       )
//                     ],
//                   )
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//       Container(
//           color: Colors.white.withOpacity(0.1),
//           child: widget.isOpen
//               ? Divider(
//                   color: Colors.white.withOpacity(0),
//                 )
//               : Divider(
//                   color: Colors.white,
//                 )),
//     ]);
//   }
// }
//Inventory
//--------
//Category
class CategoryRow extends StatefulWidget {
  ValueNotifier openedRow;
  NewProductScreenParts parts;
  bool trackInv = false;
  bool isOpen = false;
  List<String> sugestions = List();
  String doc = "";
  String currentCat = "";

  CategoryRow({this.parts, this.openedRow});

  @override
  _CategoryRowState createState() => _CategoryRowState();
}

class _CategoryRowState extends State<CategoryRow> {
  listener() {
    setState(() {
      if (widget.openedRow.value == 2) {
        widget.isOpen = !widget.isOpen;
      } else {
        widget.isOpen = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.openedRow.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    widget.parts.categoryForm = ProductCategoryRow(
      parts: widget.parts,
    );
    return Column(children: <Widget>[
      Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
        ),
        child: InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Text(Language.getProductStrings("sections.category")),
                padding:
                    EdgeInsets.symmetric(horizontal: Measurements.width * 0.05),
              ),
              IconButton(
                icon: Icon(widget.isOpen ? Icons.remove : Icons.add),
                onPressed: () {
                  widget.openedRow.notifyListeners();
                  widget.openedRow.value = 2;
                },
              )
            ],
          ),
          onTap: () {
            widget.openedRow.notifyListeners();
            widget.openedRow.value = 2;
          },
        ),
      ),
      AnimatedContainer(
        color: Colors.white.withOpacity(0.05),
        height: widget.isOpen
            ? Measurements.height * (widget.parts.isTablet ? 0.12 : 0.16)
            : 0,
        duration: Duration(milliseconds: 200),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: Measurements.width * 0.025),
          color: Colors.black.withOpacity(0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: Measurements.height *
                            (widget.parts.isTablet ? 0.1 : 0.14),
                        child: widget.parts.categoryForm,
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
      Container(
          color: Colors.white.withOpacity(0.1),
          child: widget.isOpen
              ? Divider(
                  color: Colors.white.withOpacity(0),
                )
              : Divider(
                  color: Colors.white,
                )),
    ]);
  }
}

//Category
//------
//Variant

enum DismissDialogAction {
  cancel,
  discard,
  save,
}

class VariantRow extends StatefulWidget {
  ValueNotifier openedRow;
  NewProductScreenParts parts;
  bool trackInv = false;
  bool isOpen = false;
  ValueNotifier quantity = ValueNotifier(0);

  VariantRow({this.parts, this.openedRow});

  @override
  _VariantRowState createState() => _VariantRowState();
}

class _VariantRowState extends State<VariantRow> {
  listener() {
    setState(() {
      if (widget.openedRow.value == 3) {
        widget.isOpen = !widget.isOpen;
      } else {
        widget.isOpen = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.openedRow.addListener(listener);
    widget.quantity.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    widget.parts.variantForm = ProductVariantsRow(
      parts: widget.parts,
    );
    return Column(children: <Widget>[
      Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
        ),
        child: InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Text(Language.getProductStrings("sections.variants")),
                padding:
                    EdgeInsets.symmetric(horizontal: Measurements.width * 0.05),
              ),
              Container(
                child: Text(
                    "${widget.parts.product.variants.length} ${Language.getProductStrings("menu.common.sub.variants")}"),
              ),
              IconButton(
                icon: Icon(widget.isOpen ? Icons.remove : Icons.add),
                onPressed: () {
                  widget.openedRow.notifyListeners();
                  widget.openedRow.value = 3;
                },
              )
            ],
          ),
          onTap: () {
            widget.openedRow.notifyListeners();
            widget.openedRow.value = 3;
          },
        ),
      ),
      AnimatedContainer(
        color: Colors.white.withOpacity(0.05),
        height: widget.isOpen
            ? (Measurements.height * (widget.parts.isTablet ? 0.07 : 0.09) +
                (Measurements.height *
                    (widget.parts.isTablet ? 0.05 : 0.07) *
                    widget.parts.product.variants.length))
            : 0,
        duration: Duration(milliseconds: 200),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: Measurements.width * 0.025),
          color: Colors.black.withOpacity(0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: Measurements.height *
                                (widget.parts.isTablet ? 0.05 : 0.07) +
                            (Measurements.height *
                                (widget.parts.isTablet ? 0.05 : 0.07) *
                                widget.parts.product.variants.length),
                        child: widget.parts.variantForm,
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
      Container(
          color: Colors.white.withOpacity(0.1),
          child: widget.isOpen
              ? Divider(
                  color: Colors.white.withOpacity(0),
                )
              : Divider(
                  color: Colors.white,
                )),
    ]);
  }
}

//Shipping
class ShippingRow extends StatefulWidget {
  ValueNotifier openedRow;
  NewProductScreenParts parts;
  bool isOpen = false;

  get isShippingRowOK {
    return !(parts.weightError ||
        parts.widthError ||
        parts.lengthError ||
        parts.heightError);
  }

  ShippingRow({@required this.parts, @required this.openedRow});

  @override
  _ShippingRowState createState() => _ShippingRowState();
}

class _ShippingRowState extends State<ShippingRow> {
  List<Widget> wlh;

  listener() {
    setState(() {
      if (widget.openedRow.value == 5) {
        widget.isOpen = !widget.isOpen;
      } else {
        widget.isOpen = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.openedRow.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    widget.parts.shippingForm = ProductShippingRow(parts: widget.parts);
    return Column(children: <Widget>[
      Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
        ),
        child: InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Text(Language.getProductStrings("sections.shipping")),
                padding:
                    EdgeInsets.symmetric(horizontal: Measurements.width * 0.05),
              ),
              IconButton(
                icon: Icon(widget.isOpen ? Icons.remove : Icons.add),
                onPressed: () {
                  widget.openedRow.notifyListeners();
                  widget.openedRow.value = 5;
                },
              )
            ],
          ),
          onTap: () {
            widget.openedRow.notifyListeners();
            widget.openedRow.value = 5;
          },
        ),
      ),
      AnimatedContainer(
        color: Colors.white.withOpacity(0.05),
        height: widget.isOpen
            ? Measurements.height * (widget.parts.isTablet ? 0.25 : 0.50)
            : 0,
        duration: Duration(milliseconds: 200),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: Measurements.width * 0.025),
          color: Colors.black.withOpacity(0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: Measurements.height *
                            (widget.parts.isTablet ? 0.22 : 0.45),
                        child: widget.parts.shippingForm,
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
      Container(
          color: Colors.white.withOpacity(0.1),
          child: widget.isOpen
              ? Divider(
                  color: Colors.white.withOpacity(0),
                )
              : Divider(
                  color: Colors.white,
                )),
    ]);
  }
}

//class TaxRow extends StatelessWidget {
//
//  @override
//  Widget build(BuildContext context) {
//    return ExpandableListView(
//      iconData: Icons.shopping_basket,
//      title: "TaxRow",
//      isExpanded: true,
//      widgetList: Center(child: Text("Tax Row"),),
//    );
//  }
//
//}

class TaxRow extends StatefulWidget {
  ValueNotifier openedRow;
  NewProductScreenParts parts;
  bool isOpen = false;

  bool freeShipping = false;
  bool generalShipping = false;

  TaxRow({@required this.parts, @required this.openedRow});

  @override
  _TaxRowState createState() => _TaxRowState();
}

class _TaxRowState extends State<TaxRow> {
  listener() {
    setState(() {
      if (widget.openedRow.value == 6) {
        widget.isOpen = !widget.isOpen;
      } else {
        widget.isOpen = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.openedRow.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    widget.parts.taxForm = Container(
      width: Measurements.width * 0.9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        width: Measurements.width * 0.9,
        child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: Measurements.width * 0.025),
            alignment: Alignment.center,
            height: Measurements.height * (widget.parts.isTablet ? 0.05 : 0.07),
            child: PopupMenuButton(
              padding: EdgeInsets.zero,
              child: ListTile(
                title: const Text('Default taxes apply'),
              ),
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[],
            )),
      ),
    );
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
          ),
          child: InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Text(Language.getProductStrings("sections.taxes")),
                  padding: EdgeInsets.symmetric(
                      horizontal: Measurements.width * 0.05),
                ),
                IconButton(
                  icon: Icon(widget.isOpen ? Icons.remove : Icons.add),
                  onPressed: () {
                    widget.openedRow.notifyListeners();
                    widget.openedRow.value = 6;
                  },
                )
              ],
            ),
            onTap: () {
              widget.openedRow.notifyListeners();
              widget.openedRow.value = 6;
            },
          ),
        ),
        AnimatedContainer(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
          ),
          height: widget.isOpen
              ? Measurements.height * (widget.parts.isTablet ? 0.07 : 0.09)
              : 0,
          duration: Duration(milliseconds: 200),
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: Measurements.width * 0.025),
            color: Colors.black.withOpacity(0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: Measurements.height *
                              (widget.parts.isTablet ? 0.05 : 0.07),
                          child: widget.parts.taxForm,
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        Container(
            color: Colors.white.withOpacity(0.1),
            child: widget.isOpen
                ? Divider(
                    color: Colors.white.withOpacity(0),
                  )
                : Divider(
                    color: Colors.white,
                  )),
      ],
    );
  }
}

class VisibilityRow extends StatefulWidget {
  ValueNotifier openedRow;
  NewProductScreenParts parts;
  bool isOpen = false;
  bool enabled = false;

  VisibilityRow({@required this.parts, @required this.openedRow});

  @override
  _VisibilityRowState createState() => _VisibilityRowState();
}

class _VisibilityRowState extends State<VisibilityRow> {
  listener() {
    setState(() {
      if (widget.openedRow.value == 7) {
        widget.isOpen = !widget.isOpen;
      } else {
        widget.isOpen = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.openedRow.addListener(listener);
    if (widget.parts.editMode) {
      widget.enabled = widget.parts.product.enabled ?? true;
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.parts.visibilityForm = ProductVisibilityRow(
      parts: widget.parts,
    );
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(widget.isOpen ? 0 : 16),
                  bottomRight: Radius.circular(widget.isOpen ? 0 : 16))),
          child: InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child:
                      Text(Language.getProductStrings("sections.visibility")),
                  padding: EdgeInsets.symmetric(
                      horizontal: Measurements.width * 0.05),
                ),
                IconButton(
                  icon: Icon(widget.isOpen ? Icons.remove : Icons.add),
                  onPressed: () {
                    widget.openedRow.notifyListeners();
                    widget.openedRow.value = 7;
                  },
                )
              ],
            ),
            onTap: () {
              widget.openedRow.notifyListeners();
              widget.openedRow.value = 7;
            },
          ),
        ),
        AnimatedContainer(
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(widget.isOpen ? 16 : 0),
                  bottomRight: Radius.circular(widget.isOpen ? 16 : 0))),
          height: widget.isOpen
              ? Measurements.height * (widget.parts.isTablet ? 0.07 : 0.09)
              : 0,
          duration: Duration(milliseconds: 200),
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: Measurements.width * 0.025),
            color: Colors.black.withOpacity(0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: Measurements.height *
                              (widget.parts.isTablet ? 0.05 : 0.07),
                          child: widget.parts.visibilityForm,
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class ChannelRow extends StatefulWidget {
  ValueNotifier openedRow;
  NewProductScreenParts parts;
  bool isOpen = false;
  num size = 0;

  ChannelRow({@required this.openedRow, @required this.parts});

  @override
  _ChannelRowState createState() => _ChannelRowState();
}

class _ChannelRowState extends State<ChannelRow> {
  listener() {
    setState(() {
      if (widget.openedRow.value == 4) {
        widget.isOpen = !widget.isOpen;
      } else {
        widget.isOpen = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.openedRow.addListener(listener);
    ProductsApi api = ProductsApi();
    api
        .getTerminal(
            widget.parts.business, GlobalUtils.activeToken.accessToken, context)
        .then((terminals) {
      terminals.forEach((term) {
        widget.parts.terminals.add(Terminal.toMap(term));
      });
      widget.size += terminals.length;
      setState(() {
        widget.parts.havePOS = terminals.isNotEmpty;
      });
    }).catchError((onError) {
      print(onError);
    });
    api
        .getShop(
            widget.parts.business, GlobalUtils.activeToken.accessToken, context)
        .then((shops) {
      shops.forEach((shop) {
        widget.parts.shops.add(Shop.toMap(shop));
      });
      widget.size += shops.length;
      setState(() {
        widget.parts.haveShop = shops.isNotEmpty;
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.parts.channelForm = Container(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //POS
            widget.parts.havePOS
                ? Container(
                    height: Measurements.height *
                        (widget.parts.isTablet ? 0.05 : 0.07),
                    width: Measurements.width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SvgPicture.asset(
                          "assets/images/posicon.svg",
                          height: Measurements.height *
                              (widget.parts.isTablet ? 0.02 : 0.025),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(right: Measurements.width * 0.02),
                        ),
                        Text(Language.getWidgetStrings("widgets.pos.title"))
                      ],
                    ),
                  )
                : Container(),
            widget.parts.havePOS
                ? Container(
                    width: Measurements.width * 0.8,
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
                            crossAxisAlignment: CrossAxisAlignment.end,
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
                                    Text(widget.parts.terminals[index].name),
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
                    width: Measurements.width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SvgPicture.asset(
                          "assets/images/shopicon.svg",
                          height: Measurements.height *
                              (widget.parts.isTablet ? 0.02 : 0.025),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(right: Measurements.width * 0.02),
                        ),
                        Text(Language.getWidgetStrings("widgets.store.title"))
                      ],
                    ),
                  )
                : Container(),
            widget.parts.haveShop
                ? Container(
                    width: Measurements.width * 0.8,
                    child: Center(
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
                                      bottomLeft: Radius.circular(index ==
                                              (widget.parts.shops.length - 1)
                                          ? 16
                                          : 0),
                                      bottomRight: Radius.circular(index ==
                                              (widget.parts.shops.length - 1)
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
                                    Text(widget.parts.shops[index].name),
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
                    ))
                : Container(),
          ]),
    );
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
          ),
          child: InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Text(Language.getProductStrings("sections.channels")),
                  padding: EdgeInsets.symmetric(
                      horizontal: Measurements.width * 0.05),
                ),
                Row(
                  children: <Widget>[
                    widget.parts.havePOS
                        ? Container(
                            padding: EdgeInsets.only(
                                right: Measurements.width * (0.02)),
                            child: SvgPicture.asset("assets/images/posicon.svg",
                                height: Measurements.height * 0.02))
                        : Container(),
                    widget.parts.haveShop
                        ? Container(
                            padding: EdgeInsets.only(
                                right: Measurements.width * (0.02)),
                            child: SvgPicture.asset(
                                "assets/images/shopicon.svg",
                                height: Measurements.height * 0.02))
                        : Container(),
                  ],
                ),
                IconButton(
                  icon: Icon(widget.isOpen ? Icons.remove : Icons.add),
                  onPressed: () {
                    widget.openedRow.notifyListeners();
                    widget.openedRow.value = 4;
                  },
                )
              ],
            ),
            onTap: () {
              widget.openedRow.notifyListeners();
              widget.openedRow.value = 4;
            },
          ),
        ),
        AnimatedContainer(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
          ),
          height: widget.isOpen
              ? ((Measurements.height * (widget.parts.isTablet ? 0.07 : 0.09)) +
                      (Measurements.height *
                              (widget.parts.isTablet ? 0.055 : 0.075)) *
                          widget.size) +
                  (Measurements.height *
                      ((widget.parts.haveShop && widget.parts.havePOS)
                          ? (widget.parts.isTablet ? 0.05 : 0.07)
                          : 0))
              : 0,
          duration: Duration(milliseconds: 200),
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: Measurements.width * 0.025),
            color: Colors.black.withOpacity(0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: Measurements.height *
                                  (widget.parts.isTablet ? 0.05 : 0.07) +
                              ((Measurements.height *
                                      (widget.parts.isTablet ? 0.055 : 0.075)) *
                                  widget.size) +
                              (Measurements.height *
                                  ((widget.parts.haveShop &&
                                          widget.parts.havePOS)
                                      ? (widget.parts.isTablet ? 0.05 : 0.07)
                                      : 0)),
                          child: widget.parts.channelForm,
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        Container(
            color: Colors.white.withOpacity(0.1),
            child: widget.isOpen
                ? Divider(
                    color: Colors.white.withOpacity(0),
                  )
                : Divider(
                    color: Colors.white,
                  )),
      ],
    );
  }
}
