import 'package:intl/intl.dart';

import 'pos.dart';
import '../utils/utils.dart';

class Products {
  String _business;
  String _id;
  String _lastSale;
  String _name;
  num _quantity;
  String _thumbnail;
  String _uuid;
  num __v;
  String __id;

  Products.toMap(dynamic obj) {
    _business = obj[GlobalUtils.DB_PROD_BUSINESS];
    _id = obj[GlobalUtils.DB_PROD_ID];
    _lastSale = obj[GlobalUtils.DB_PROD_LAST_SELL];
    _name = obj[GlobalUtils.DB_PROD_NAME];
    _quantity = obj[GlobalUtils.DB_PROD_QUANTITY];
    _thumbnail = obj[GlobalUtils.DB_PROD_THUMBNAIL];
    _uuid = obj[GlobalUtils.DB_PROD_UUID];

    __id = obj[GlobalUtils.DB_PROD__ID];
    __v = obj[GlobalUtils.DB_PROD__V];
  }

  String get lastSaleDays {
    DateTime time = DateTime.parse(_lastSale);
    DateTime now = DateTime.now();
    if (now.difference(time).inDays < 1) {
      if (now.difference(time).inHours < 1) {
        return "${now.difference(time).inMinutes} minutes ago";
      } else {
        return "${now.difference(time).inHours} hrs ago";
      }
    } else {
      if (now.difference(time).inDays < 8) {
        return "${now.difference(time).inDays} days ago";
      } else {
        return "${DateFormat.d("en_US").add_M().add_y().format(time).replaceAll(" ", ".")}";
      }
    }
  }

  String get business => _business;

  String get id => _id;

  String get lastSale => _lastSale;

  String get name => _name;

  num get quantity => _quantity;

  String get thumbnail => _thumbnail;

  String get uuid => _uuid;

  num get _v => __v;

  String get customId => __id;
}

class ProductsModel {
  ProductsModel();

  List<String> images = List();
  String uuid;
  String title;
  String description;
  bool hidden;
  num price;
  num salePrice;
  String sku;
  String barcode;
  String currency;
  String type;
  bool enabled;
  List<Categories> categories = List();
  List<ChannelSet> channels = List();
  List<Variants> variants = List();
  Shipping shipping = Shipping();

  ProductsModel.toMap(dynamic obj) {
    uuid = obj[GlobalUtils.DB_PROD_MODEL_UUID] ?? "";
    title = obj[GlobalUtils.DB_PROD_MODEL_TITLE];
    description = obj[GlobalUtils.DB_PROD_MODEL_DESCRIPTION];
    hidden = obj[GlobalUtils.DB_PROD_MODEL_HIDDEN];
    price = obj[GlobalUtils.DB_PROD_MODEL_PRICE];
    salePrice = obj[GlobalUtils.DB_PROD_MODEL_SALE_PRICE];
    sku = obj[GlobalUtils.DB_PROD_MODEL_SKU];
    barcode = obj[GlobalUtils.DB_PROD_MODEL_BARCODE];
    currency = obj[GlobalUtils.DB_PROD_MODEL_CURRENCY];
    type = obj[GlobalUtils.DB_PROD_MODEL_TYPE];
    enabled = obj[GlobalUtils.DB_PROD_MODEL_ENABLE];
    if (obj[GlobalUtils.DB_PROD_MODEL_IMAGES] != null)
      obj[GlobalUtils.DB_PROD_MODEL_IMAGES].forEach((img) {
        images.add(img);
      });
    if (obj[GlobalUtils.DB_PROD_MODEL_CATEGORIES] != null)
      obj[GlobalUtils.DB_PROD_MODEL_CATEGORIES].forEach((categ) {
        if (categ != null) categories.add(Categories.toMap(categ));
      });
    if (obj[GlobalUtils.DB_PROD_MODEL_CHANNEL_SET] != null)
      obj[GlobalUtils.DB_PROD_MODEL_CHANNEL_SET].forEach((ch) {
        channels.add(ChannelSet.toMap(ch));
      });
    if (obj[GlobalUtils.DB_PROD_MODEL_VARIANTS] != null)
      obj[GlobalUtils.DB_PROD_MODEL_VARIANTS].forEach((variant) {
        variants.add(Variants.toMap(variant));
      });
    if (obj[GlobalUtils.DB_PROD_MODEL_SHIPPING] != null)
      shipping = Shipping.toMap(obj[GlobalUtils.DB_PROD_MODEL_SHIPPING]);
  }
}

class Categories {
  String title;
  String businessUuid;
  String slug;
  String id;

  Categories.toMap(dynamic obj) {
    title = obj[GlobalUtils.DB_PROD_MODEL_CATEGORIES_TITLE];
    slug = obj[GlobalUtils.DB_PROD_MODEL_CATEGORIES_SLUG];
    id = obj[GlobalUtils.DB_PROD_MODEL_CATEGORIES__ID];
    businessUuid = obj[GlobalUtils.DB_PROD_MODEL_CATEGORIES_BUSINESS_UUID];
  }
}

class Variants {
  Variants();

  String id;
  List<String> images = List();
  String title;
  String description;
  bool hidden;
  num price;
  num salePrice;
  String sku;
  String barcode;

  Variants.toMap(dynamic obj) {
    id = obj[GlobalUtils.DB_PROD_MODEL_VAR_ID];
    title = obj[GlobalUtils.DB_PROD_MODEL_VAR_TITLE];
    description = obj[GlobalUtils.DB_PROD_MODEL_VAR_DESCRIPTION];
    hidden = obj[GlobalUtils.DB_PROD_MODEL_VAR_HIDDEN];
    price = obj[GlobalUtils.DB_PROD_MODEL_VAR_PRICE];
    salePrice = obj[GlobalUtils.DB_PROD_MODEL_VAR_SALE_PRICE];
    sku = obj[GlobalUtils.DB_PROD_MODEL_VAR_SKU];
    barcode = obj[GlobalUtils.DB_PROD_MODEL_VAR_BARCODE];
    obj[GlobalUtils.DB_PROD_MODEL_VAR_IMAGES].forEach((img) {
      images.add(img);
    });
  }
}

class Shipping {
  Shipping();

  bool free;
  bool general;
  num weight;
  num width;
  num length;
  num height;

  Shipping.toMap(dynamic obj) {
    free = obj[GlobalUtils.DB_PROD_MODEL_SHIP_FREE];
    general = obj[GlobalUtils.DB_PROD_MODEL_SHIP_GENERAL];
    weight = obj[GlobalUtils.DB_PROD_MODEL_SHIP_WEIGHT];
    width = obj[GlobalUtils.DB_PROD_MODEL_SHIP_WIDTH];
    length = obj[GlobalUtils.DB_PROD_MODEL_SHIP_LENGTH];
    height = obj[GlobalUtils.DB_PROD_MODEL_SHIP_HEIGHT];
  }
}

//class Info {
//  num page;
//  num page_count;
//  num per_page;
//  num item_count;
//
//  Info.toMap(dynamic obj) {}
//}

class InventoryModel {
  String _barcode;
  String _business;
  String _createdAt;
  bool _isNegativeStockAllowed;
  bool _isTrackable;
  String _sku;
  num _stock;
  num _reserved;
  String _updatedAt;
  num __v;
  String __id;

  InventoryModel.toMap(dynamic obj) {

    print("obj: $obj");

    _barcode = obj[GlobalUtils.DB_INV_MODEL_BARCODE];
    _business = obj[GlobalUtils.DB_INV_MODEL_BUSINESS];
    _createdAt = obj[GlobalUtils.DB_INV_MODEL_CREATED_AT];
    _isNegativeStockAllowed = obj[GlobalUtils.DB_INV_MODEL_IS_NEGATIVE_ALLOW];
    _isTrackable = obj[GlobalUtils.DB_INV_MODEL_IS_TRACKABLE];
    _sku = obj[GlobalUtils.DB_INV_MODEL_SKU];
    _stock = obj[GlobalUtils.DB_INV_MODEL_STOCK];
    _reserved = obj[GlobalUtils.DB_INV_MODEL_RESERVED];
    _updatedAt = obj[GlobalUtils.DB_INV_MODEL_UPDATE_AT];
    __v = obj[GlobalUtils.DB_INV_MODEL_V];
    __id = obj[GlobalUtils.DB_INV_MODEL_ID];
  }

  String get barcode => _barcode;

  String get business => _business;

  String get createdAt => _createdAt;

  bool get isNegativeStock => _isNegativeStockAllowed;

  bool get isTrackable => _isTrackable;

  String get sku => _sku;

  num get stock => _stock;

  num get reserved => _reserved;

  String get updatedAt => _updatedAt;

  num get _v => __v;

  String get _id => __id;
}

class VariantsRef {
  VariantsRef();

  String id;
  List<String> images = List();
  String title;
  String description;
  bool hidden;
  num price;
  num salePrice;
  String sku;
  String barcode;
  List<VariantType> type = List();

  VariantsRef.toMap(dynamic obj) {
    id = obj[GlobalUtils.DB_PROD_MODEL_VAR_ID];
    title = obj[GlobalUtils.DB_PROD_MODEL_VAR_TITLE];
    description = obj[GlobalUtils.DB_PROD_MODEL_VAR_DESCRIPTION];
    hidden = obj[GlobalUtils.DB_PROD_MODEL_VAR_HIDDEN];
    price = obj[GlobalUtils.DB_PROD_MODEL_VAR_PRICE];
    salePrice = obj[GlobalUtils.DB_PROD_MODEL_VAR_SALE_PRICE];
    sku = obj[GlobalUtils.DB_PROD_MODEL_VAR_SKU];
    barcode = obj[GlobalUtils.DB_PROD_MODEL_VAR_BARCODE];
    obj[GlobalUtils.DB_PROD_MODEL_VAR_IMAGES].forEach((img) {
      images.add(img);
    });
  }
}

class VariantType {
  String type;
  String value;
}
