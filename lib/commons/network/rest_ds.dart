import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';

import 'network_utils.dart';

//import '../models/models.dart';
import '../utils/utils.dart';

class RestDataSource {
  NetworkUtil _netUtil = NetworkUtil();

  static final envUrl = GlobalUtils.COMMERCE_OS_URL + "/env.json";
  static String authBaseUrl = Env.auth;
  static String baseUrl = Env.users;
  static String wallpaper = Env.wallpapers;
  static String widgets = Env.widgets;

  static String loginUrl = authBaseUrl + '/api/login';
  static String refreshUrl = authBaseUrl + '/api/refresh';

  static String userUrl = baseUrl + '/api/user';
  static String businessUrl = baseUrl + '/api/business';
  static String businessApps = Env.commerceOsBack + '/api/apps/business/';

  static String wallpaperUrl = wallpaper + '/api/business/';
  static String wallpaperUrlPer = wallpaper + '/api/personal/wallpapers';
  static String wallpaperEnd = '/wallpapers';
  static String wallpaperAll = wallpaper +'/api/products/wallpapers';


  static String widgetsUrl = widgets + "/api/business/";
  static String widgetsUrlPer = widgets + "/api/personal/widget";
  static String widgetsEnd = "/widget";
  static String widgetsChannelSet = "/channel-set/";

  static String storageUrl = Env.media + "/api/storage";
  static String appRegistryUrl = Env.appRegistry + "/api/";

  static String transactionsUrl = widgets + "/api/transactions-app/business/";
  static String transactionsUrlPer =
      widgets + "/api/transactions-app/personal/";
  static String months = "/last-monthly";
  static String days = "/last-daily";

  static String transactionWid = Env.transactions;
  static String transactionWidUrl = transactionWid + "/api/business/";
  static String transactionWidEnd = "/list";
  static String transactionWidDetails = "/detail/";

  static String productsUrl = widgets + "/api/products-app/business/";
  static String popularWeek = "/popular-week";
  static String popularMonth = "/popular-month";
  static String prodLastSold = "/last-sold";
  static String productRandomEnd = "/random";

  static String posBase = Env.pos + "/api/";
  static String posBusiness = posBase + "business/";
  static String posTerminalEnd = "/terminal";
  static String posTerminalMid = "/terminal/";

  static String shopsBase = Env.shops;
  static String shopUrl = shopsBase + "/api/business/";
  static String shopEnd = "/shop";

  static String checkoutBase = Env.checkout + "/api";
  static String checkoutFlow = checkoutBase + "/flow/channel-set/";
  static String checkoutBusiness = checkoutBase + "/business/";
  static String checkout = "/checkout/";
  static String endCheckout = "/checkout";
  static String endIntegration = "/integration";
  static String endChannelSet = "/channelSet";

  static String mediaBase = Env.media;
  static String mediaBusiness = mediaBase + "/api/image/business/";
  static String mediaImageEnd = "/images";
  static String mediaProductsEnd = "/products";

  static String productBase = Env.products;
  static String productsList = productBase + "/products";

  static String inventoryBase = Env.inventory;
  static String inventoryUrl = inventoryBase + "/api/business/";
  static String skuMid = "/inventory/sku/";
  static String inventoryEnd = "/inventory";
  static String addEnd = "/add";
  static String subtractEnd = "/subtract";

  static String checkoutV1 = Env.checkoutPhp + "/api/rest/v1/checkout/flow";
  static String checkoutV3 = Env.checkoutPhp + "/api/rest/v3/checkout/flow/";

  static String employees = Env.employees;
  static String newEmployee = authBaseUrl + "/api/employees/create/";
  static String inviteEmployee = authBaseUrl + "/api/employees/invite/";
  static String employeesList = authBaseUrl + "/api/employees/";
  static String employeeDetails = authBaseUrl + "/api/employees/";
  static String employeeGroups = authBaseUrl + "/api/employee-groups/";



  Future<dynamic> getEnv() {
    print("TAG - getEnv()");
    var headers = {HttpHeaders.contentTypeHeader: "application/json"};
    return _netUtil.get(envUrl, headers: headers).then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> getVersion() {
    print("TAG - getVersion()");
    var headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(appRegistryUrl + "mobile-settings", headers: headers)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> login(String username, String password, String finger) {
    print("TAG - login()");
    var body = jsonEncode({"email": username, "plainPassword": password});
    var headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .post(loginUrl, headers: headers, body: body)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> refreshToken(
      String token, String finger, BuildContext context) {
    print("TAG - refreshToken()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil.get(refreshUrl, headers: headers).then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> getDays(String id, String token, BuildContext context) {
    print("TAG - getDays()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(transactionsUrl + id + days, headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getMonths(String id, String token, BuildContext context) {
    print("TAG - getMonths()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(transactionsUrl + id + months, headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getTransactionList(
      String id, String token, String query, BuildContext context) {
    print("TAG - getTransactionList()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(transactionWidUrl + id + transactionWidEnd + query,
            headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getUser(String token, BuildContext context) {
    print("TAG - getUser()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil.get(userUrl, headers: headers).then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> getWidgets(String id, String token, BuildContext context) {
    print("TAG - getWidgets()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(widgetsUrl + id + widgetsEnd, headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getWidgetsPersonal(String token, BuildContext context) {
    print("TAG - getEnv()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil.get(widgetsUrlPer, headers: headers).then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getWallpaper(String id, String token, BuildContext context) {
    print("TAG - getWallpaper()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(wallpaperUrl + id + wallpaperEnd, headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getWallpaperPersonal(String token, BuildContext context) {
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(wallpaperUrlPer, headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getMonthsPersonal(String token, BuildContext context) {
    print("TAG - getEnv()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(transactionsUrlPer + "last-monthly", headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getDaysPersonal(String token, BuildContext context) {
    print("TAG - getEnv()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(transactionsUrlPer + "last-daily", headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getBusinesses(String token, BuildContext context) {
    print("TAG - getBusinesses()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil.get(businessUrl, headers: headers).then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> getTerminal(
      String idBusiness, String token, BuildContext context) {
    print("TAG - geTerminal()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(posBusiness + idBusiness + posTerminalEnd, headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getChannelSet(
      String idBusiness, String token, BuildContext context) {
    print("TAG - getChannelSet()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(checkoutBusiness + idBusiness + endChannelSet, headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getCheckoutIntegration(String idBusiness, String checkoutID,
      String token, BuildContext context) async {
    print("TAG - getCheckoutIntegration()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(
            checkoutBusiness +
                idBusiness +
                checkout +
                checkoutID +
                endIntegration,
            headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getLastWeek(String idBusiness, String channel, String token,
      BuildContext context) async {
    print("TAG - getLastWeek()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(transactionsUrl + idBusiness + widgetsChannelSet + channel + days,
            headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getPopularWeek(String idBusiness, String channel,
      String token, BuildContext context) async {
    print("TAG - getPopularWeek()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(
            productsUrl +
                idBusiness +
                widgetsChannelSet +
                channel +
                popularWeek,
            headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getProductsPopularWeek(
      String idBusiness, String token, BuildContext context) async {
    print("TAG - getProductsPopularWeek()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(productsUrl + idBusiness + popularWeek, headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getProductsPopularMonth(
      String idBusiness, String token, BuildContext context) async {
    print("TAG - getProductsPopularMonth()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(productsUrl + idBusiness + popularMonth, headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getProductLastSold(
      String idBusiness, String token, BuildContext context) async {
    print("TAG - getProductLastSold()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(productsUrl + idBusiness + prodLastSold, headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> deleteTransactionList(String id, String token, String query) {
    print("TAG - deleteTransactionList()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .delete(transactionWidUrl + id + transactionWidEnd + query,
            headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getTutorials(String token, String id) {
    print("TAG - getTutorials()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(widgetsUrl + "$id" + "/widget-tutorial", headers: headers)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> patchTutorials(String token, String id, String video) {
    print("TAG - patchTutorials()");
    var body = jsonEncode({});
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .patch(widgetsUrl + "$id" + "/widget-tutorial/$video/watched",
            headers: headers, body: body)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> getAppsBusiness(String idBusiness, String token) {
    print("TAG - getAppsBusiness()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(businessApps + idBusiness, headers: headers)
        .then((dynamic result) {
      return result;
    });
  }
}
