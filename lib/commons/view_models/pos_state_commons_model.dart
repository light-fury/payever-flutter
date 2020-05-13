import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

import 'global_state_model.dart';
import '../models/models.dart';
import '../network/network.dart';
import '../utils/utils.dart';

ValueNotifier<GraphQLClient> clientFor({
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
    print("webSocketLink: $webSocketLink");

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

class PosStateCommonsModel extends ChangeNotifier {
  final GlobalStateModel globalStateModel;

  PosStateCommonsModel(this.globalStateModel);

  String get accessToken => GlobalUtils.activeToken.accessToken;

  String get businessId => globalStateModel.currentBusiness.id;

  Terminal currentTerminal;

  Terminal get getCurrentTerminal => currentTerminal;

  Business business;

  Business get getBusiness => globalStateModel.currentBusiness;

  Cart shoppingCart = Cart();
  List<ProductsModel> productList = List<ProductsModel>();

  List<ProductsModel> get getProductList => productList;

  Map<String, String> productStock = Map();

  Map<String, String> get getProductStock => productStock;

  bool smsEnabled = false;
  String shoppingCartID = "";
  String url;

  bool isTablet;
  bool isPortrait;

  int pageCount;

  int get getPageCount => pageCount;

  int page = 1;

  int get getPage => page;

  String search = "";

  String get getSearch => search;

  bool loadMore = false;

  bool get getLoadMore => loadMore;

  bool isLoading = true;

  bool get getIsLoading => isLoading;

  bool haveProducts = false;

  bool get getHaveProducts => haveProducts;

  bool dataFetched = true;

  bool get getDataFetched => dataFetched;

  int openSection = 0;

  int get getOpenSection => openSection;

  updateOpenSection(int value) {
    openSection = value;
    notifyListeners();
  }

  final ValueNotifier<GraphQLClient> client = clientFor(
    uri: Env.products + "/products",
  );

  Checkout currentCheckout;
  Color titleColor = Colors.black;
  Color saleColor = Color(0xFFFF3D34);

  var f = NumberFormat("###,##0.00", "de_DE");

  addProductList(productsList) {
    productList.add(productsList);
//    notifyListeners();
  }

  updateProductList() {
    productList = [];
    notifyListeners();
  }

  updatePage() {
    page++;
    notifyListeners();
  }

  refreshPage() {
    page = 1;
    notifyListeners();
  }

  updatePageCount(int value) {
    pageCount = value;
//    notifyListeners();
  }

  updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  updateLoadMore(bool value) {
    loadMore = value;
//    notifyListeners();
  }

  updateFetchValues(bool dataFetchedValue, bool loadMoreValue) {
    dataFetched = dataFetchedValue;
    loadMore = loadMoreValue;
    notifyListeners();
  }

  add2cart({
    String id,
    String image,
    String name,
    num price,
    num qty,
    String sku,
    String uuid,
  }) {

    print("shoppingCart: $shoppingCart");

    int index = shoppingCart.items.indexWhere((test) => test.id == id);
    if (index < 0) {
      shoppingCart.items.add(CartItem(
          id: id,
          sku: sku,
          price: price,
          name: name,
          quantity: qty,
          uuid: uuid,
          image: image));
          shoppingCart.total += price;
    } else {
      if(shoppingCart.items[index].quantity<99){
        shoppingCart.items[index].quantity += qty;
        shoppingCart.total += price;
      }
    }
    
    haveProducts = shoppingCart.items.isNotEmpty;
    notifyListeners();
  }

  deleteProduct(int index) {
    num less =
        shoppingCart.items[index].price * shoppingCart.items[index].quantity;
    shoppingCart.total -= less;
    shoppingCart.items.removeAt(index);
    haveProducts = shoppingCart.items.isNotEmpty;
    notifyListeners();
  }

  updateQty({int index, num quantity}) {
    var add = quantity - shoppingCart.items[index].quantity;
    shoppingCart.items[index].quantity = quantity;
    shoppingCart.total =
        shoppingCart.total + (shoppingCart.items[index].price * add);
    notifyListeners();
  }

  addProductListStock(List<InventoryModel> inventoryModelList) {
    for (var inv in inventoryModelList) {
      productStock.addAll({"${inv.sku}": "${inv.stock.toString()}"});
    }
  }

}
