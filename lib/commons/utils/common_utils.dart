import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'utils.dart';

class Styles {
  static TextStyle noAvatarPhone = TextStyle(
    color: Colors.black.withOpacity(0.7),
    fontSize: Measurements.height * 0.035,
    fontWeight: FontWeight.w100,
  );
  static TextStyle noAvatarTablet = TextStyle(
    color: Colors.black.withOpacity(0.7),
    fontSize: Measurements.height * 0.025,
    fontWeight: FontWeight.w100,
  );
}

class Measurements {
  static double height;
  static double width;
  static dynamic iconsRoutes;

  static void loadImages(context) {
    DefaultAssetBundle.of(context)
        .loadString("assets/images/images_routes.json", cache: false)
        .then((value) {
      iconsRoutes = JsonDecoder().convert(value);
    }).catchError((onError) {
      print(onError);
    });
  }

  static String iconRoute(String name) => iconsRoutes[name] ?? "";

  static String currency(String currency) {
    switch (currency.toUpperCase()) {
      case "EUR":
        return "€";
      case "USD":
        return 'US\$';
      case "NOK":
        return "NOK";
      case "SEK":
        return "SEK";
      case "GBP":
        return "£";
      case "DKK":
        return "DKK";
      case "CHF":
        return "CHF";
        break;
      default:
        return "€";
    }
  }

  static String channelIcon(String channel) {
    return iconRoute(channel);
  }

  static String channel(String channel) {
    return Language.getTransactionStrings("channels." + channel);
  }

  static String paymentType(String type) {
    return iconRoute(type);
  }

  static String actions(
      String action, dynamic _event, TransactionDetails _transaction) {
    const String statusChange = "{{ payment_status }}";
    const String amount = "{{ amount }}";
    const String reference = "{{ reference }}";
    const String upload = "{{ upload_type }}";

    var f = new NumberFormat("###,###,###.00", "en_US");
    switch (action) {
      case "refund":
        return Language.getTransactionStrings(
                "details.history.action.refund.amount")
            .replaceFirst("$amount",
                "${Measurements.currency(_transaction.transaction.currency)}${f.format(_event.amount ?? 0)}");
        break;
      case "statuschanged":
        return Language.getTransactionStrings(
                "details.history.action.statuschanged")
            .replaceFirst(
                "$statusChange",
                Language.getTransactionStatusStrings(
                    "transactions_specific_statuses." +
                        _transaction.status.general));
        break;
      case "change_amount":
        return Language.getTransactionStrings(
                "details.history.action.change_amount")
            .replaceFirst("$amount", _event.amount ?? 0);
        break;
      case "upload":
        return Language.getTransactionStrings("details.history.action.upload")
            .replaceFirst("$upload", _event.upload ?? "");
        break;
      case "capture_with_amount":
        return Language.getTransactionStrings(
                "details.history.action.capture_with_amount")
            .replaceFirst("$amount", _event.amount ?? 0);
        break;
      case "capture_with_amount":
        return Language.getTransactionStrings(
                "details.history.action.change_amount")
            .replaceFirst("$amount", _event.amount ?? 0);
        break;
      case "change_reference":
        return Language.getTransactionStrings(
                "details.history.action.change_reference")
            .replaceFirst("$reference", _event.reference ?? "");
        break;
      default:
        return Language.getTransactionStrings("details.history.action.$action");
    }
  }

  static String historyStatus(String status) {
    return Language.getTransactionStrings("filters.status." + status);
  }

  static String paymentTypeName(String type) {
    if (type.isNotEmpty)
      return Language.getTransactionStrings("filters.type." + type);
    else
      return "";
  }

  static Widget statusWidget(String status) {
    switch (status) {
      case "STATUS_IN_PROCESS":
        return AutoSizeText(
          Language.getTransactionStrings(status),
          minFontSize: 10,
          maxLines: 2,
          style: TextStyle(color: Colors.orange),
        );
        break;
      case "STATUS_ACCEPTED":
        return AutoSizeText(
          Language.getTransactionStrings(status),
          minFontSize: 10,
          maxLines: 2,
          style: TextStyle(color: Colors.lightGreen),
        );
        break;
      case "STATUS_NEW":
        return AutoSizeText(
          Language.getTransactionStrings(status),
          minFontSize: 10,
          maxLines: 2,
          style: TextStyle(color: Colors.orange),
        );
        break;
      case "STATUS_REFUNDED":
        return AutoSizeText(
          Language.getTransactionStrings(status),
          minFontSize: 10,
          maxLines: 2,
          style: TextStyle(color: Colors.orange),
        );
        break;
      case "STATUS_FAILED":
        return AutoSizeText(
          Language.getTransactionStrings(status),
          minFontSize: 10,
          maxLines: 2,
          style: TextStyle(color: Colors.red),
        );
        break;
      case "STATUS_PAID":
        return AutoSizeText(
          Language.getTransactionStrings(status),
          minFontSize: 10,
          maxLines: 2,
          style: TextStyle(color: Colors.lightGreen),
        );
        break;
      case "STATUS_DECLINED":
        return AutoSizeText(
          Language.getTransactionStrings(status),
          minFontSize: 10,
          maxLines: 2,
          style: TextStyle(color: Colors.red),
        );
        break;
      case "STATUS_CANCELLED":
        return AutoSizeText(
          Language.getTransactionStrings(status),
          minFontSize: 10,
          maxLines: 2,
          style: TextStyle(color: Colors.red),
        );
        break;
      default:
        return AutoSizeText(
          Language.getTransactionStrings(status),
          minFontSize: 10,
          maxLines: 2,
          style: TextStyle(color: Colors.white),
        );
        break;
    }
  }

  static String salutation(String salutation) {
    return Language.getTransactionStrings("salutation.$salutation");
  }

  static paymentTypeIcon(String type, bool isTablet) {
    double size = Measurements.width * (isTablet ? 0.03 : 0.055);
    print(size);
    Color _color = Colors.white.withOpacity(0.7);
    return SvgPicture.asset(
      Measurements.paymentType(type),
      height: AppStyle.iconDashboardCardSize(isTablet),
      color: _color,
    );
  }

  static Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  static String initials(String name) {
    String displayName;
    if (name.contains(" ")) {
      displayName = name.substring(0, 1);
      displayName = displayName + name.split(" ")[1].substring(0, 1);
    } else {
      displayName = name.substring(0, 1) + name.substring(name.length - 1);
    }
    return displayName = displayName.toUpperCase();
  }
}

class GlobalUtils {
  static Token activeToken;
  static BuildContext currentContext;
  static bool isLoaded = false;
  static var isDashboardLoaded = false;
  static String fingerprint = "";

  //URLS
  //static String  pass= "P@ssword123";//test 1
  // static String  pass= "Test1234!";//staging 1
  static String  pass= "";//live 0
  //static String pass = "Payever2019!"; //live 1
  //static String  pass = "Payever123!";//test 2
  //static String  pass= "12345678";//staging 2

  //static String  mail= "payever.automation@gmail.com";//test 1
  // static String  mail= "rob@top.com";//staging 1
  static String  mail= "";//live 0
  //static String mail = "abiantgmbh@payever.de"; //live 1
  //static String  mail = "testcases@payever.de";//test 2
  //static String  mail= "service@payever.de";//staging 2

  //static const String COMMERCE_OS_URL = "https://commerceos.test.devpayever.com";//test
  static const String COMMERCE_OS_URL = "https://commerceos.staging.devpayever.com";//staging
  // static const String COMMERCE_OS_URL = "https://commerceos.payever.org"; //live

  static const String POS_URL = "https://getpayever.com/pos";

  static const String FORGOT_PASS = COMMERCE_OS_URL + "/password/forgot";

  //static const String SIGN_UP = COMMERCE_OS_URL+"/entry/registration/business";
  static const String SIGN_UP = "https://getpayever.com/business/trial";

  //Preferences Keys
  static const String EMAIL = "email";
  static const String PASSWORD = "password";
  static const String DEVICE_ID = "id";
  static const String FINGERPRINT = "fingerPrint";
  static const String WALLPAPER = "wallpaper";
  static const String BUSINESS = "businessid";
  static const String TOKEN = "TOKEN";
  static const String REFRESH_TOKEN = "REFRESHTOKEN";
  static const String REFRESH_DATE = "REFRESHDATE";
  static const String LAST_OPEN = "lastOpen";
  static const String EVENTS_KEY = "fetch_events";
  static const String LANGUAGE = "language";

  // static Channels

  static const String CHANNEL_POS = "pos";
  static const String CHANNEL_SHOP = "shop";

  // token__
  static const String DB_TOKEN = "Token";
  static const String DB_TOKEN_ACC = "accessToken";
  static const String DB_TOKEN_RFS = "refreshToken";

  // tables__
  static const String DB_USER = "User";
  static const String DB_BUSINESS = "Business";

  // user__
  static const String DB_USER_ID = "_id";
  static const String DB_USER_FIRST_NAME = "firstName";
  static const String DB_USER_LAST_NAME = "lastName";
  static const String DB_USER_EMAIL = "email";
  static const String DB_USER_LANGUAGE = "language";
  static const String DB_USER_CREATED_AT = "createdAt";
  static const String DB_USER_UPDATED_AT = "updatedAt";
  static const String DB_USER_BIRTHDAY = "birthday";
  static const String DB_USER_SALUTATION = "salut ation";
  static const String DB_USER_PHONE = "phone";
  static const String DB_USER_LOGO = "logo";

  // business__
  static const String DB_BUSINESS_ID = "_id";
  static const String DB_BUSINESS_CREATE_AT = "createAt";
  static const String DB_BUSINESS_UPDATED_AT = "updatedAt";
  static const String DB_BUSINESS_CURRENCY = "currency";
  static const String DB_BUSINESS_EMAIL = "email";
  static const String DB_BUSINESS_HIDDEN = "hidden";
  static const String DB_BUSINESS_LOGO = "logo";
  static const String DB_BUSINESS_NAME = "name";
  static const String DB_BUSINESS_ACTIVE = "active";

  static const String DB_BUSINESS_COMPANY_ADDRESS = "companyAddress";

  static const String DB_BUSINESS_CA_CITY = "city";
  static const String DB_BUSINESS_CA_COUNTRY = "country";
  static const String DB_BUSINESS_CA_CREATED_AT = "createdAt";
  static const String DB_BUSINESS_CA_UPDATED_AT = "updatedAt";
  static const String DB_BUSINESS_CA_STREET = "street";
  static const String DB_BUSINESS_CA_ZIP_CODE = "zipCode";
  static const String DB_BUSINESS_CA_ID = "_id";

  static const String DB_BUSINESS_CONTACT_DETAILS = "contactDetails";

  static const String DB_BUSINESS_CNDT_CREATED_AT = "createdAT";
  static const String DB_BUSINESS_CNDT_FIRST_NAME = "firstName";
  static const String DB_BUSINESS_CNDT_LAST_NAME = "lastName";
  static const String DB_BUSINESS_CNDT_UPDATED_AT = "updatedAt";
  static const String DB_BUSINESS_CNDT_ID = "_id";

  static const String DB_BUSINESS_COMPANY_DETAILS = "companyDetails";

  static const String DB_BUSINESS_CMDT_CREATED_AT = "createdAt";
  static const String DB_BUSINESS_CMDT_UPDATED_AT = "updatedAt";
  static const String DB_BUSINESS_CMDT_FOUNDATION_YEAR = "foundationYear";
  static const String DB_BUSINESS_CMDT_INDUSTRY = "industry";
  static const String DB_BUSINESS_CMDT_PRODUCT = "product";
  static const String DB_BUSINESS_CMDT_ID = "_id";

  static const String DB_BUSINESS_CMDT_EMPLOYEES_RANGE = "employeesRange";

  static const String DB_BUSINESS_CMDT_EMP_RANGE_MIN = "min";
  static const String DB_BUSINESS_CMDT_EMP_RANGE_MAX = "max";
  static const String DB_BUSINESS_CMDT_EMP_RANGE_ID = "id";

  static const String DB_BUSINESS_CMDT_SALES_RANGE = "salesRange";

  static const String DB_BUSINESS_CMDT_SALES_RANGE_MIN = "min";
  static const String DB_BUSINESS_CMDT_SALES_RANGE_MAX = "max";
  static const String DB_BUSINESS_CMDT_SALES_RANGE_ID = "_id";

  // transactions__
  static const String DB_TRANSACTIONS_COLLECTION = "collection";
  static const String DB_TRANSACTIONS_FILTER = "filters";
  static const String DB_TRANSACTIONS_PAGINATION = "pagination_data";
  static const String DB_TRANSACTIONS_USAGES = "usage";

  static const String DB_TRANSACTIONS_C_ACTION_R = "action_running";
  static const String DB_TRANSACTIONS_C_AMOUNT = "amount";
  static const String DB_TRANSACTIONS_C_BILLING = "billing_address";
  static const String DB_TRANSACTIONS_C_BUS_OPT = "business_option_id";
  static const String DB_TRANSACTIONS_C_BUS_UUID = "business_uuid";
  static const String DB_TRANSACTIONS_C_CHANNEL = "channel";
  static const String DB_TRANSACTIONS_C_CH_SET = "channel_set_uuid";
  static const String DB_TRANSACTIONS_C_CREATED_AT = "created_at";
  static const String DB_TRANSACTIONS_C_CURRENCY = "currency";
  static const String DB_TRANSACTIONS_C_CUSTOMER_E = "customer_email";
  static const String DB_TRANSACTIONS_C_CUSTOMER_N = "customer_name";
  static const String DB_TRANSACTIONS_C_HISTORY = "history";
  static const String DB_TRANSACTIONS_C_ITEMS = "items";
  static const String DB_TRANSACTIONS_C_MERCHANT_E = "merchant_email";
  static const String DB_TRANSACTIONS_C_MERCHANT_N = "merchant_name";
  static const String DB_TRANSACTIONS_C_ORIGINAL_ID = "original_id";
  static const String DB_TRANSACTIONS_C_PAYMENT_DET = "payment_details";
  static const String DB_TRANSACTIONS_C_PAYMENT_FLO = "payment_flow_id";
  static const String DB_TRANSACTIONS_C_PLACE = "place";
  static const String DB_TRANSACTIONS_C_REFERENCE = "reference";
  static const String DB_TRANSACTIONS_C_SANTANDER = "santander_applications";
  static const String DB_TRANSACTIONS_C_STATUS = "status";
  static const String DB_TRANSACTIONS_C_TOTAL = "total";
  static const String DB_TRANSACTIONS_C_TYPE = "type";
  static const String DB_TRANSACTIONS_C_UPDATED_AT = "updated_at";
  static const String DB_TRANSACTIONS_C_UUID = "uuid";
  static const String DB_TRANSACTIONS_C_ID = "_id";

  static const String DB_TRANSACTIONS_P_PAGE = "page";
  static const String DB_TRANSACTIONS_P_CURRENT = "current";
  static const String DB_TRANSACTIONS_P_TOTAL = "total";
  static const String DB_TRANSACTIONS_P_TOTAL_COUNT = "totalCount";
  static const String DB_TRANSACTIONS_P_AMOUNT = "amount";

  static const String DB_TRANSACTIONS_U_SPECIFIC = "specific_statuses";
  static const String DB_TRANSACTIONS_U_STATUS = "statuses";

  static const String DB_TRANSACTIONS_C_B_CITY = "city";
  static const String DB_TRANSACTIONS_C_B_COUNTRY = "country";
  static const String DB_TRANSACTIONS_C_B_COUNTRY_N = "country_name";
  static const String DB_TRANSACTIONS_C_B_EMAIL = "email";
  static const String DB_TRANSACTIONS_C_B_FIRST_NAME = "first_name";
  static const String DB_TRANSACTIONS_C_B_LAST_NAME = "last_name";
  static const String DB_TRANSACTIONS_C_B_SALUTATION = "salutation";
  static const String DB_TRANSACTIONS_C_B_STREET = "street";
  static const String DB_TRANSACTIONS_C_B_ZIP_CODE = "zip_code";
  static const String DB_TRANSACTIONS_C_B_ID = "_id";

  static const String DB_TRANSACTIONS_C_H_ACTION = "action";
  static const String DB_TRANSACTIONS_C_H_CREATED_AT = "created_at";
  static const String DB_TRANSACTIONS_C_H_PAYMENT_ST = "payment_status";
  static const String DB_TRANSACTIONS_C_H_REFUNDS = "refund_items";
  static const String DB_TRANSACTIONS_C_H_UPLOAD = "upload_items";
  static const String DB_TRANSACTIONS_C_H_ID = "_id";

  static const String DB_TRANS_DETAIL_ACTIONS = "actions";
  static const String DB_TRANS_DETAIL_ACT_ACTION = "action";
  static const String DB_TRANS_DETAIL_ACT_ENABLED = "enabled";
  static const String DB_TRANS_DETAIL_BILLING_ADDRESS = "billing_address";
  static const String DB_TRANS_DETAIL_BA_CITY = "city";
  static const String DB_TRANS_DETAIL_BA_COUNTRY = "country";
  static const String DB_TRANS_DETAIL_BA_COUNTRY_NAME = "country_name";
  static const String DB_TRANS_DETAIL_BA_EMAIL = "email";
  static const String DB_TRANS_DETAIL_BA_FIRST_NAME = "first_name";
  static const String DB_TRANS_DETAIL_BA_LAST_NAME = "last_name";
  static const String DB_TRANS_DETAIL_BA_ID = "id";
  static const String DB_TRANS_DETAIL_BA_SALUTATION = "salutation";
  static const String DB_TRANS_DETAIL_BA_STREET = "street";
  static const String DB_TRANS_DETAIL_BA_ZIP_CODE = "zip_code";
  static const String DB_TRANS_DETAIL_BA__ID = "_id";
  static const String DB_TRANS_DETAIL_BUSINESS = "business";
  static const String DB_TRANS_DETAIL_BUSINESS_UUID = "uuid";
  static const String DB_TRANS_DETAIL_CART = "cart";
  static const String DB_TRANS_DETAIL_ITEMS = "items";
  static const String DB_TRANS_DETAIL_IT_CREATED_AT = "created_at";
  static const String DB_TRANS_DETAIL_IT_ID = "id";
  static const String DB_TRANS_DETAIL_IT_IDENTIFIER = "identifier";
  static const String DB_TRANS_DETAIL_IT_NAME = "name";
  static const String DB_TRANS_DETAIL_IT_PRICE = "price";
  static const String DB_TRANS_DETAIL_IT_PRICE_NET = "price_net";
  static const String DB_TRANS_DETAIL_IT_QUANTITY = "quantity";
  static const String DB_TRANS_DETAIL_IT_THUMBNAIL = "thumbnail";
  static const String DB_TRANS_DETAIL_IT_UPDATED_AT = "upadated_at";
  static const String DB_TRANS_DETAIL_IT_VAT_RATE = "vat_rate";
  static const String DB_TRANS_DETAIL_IT__ID = "_id";
  static const String DB_TRANS_DETAIL_ITEMS_AVAIL_REF =
      "available_refund_items";
  static const String DB_TRANS_DETAIL_IT_REF_COUNT = "count";
  static const String DB_TRANS_DETAIL_IT_REF_UUID = "item_uuid";
  static const String DB_TRANS_DETAIL_CHANNEL = "channel";
  static const String DB_TRANS_DETAIL_CHANNEL_NAME = "name";
  static const String DB_TRANS_DETAIL_CHANNEL_SET = "channel_set";
  static const String DB_TRANS_DETAIL_CHANNEL_SET_UUID = "uuid";
  static const String DB_TRANS_DETAIL_CUSTOMER = "customer";
  static const String DB_TRANS_DETAIL_CUSTOMER_EMAIL = "email";
  static const String DB_TRANS_DETAIL_CUSTOMER_NAME = "name";
  static const String DB_TRANS_DETAIL_HISTORY = "history";
  static const String DB_TRANS_DETAIL_HIST_ACTION = "action";
  static const String DB_TRANS_DETAIL_HIST_CREATED_AT = "created_at";
  static const String DB_TRANS_DETAIL_HIST_ID = "id";
  static const String DB_TRANS_DETAIL_HIST_REFUND_IT = "refund_items";
  static const String DB_TRANS_DETAIL_HIST_UPLOAD_IT = "upload_items";
  static const String DB_TRANS_DETAIL_HIST__ID = "_id";
  static const String DB_TRANS_DETAIL_HIST_AMOUNT = "amount";
  static const String DB_TRANS_DETAIL_HIST_PAY_STATUS = "payment_status";
  static const String DB_TRANS_DETAIL_MERCHANT = "merchant";
  static const String DB_TRANS_DETAIL_MERC_EMAIL = "email";
  static const String DB_TRANS_DETAIL_MERC_NAME = "name";
  static const String DB_TRANS_DETAIL_PAYMENT_FLOW = "payment_flow";
  static const String DB_TRANS_DETAIL_PAYMENT_FLOW_ID = "id";
  static const String DB_TRANS_DETAIL_PAYMENT_OPTION = "payment_option";
  static const String DB_TRANS_DETAIL_PAY_OPT_DOWN_PAY = "down_payment";
  static const String DB_TRANS_DETAIL_PAY_OPT_FEE = "payment_fee";
  static const String DB_TRANS_DETAIL_PAY_OPT_ID = "id";
  static const String DB_TRANS_DETAIL_PAY_OPT_TYPE = "type";
  static const String DB_TRANS_DETAIL_SHIPPING = "shipping";
  static const String DB_TRANS_DETAIL_SHIPPING_METHOD = "method_name";
  static const String DB_TRANS_DETAIL_SHIPPING_FEE = "delivery_fee";
  static const String DB_TRANS_DETAIL_STATUS = "status";
  static const String DB_TRANS_DETAIL_STATUS_GENERAL = "general";
  static const String DB_TRANS_DETAIL_STATUS_PLACE = "place";
  static const String DB_TRANS_DETAIL_STATUS_SPECIFIC = "specific";
  static const String DB_TRANS_DETAIL_STORE = "store";
  static const String DB_TRANS_DETAIL_TRANSACTION = "transaction";
  static const String DB_TRANS_DETAIL_TRANS_AMOUNT = "amount";
  static const String DB_TRANS_DETAIL_TRANS_AMOUNT_REF = "amount_refunded";
  static const String DB_TRANS_DETAIL_TRANS_AMOUNT_REST = "amount_rest";
  static const String DB_TRANS_DETAIL_TRANS_CREATED_AT = "created_at";
  static const String DB_TRANS_DETAIL_TRANS_CURRENCY = "currency";
  static const String DB_TRANS_DETAIL_TRANS_ID = "id";
  static const String DB_TRANS_DETAIL_TRANS_ORIGINAL_ID = "original_id";
  static const String DB_TRANS_DETAIL_TRANS_REFERENCE = "reference";
  static const String DB_TRANS_DETAIL_TRANS_TOTAL = "total";
  static const String DB_TRANS_DETAIL_TRANS_UPDATED_AT = "updated_at";
  static const String DB_TRANS_DETAIL_TRANS_UUID = "uuid";
  static const String DB_TRANS_DETAIL_USER = "user";
  static const String DB_TRANS_DETAIL_ORDER = "order";
  static const String DB_TRANS_DETAIL_DETAILS = "details";
  static const String DB_TRANS_DETAIL_OR_FINANCE_ID = "finance_id";
  static const String DB_TRANS_DETAIL_OR_APPLICATION_NO = "application_no";
  static const String DB_TRANS_DETAIL_OR_APPLICATION_NU = "application_number";
  static const String DB_TRANS_DETAIL_OR_USAGE_TEXT = "usage_text";
  static const String DB_TRANS_DETAIL_OR_PAN_ID = "pan_id";
  static const String DB_TRANS_DETAIL_OR_REFERENCE = "reference";
  static const String DB_TRANS_DETAIL_OR_IBAN = "iban";
  static const String DB_TRANS_DETAIL_OR__IBAN = "bank_i_b_a_n";

  //POS
  static const String DB_POS_TERMINAL_ACTIVE = "active";
  static const String DB_POS_TERMINAL_BUSINESS = "business";
  static const String DB_POS_TERMINAL_CHANNEL_SET = "channelSet";
  static const String DB_POS_TERMINAL_CREATED_AT = "createdAt";
  static const String DB_POS_TERMINAL_DEFAULT_LOCALE = "defaultLocale";
  static const String DB_POS_TERMINAL_INTEGRATION_SUB =
      "integrationSubscriptions";
  static const String DB_POS_TERMINAL_LOCALES = "locales";
  static const String DB_POS_TERMINAL_LOGO = "logo";
  static const String DB_POS_TERMINAL_NAME = "name";
  static const String DB_POS_TERMINAL_THEME = "theme";
  static const String DB_POS_TERMINAL_UPDATED_AT = "updatedAt";
  static const String DB_POS_TERMINAL_V = "__v";
  static const String DB_POS_TERMINAL_ID = "_id";

  static const String DB_POS_CHANNEL_SET_CHECKOUT = "checkout";
  static const String DB_POS_CHANNEL_SET_ID = "id";
  static const String DB_POS_CHANNEL_SET_NAME = "name";
  static const String DB_POS_CHANNEL_SET_TYPE = "type";

  static const String DB_POS_TERM_PRODUCT_CHANNEL_SET = "channelSet";
  static const String DB_POS_TERM_PRODUCT_ID = "id";
  static const String DB_POS_TERM_PRODUCT_LAST_SELL = "lastSell";
  static const String DB_POS_TERM_PRODUCT_NAME = "name";
  static const String DB_POS_TERM_PRODUCT_QUANTITY = "quantity";
  static const String DB_POS_TERM_PRODUCT_THUMBNAIL = "thumbnail";
  static const String DB_POS_TERM_PRODUCT_UUID = "uuid";
  static const String DB_POS_TERM_PRODUCT_V = "__v";
  static const String DB_POS_TERM_PRODUCT__ID = "_id";

  static const String DB_POS_CART = "cart";
  static const String DB_POS_CART_CART_ID = "id";
  static const String DB_POS_CART_CART_IDENTIFIER = "identifier";
  static const String DB_POS_CART_CART_IMAGE = "image";
  static const String DB_POS_CART_CART_NAME = "name";
  static const String DB_POS_CART_CART_PRICE = "price";
  static const String DB_POS_CART_CART_QTY = "quantity";
  static const String DB_POS_CART_CART_SKU = "sku";
  static const String DB_POS_CART_CART_UUID = "uuid";
  static const String DB_POS_CART_CART_VAT = "vat";
  static const String DB_POS_CART_ID = "id";
  static const String DB_POS_CART_TOTAL = "total";

  static const String DB_PROD_BUSINESS = "business";
  static const String DB_PROD_ID = "id";
  static const String DB_PROD_LAST_SELL = "lastSell";
  static const String DB_PROD_NAME = "name";
  static const String DB_PROD_QUANTITY = "quantity";
  static const String DB_PROD_THUMBNAIL = "thumbnail";
  static const String DB_PROD_UUID = "uuid";
  static const String DB_PROD__V = "__v";
  static const String DB_PROD__ID = "__id";

  static const String DB_PROD_MODEL_UUID = "uuid";
  static const String DB_PROD_MODEL_BARCODE = "barcode";
  static const String DB_PROD_MODEL_CATEGORIES = "categories";
  static const String DB_PROD_MODEL_CURRENCY = "currency";
  static const String DB_PROD_MODEL_DESCRIPTION = "description";
  static const String DB_PROD_MODEL_ENABLE = "enable";
  static const String DB_PROD_MODEL_HIDDEN = "hidden";
  static const String DB_PROD_MODEL_IMAGES = "images";
  static const String DB_PROD_MODEL_PRICE = "price";
  static const String DB_PROD_MODEL_SALE_PRICE = "salePrice";
  static const String DB_PROD_MODEL_SKU = "sku";
  static const String DB_PROD_MODEL_TITLE = "title";
  static const String DB_PROD_MODEL_TYPE = "type";
  static const String DB_PROD_MODEL_VARIANTS = "variants";
  static const String DB_PROD_MODEL_SHIPPING = "shipping";
  static const String DB_PROD_MODEL_CHANNEL_SET = "channelSets";

  static const String DB_PROD_MODEL_SHIP_FREE = "free";
  static const String DB_PROD_MODEL_SHIP_GENERAL = "general";
  static const String DB_PROD_MODEL_SHIP_HEIGHT = "height";
  static const String DB_PROD_MODEL_SHIP_LENGTH = "length";
  static const String DB_PROD_MODEL_SHIP_WIDTH = "width";
  static const String DB_PROD_MODEL_SHIP_WEIGHT = "weight";

  static const String DB_PROD_MODEL_VAR_BARCODE = "barcode";
  static const String DB_PROD_MODEL_VAR_DESCRIPTION = "description";
  static const String DB_PROD_MODEL_VAR_HIDDEN = "hidden";
  static const String DB_PROD_MODEL_VAR_ID = "id";
  static const String DB_PROD_MODEL_VAR_IMAGES = "images";
  static const String DB_PROD_MODEL_VAR_PRICE = "price";
  static const String DB_PROD_MODEL_VAR_SALE_PRICE = "salePrice";
  static const String DB_PROD_MODEL_VAR_SKU = "sku";
  static const String DB_PROD_MODEL_VAR_TITLE = "title";

  static const String DB_PROD_MODEL_CATEGORIES_TITLE = "title";
  static const String DB_PROD_MODEL_CATEGORIES_SLUG = "slug";
  static const String DB_PROD_MODEL_CATEGORIES__ID = "_id";
  static const String DB_PROD_MODEL_CATEGORIES_BUSINESS_UUID = "businessUuid";

  static const String DB_INV_MODEL_BARCODE = "barcode";
  static const String DB_INV_MODEL_BUSINESS = "business";
  static const String DB_INV_MODEL_IS_NEGATIVE_ALLOW = "isNegativeStockAllowed";
  static const String DB_INV_MODEL_CREATED_AT = "createdAt";
  static const String DB_INV_MODEL_IS_TRACKABLE = "isTrackable";
  static const String DB_INV_MODEL_SKU = "sku";
  static const String DB_INV_MODEL_UPDATE_AT = "updatedAt";
  static const String DB_INV_MODEL_STOCK = "stock";
  static const String DB_INV_MODEL_RESERVED = "reserved";
  static const String DB_INV_MODEL_V = "__v";
  static const String DB_INV_MODEL_ID = "_id";

  static const String DB_PROD_INFO = "info";
  static const String DB_PROD_INFO_PAGINATION = "pagination";
  static const String DB_PROD_INFO_ITEM_COUNT = "item_count";
  static const String DB_PROD_INFO_ITEM_PAGE = "page";
  static const String DB_PROD_INFO_ITEM_PAGE_COUNT = "page_count";
  static const String DB_PROD_INFO_ITEM_PER_PAGE = "per_page";

  static const String DB_SHOP_ACTIVE = "active";
  static const String DB_SHOP_BUSINESS = "business";
  static const String DB_SHOP_CHANNEL_SET = "channelSet";
  static const String DB_SHOP_CREATED_AT = "createdAt";
  static const String DB_SHOP_DEFAULT_LOCALE = "defaultLocale";
  static const String DB_SHOP_LIVE = "live";
  static const String DB_SHOP_LOCALES = "locales";
  static const String DB_SHOP_LOGO = "logo";
  static const String DB_SHOP_NAME = "name";
  static const String DB_SHOP_THEME = "theme";
  static const String DB_SHOP_UPDATED_AT = "updatedAt";
  static const String DB_SHOP__v = "__v";
  static const String DB_SHOP_ID = "_id";

  static const String DB_CHECKOUT_SECTIONS = "sections";
  static const String DB_CHECKOUT_SECTIONS_CODE = "code";
  static const String DB_CHECKOUT_SECTIONS_ENABLED = "enabled";
  static const String DB_CHECKOUT_SECTIONS_FIXED = "fixed";
  static const String DB_CHECKOUT_SECTIONS_ORDER = "order";
  static const String DB_CHECKOUT_SECTIONS_EXCLUDED = "excluded_channels";
  static const String DB_CHECKOUT_SECTIONS_SUB_SEC = "subsections";

  static const String DB_TUTORIAL_INIT = "\$init";
  static const String DB_TUTORIAL_ICON = "icon";
  static const String DB_TUTORIAL_ORDER = "order";
  static const String DB_TUTORIAL_TITLE = "title";
  static const String DB_TUTORIAL_TYPE = "type";
  static const String DB_TUTORIAL_URL = "url";
  static const String DB_TUTORIAL_WATCHED = "watched";
  static const String DB_TUTORIAL_ID = "_id";

  static const String DB_VERSION_APPLE_STORE = "appleStoreUrl";
  static const String DB_VERSION_CURRENT_VERSION = "currentVersion";
  static const String DB_VERSION_MIN_VERSION = "minVersion";
  static const String DB_VERSION_PLAY_STORE = "playStoreUrl";
  	
  static const String DB_SETTINGS_WALLPAPER_INDUSTRIES    ="industries";
  static const String DB_SETTINGS_WALLPAPER_CODE          ="code";
  static const String DB_SETTINGS_WALLPAPER_WALLPAPERS    ="wallpapers";

  // env__
  static const String ENV_CUSTOM = "custom";
  static const String ENV_BACKEND = "backend";
  static const String ENV_AUTH = "auth";
  static const String ENV_USER = "users";
  static const String ENV_BUSINESS = "business";
  static const String ENV_STORAGE = "storage";
  static const String ENV_WALLPAPER = "wallpapers";
  static const String ENV_WIDGET = "widgets";
  static const String ENV_BUILDER = "builder";
  static const String ENV_BUILDER_CLIENT = "builderClient";
  static const String ENV_COMMERCE_OS = "commerceos";
  static const String ENV_FRONTEND = "frontend";
  static const String ENV_TRANSACTIONS = "transactions";
  static const String ENV_POS = "pos";
  static const String ENV_CHECKOUT = "checkout";
  static const String ENV_CHECKOUT_PHP = "payments";
  static const String ENV_MEDIA = "media";
  static const String ENV_PRODUCTS = "products";
  static const String ENV_INVENTORY = "inventory";
  static const String ENV_SHOPS = "shops";
  static const String ENV_WRAPPER = "checkoutWrapper";
  static const String ENV_EMPLOYEES = "employees";
  static const String ENV_APP_REGISTRY = "appRegistry";

  // dashboard_
  static const String CURRENT_WALLPAPER = "currentWallpaper";

  // AppWidget_
  static const String APP_WID = "widgets";
  static const String APP_WID_ID = "_id";
  static const String APP_WID_DEFAULT = "default";
  static const String APP_WID_ICON = "icon";
  static const String APP_WID_INSTALLED = "installed";
  static const String APP_WID_ORDER = "order";
  static const String APP_WID_TITLE = "title";
  static const String APP_WID_TYPE = "type";
  static const String APP_WID_HELP = "helpUrl";

  static const String APP_WID_LAST_CURRENCY = "currency";
  static const String APP_WID_LAST_DATE = "date";
  static const String APP_WID_LAST_AMOUNT = "amount";

  static void clearCredentials() {
    SharedPreferences.getInstance().then((p) {
      p.setString(GlobalUtils.BUSINESS, "");
      p.setString(GlobalUtils.WALLPAPER, "");
      p.setString(GlobalUtils.EMAIL, "");
      p.setString(GlobalUtils.PASSWORD, "");
      p.setString(GlobalUtils.DEVICE_ID, "");
      p.setString(GlobalUtils.DB_TOKEN_ACC, "");
      p.setString(GlobalUtils.DB_TOKEN_RFS, "");
    });
  }

  static List<String> positionsListOptions() {
    List<String> positions = List<String>();
    positions.add("Cashier");
    positions.add("Sales");
    positions.add("Marketing");
    positions.add("Staff");
    positions.add("Admin");
    positions.add("Others");
    return positions;
  }
}
