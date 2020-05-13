import 'dart:core';

import '../utils/utils.dart';

class TransactionCardData {
  List<Month> lastYear = List();
  List<Day> lastMonth = List();
}

class Month {
  String _date;
  num _amount;
  String _currency;

  Month.map(dynamic obj) {
    this._date = obj[GlobalUtils.APP_WID_LAST_DATE];
    this._amount = obj[GlobalUtils.APP_WID_LAST_AMOUNT];
    this._currency = obj[GlobalUtils.APP_WID_LAST_CURRENCY];
  }

  String get date => _date;

  num get amount => _amount;

  String get currency => _currency;
}

class Day {
  String _date;
  num _amount;
  String _currency;

  Day.map(dynamic obj) {
    this._date = obj[GlobalUtils.APP_WID_LAST_DATE];
    this._amount = obj[GlobalUtils.APP_WID_LAST_AMOUNT];
    this._currency = obj[GlobalUtils.APP_WID_LAST_CURRENCY];
  }

  String get date => _date;

  num get amount => _amount;

  String get currency => _currency;
}

class Transaction {
  List<Collection> _collection = List();
  PaginationData _paginationData;
  Usages _usages;

  Transaction.toMap(dynamic obj) {
    _paginationData =
        PaginationData.toMap(obj[GlobalUtils.DB_TRANSACTIONS_PAGINATION]);
    _usages = Usages.toMap(obj[GlobalUtils.DB_TRANSACTIONS_USAGES]);
    print(_usages);
    dynamic _tempCol = obj[GlobalUtils.DB_TRANSACTIONS_COLLECTION];

    _tempCol.forEach((_collections) {
      _collection.add(Collection.toMap(_collections));
    });
  }

  List<Collection> get collection => _collection;

  PaginationData get paginationData => _paginationData;

  Usages get usages => usages;
}

class Collection {
  bool _actionRunning;
  num _amount;
  BillingAddress _billingAddress;
  int _businessOptionId;
  String _businessUuid;
  String _channel;
  String _channelSetUuid;
  String _createdAt;
  String _currency;
  String _customerEmail;
  String _customerName;
  List<TDHistory> _history = List();
  String _merchantEmail;
  String _merchantName;
  String _originalId;
  List<String> _paymentDetails = List();
  String _paymentFlowId;
  String _place;
  String _reference;
  List<String> _santanderApplications = List();
  String _status;
  num _total;
  String _type;
  String _updatedAt;
  String _uuid;
  String _id;

  Collection.toMap(dynamic obj) {
    _actionRunning = obj[GlobalUtils.DB_TRANSACTIONS_C_ACTION_R];

    _amount = obj[GlobalUtils.DB_TRANSACTIONS_C_AMOUNT];

    _billingAddress =
        BillingAddress.toMap(obj[GlobalUtils.DB_TRANSACTIONS_C_BILLING]);
    _currency = obj[GlobalUtils.DB_TRANSACTIONS_C_CURRENCY];
    _businessOptionId = obj[GlobalUtils.DB_TRANSACTIONS_C_BUS_OPT];
    _businessUuid = obj[GlobalUtils.DB_TRANSACTIONS_C_BUS_UUID];
    _channel = obj[GlobalUtils.DB_TRANSACTIONS_C_CHANNEL];
    _channelSetUuid = obj[GlobalUtils.DB_TRANSACTIONS_C_CH_SET];
    _createdAt = obj[GlobalUtils.DB_TRANSACTIONS_C_CREATED_AT];
    _customerEmail = obj[GlobalUtils.DB_TRANSACTIONS_C_CUSTOMER_E];
    _customerName = obj[GlobalUtils.DB_TRANSACTIONS_C_CUSTOMER_N];
    _merchantEmail = obj[GlobalUtils.DB_TRANSACTIONS_C_MERCHANT_E];
    _merchantName = obj[GlobalUtils.DB_TRANSACTIONS_C_MERCHANT_N];
    _originalId = obj[GlobalUtils.DB_TRANSACTIONS_C_ORIGINAL_ID];
    _paymentFlowId = obj[GlobalUtils.DB_TRANSACTIONS_C_PAYMENT_FLO];
    _place = obj[GlobalUtils.DB_TRANSACTIONS_C_PLACE];
    _reference = obj[GlobalUtils.DB_TRANSACTIONS_C_REFERENCE];
    _status = obj[GlobalUtils.DB_TRANSACTIONS_C_STATUS];
    _total = obj[GlobalUtils.DB_TRANSACTIONS_C_TOTAL];
    _type = obj[GlobalUtils.DB_TRANSACTIONS_C_TYPE];
    _updatedAt = obj[GlobalUtils.DB_TRANSACTIONS_C_UPDATED_AT];
    _uuid = obj[GlobalUtils.DB_TRANSACTIONS_C_UUID];
    _id = obj[GlobalUtils.DB_TRANSACTIONS_C_ID];

    dynamic tempHist = obj[GlobalUtils.DB_TRANSACTIONS_C_HISTORY];

    tempHist.forEach((_histories) {
      _history.add(TDHistory.toMap(_histories));
    });

    dynamic tempSant = obj[GlobalUtils.DB_TRANSACTIONS_C_SANTANDER];

    tempSant.forEach((sant) {
      _santanderApplications.add(sant);
    });
  }

  bool get actionRunning => _actionRunning;

  num get amount => _amount;

  BillingAddress get billingAddress => _billingAddress;

  int get businessOptionId => _businessOptionId;

  String get businessUuid => _businessUuid;

  String get channel => _channel;

  String get channelSetUuid => _channelSetUuid;

  String get createdAt => _createdAt;

  String get currency => _currency;

  String get customerEmail => _customerEmail;

  String get customerName => _customerName;

  List<TDHistory> get history => _history;

  String get merchantEmail => _merchantEmail;

  String get merchantName => _merchantName;

  String get originalId => _originalId;

  List<String> get paymentDetails => _paymentDetails;

  String get paymentFlowId => _paymentFlowId;

  String get place => _place;

  String get reference => _reference;

  List<String> get santanderApplications => _santanderApplications;

  String get status => _status;

  num get total => _total;

  String get type => _type;

  String get updatedAt => _updatedAt;

  String get uuid => _uuid;

  String get id => _id;
}

class BillingAddress {
  String _city;
  String _country;
  String _countryName;
  String _email;
  String _firstName;
  String _lastName;
  String _salutation;
  String _street;
  String _zipCode;
  String _id;

  BillingAddress.toMap(dynamic obj) {
    _city = obj[GlobalUtils.DB_TRANSACTIONS_C_B_CITY];
    _country = obj[GlobalUtils.DB_TRANSACTIONS_C_B_COUNTRY];
    _countryName = obj[GlobalUtils.DB_TRANSACTIONS_C_B_COUNTRY_N];
    _email = obj[GlobalUtils.DB_TRANSACTIONS_C_B_EMAIL];
    _firstName = obj[GlobalUtils.DB_TRANSACTIONS_C_B_FIRST_NAME];
    _lastName = obj[GlobalUtils.DB_TRANSACTIONS_C_B_LAST_NAME];
    _salutation = obj[GlobalUtils.DB_TRANSACTIONS_C_B_SALUTATION];
    _street = obj[GlobalUtils.DB_TRANSACTIONS_C_B_STREET];
    _zipCode = obj[GlobalUtils.DB_TRANSACTIONS_C_B_ZIP_CODE];
    _id = obj[GlobalUtils.DB_TRANSACTIONS_C_B_ID];
  }

  String get city => _city;

  String get country => _country;

  String get countryName => _countryName;

  String get email => _email;

  String get firstName => _firstName;

  String get lastName => _lastName;

  String get salutation => _salutation;

  String get street => _street;

  String get zipCode => _zipCode;

  String get id => _id;
}

class History {
  String _action;
  String _createdAt;
  String _paymentStatus;
  List<dynamic> _refundItems = List();
  List<dynamic> _uploadItems = List();
  String _id;

  History.toMap(dynamic obj) {
    _action = obj[GlobalUtils.DB_TRANSACTIONS_C_H_ACTION];
    _createdAt = obj[GlobalUtils.DB_TRANSACTIONS_C_H_CREATED_AT];
    _paymentStatus = obj[GlobalUtils.DB_TRANSACTIONS_C_H_PAYMENT_ST];
    _id = obj[GlobalUtils.DB_TRANSACTIONS_C_H_ID];

    dynamic temp = obj[GlobalUtils.DB_TRANSACTIONS_C_H_REFUNDS];
    temp.forEach((details) {
      refundItems.add(details);
    });

    dynamic tempSant = obj[GlobalUtils.DB_TRANSACTIONS_C_H_UPLOAD];
    tempSant.forEach((sant) {
      uploadItems.add(sant);
    });
  }

  String get action => _action;

  String get createdAt => _createdAt;

  String get paymentStatus => _paymentStatus;

  List<String> get refundItems => _refundItems;

  List<String> get uploadItems => _uploadItems;

  String get id => _id;
}

class PaginationData {
  num _page;
  num _total;
  num _amount;

  PaginationData.toMap(dynamic obj) {
    _page = obj[GlobalUtils.DB_TRANSACTIONS_P_PAGE];
    _total = obj[GlobalUtils.DB_TRANSACTIONS_P_TOTAL];
    _amount = obj[GlobalUtils.DB_TRANSACTIONS_P_AMOUNT];
  }

  num get current => _page;

  num get amount => _amount;

  num get total => _total;
}

class Usages {
  List<SpecificStatuses> _specificStatuses = List();
  List<Statuses> _statuses = List();

  Usages.toMap(dynamic obj) {
    dynamic temSpec = obj[GlobalUtils.DB_TRANSACTIONS_U_SPECIFIC];

    temSpec.forEach((_histories) {
      _specificStatuses.add(SpecificStatuses.toMap(_histories));
    });

    dynamic temStat = obj[GlobalUtils.DB_TRANSACTIONS_U_STATUS];
    print(temStat);

    temSpec.forEach((_histories) {
      _statuses.add(Statuses.toMap(_histories));
    });
  }

  List<SpecificStatuses> get specificStatuses => _specificStatuses;

  List<Statuses> get statuses => _statuses;
}

class SpecificStatuses {
  String _status;

  SpecificStatuses.toMap(dynamic obj) {
    _status = obj;
  }

  String get status => _status;
}

class Statuses {
  String _status;

  Statuses.toMap(dynamic obj) {
    _status = obj;
  }

  String get status => _status;
}

//------------------------------
//------------------------------

class TransactionDetails {
  List<Actions> actions = List();
  TDBillingAddress billingAddress;
  TDBusiness business;
  CartItems cart;
  TDChannel channel;
  TDChannelSet channelSet;
  Customer customer;
  TDDetails details;
  List<TDHistory> history = List();
  Merchant merchant;
  PaymentFlow paymentFlow;
  PaymentOption paymentOption;
  ShippingOption shipping;
  Status status;
  Store store;
  TDTransaction transaction;
  UserId user;

  TransactionDetails.toMap(dynamic obj) {
    if (obj[GlobalUtils.DB_TRANS_DETAIL_ACTIONS].isNotEmpty) {
      obj[GlobalUtils.DB_TRANS_DETAIL_ACTIONS].forEach((action) {
        actions.add(Actions.toMap(action));
      });
    }
    if (obj[GlobalUtils.DB_TRANS_DETAIL_HISTORY].isNotEmpty) {
      obj[GlobalUtils.DB_TRANS_DETAIL_HISTORY].forEach((histories) {
        history.add(TDHistory.toMap(histories));
      });
    }

    billingAddress =
        TDBillingAddress.toMap(obj[GlobalUtils.DB_TRANS_DETAIL_BILLING_ADDRESS]);
    business = TDBusiness.toMap(obj[GlobalUtils.DB_TRANS_DETAIL_BUSINESS]);
    cart = CartItems.toMap(obj[GlobalUtils.DB_TRANS_DETAIL_CART]);
    channel = TDChannel.toMap(obj[GlobalUtils.DB_TRANS_DETAIL_CHANNEL]);
    channelSet =
        TDChannelSet.toMap(obj[GlobalUtils.DB_TRANS_DETAIL_CHANNEL_SET]);
    customer = Customer.toMap(obj[GlobalUtils.DB_TRANS_DETAIL_CUSTOMER]);
    details = TDDetails.toMap(obj[GlobalUtils.DB_TRANS_DETAIL_DETAILS]);
    merchant = Merchant.toMap(obj[GlobalUtils.DB_TRANS_DETAIL_MERCHANT]);
    paymentFlow =
        PaymentFlow.toMap(obj[GlobalUtils.DB_TRANS_DETAIL_PAYMENT_FLOW]);
    paymentOption =
        PaymentOption.toMap(obj[GlobalUtils.DB_TRANS_DETAIL_PAYMENT_OPTION]);
    shipping = ShippingOption.toMap(obj[GlobalUtils.DB_TRANS_DETAIL_SHIPPING]);
    status = Status.toMap(obj[GlobalUtils.DB_TRANS_DETAIL_STATUS]);
    store = Store.toMap(obj[GlobalUtils.DB_TRANS_DETAIL_STORE]);
    transaction =
        TDTransaction.toMap(obj[GlobalUtils.DB_TRANS_DETAIL_TRANSACTION]);
    user = UserId.toMap(obj[GlobalUtils.DB_TRANS_DETAIL_USER]);
  }
}

class Actions {
  String action;
  bool enabled;

  Actions.toMap(dynamic obj) {
    action = obj[GlobalUtils.DB_TRANS_DETAIL_ACT_ACTION];
    enabled = obj[GlobalUtils.DB_TRANS_DETAIL_ACT_ENABLED];
  }
}

class TDBillingAddress {
  String city;
  String country;
  String countryName;
  String email;
  String firstName;
  String id;
  String lastName;
  String salutation;
  String street;
  String zipCode;
  String _id;

  TDBillingAddress.toMap(dynamic obj) {
    city = obj[GlobalUtils.DB_TRANS_DETAIL_BA_CITY];
    country = obj[GlobalUtils.DB_TRANS_DETAIL_BA_COUNTRY];
    countryName = obj[GlobalUtils.DB_TRANS_DETAIL_BA_COUNTRY_NAME];
    email = obj[GlobalUtils.DB_TRANS_DETAIL_BA_EMAIL];
    firstName = obj[GlobalUtils.DB_TRANS_DETAIL_BA_FIRST_NAME];
    id = obj[GlobalUtils.DB_TRANS_DETAIL_BA_ID];
    lastName = obj[GlobalUtils.DB_TRANS_DETAIL_BA_LAST_NAME];
    salutation = obj[GlobalUtils.DB_TRANS_DETAIL_BA_SALUTATION];
    street = obj[GlobalUtils.DB_TRANS_DETAIL_BA_STREET];
    zipCode = obj[GlobalUtils.DB_TRANS_DETAIL_BA_ZIP_CODE];
    _id = obj[GlobalUtils.DB_TRANS_DETAIL_BA__ID];
  }
}

class TDBusiness {
  String uuid;

  TDBusiness.toMap(dynamic obj) {
    //uuid = obj[GlobalUtils.DB_TRANS_DETAIL_BUSINESS_UUID];
  }
}

class CartItems {
  List<Items> items = List();
  List<AvailableRefundItems> availableRefundItems = List();

  CartItems.toMap(dynamic obj) {
    if (obj[GlobalUtils.DB_TRANS_DETAIL_ITEMS].isNotEmpty) {
      obj[GlobalUtils.DB_TRANS_DETAIL_ITEMS].forEach((item) {
        items.add(Items.toMap(item));
      });
    }
    if (obj[GlobalUtils.DB_TRANS_DETAIL_ITEMS_AVAIL_REF].isNotEmpty) {
      obj[GlobalUtils.DB_TRANS_DETAIL_ITEMS_AVAIL_REF].forEach((item) {
        availableRefundItems.add(AvailableRefundItems.toMap(item));
      });
    }
  }
}

class Items {
  String createdAt;
  String id;
  String identifier;
  String name;
  num price;
  num priceNet;
  num quantity;
  String thumbnail;
  String updatedAt;
  num vatRate;
  String _id;

  Items.toMap(dynamic obj) {
    createdAt = obj[GlobalUtils.DB_TRANS_DETAIL_IT_CREATED_AT];
    id = obj[GlobalUtils.DB_TRANS_DETAIL_IT_ID];
    identifier = obj[GlobalUtils.DB_TRANS_DETAIL_IT_IDENTIFIER];
    name = obj[GlobalUtils.DB_TRANS_DETAIL_IT_NAME];
    price = obj[GlobalUtils.DB_TRANS_DETAIL_IT_PRICE];
    priceNet = obj[GlobalUtils.DB_TRANS_DETAIL_IT_PRICE_NET];
    quantity = obj[GlobalUtils.DB_TRANS_DETAIL_IT_QUANTITY];
    thumbnail = obj[GlobalUtils.DB_TRANS_DETAIL_IT_THUMBNAIL];
    updatedAt = obj[GlobalUtils.DB_TRANS_DETAIL_IT_UPDATED_AT];
    vatRate = obj[GlobalUtils.DB_TRANS_DETAIL_IT_VAT_RATE];
    _id = obj[GlobalUtils.DB_TRANS_DETAIL_IT__ID];
  }
}

class AvailableRefundItems {
  num count;
  String itemUuid;

  AvailableRefundItems.toMap(dynamic obj) {
    count = obj[GlobalUtils.DB_TRANS_DETAIL_IT_REF_COUNT];
    itemUuid = obj[GlobalUtils.DB_TRANS_DETAIL_IT_REF_UUID];
  }
}

class TDChannel {
  String name;

  TDChannel.toMap(dynamic obj) {
    name = obj[GlobalUtils.DB_TRANS_DETAIL_CHANNEL_NAME];
  }
}

class TDChannelSet {
  String uuid;

  TDChannelSet.toMap(dynamic obj) {
    uuid = obj[GlobalUtils.DB_TRANS_DETAIL_CHANNEL_SET_UUID];
  }
}

class Customer {
  String email;
  String name;

  Customer.toMap(dynamic obj) {
    email = obj[GlobalUtils.DB_TRANS_DETAIL_CUSTOMER_EMAIL];
    name = obj[GlobalUtils.DB_TRANS_DETAIL_CUSTOMER_NAME];
  }
}

class TDDetails {
  String financeId;
  String applicationNo;
  String applicationNumber;
  String usageText;
  String panId;
  String reference;
  String iban;

  TDDetails.toMap(dynamic obj) {
    financeId = obj[GlobalUtils.DB_TRANS_DETAIL_ORDER]
        [GlobalUtils.DB_TRANS_DETAIL_OR_FINANCE_ID];
    applicationNo = obj[GlobalUtils.DB_TRANS_DETAIL_ORDER]
        [GlobalUtils.DB_TRANS_DETAIL_OR_APPLICATION_NO];
    applicationNumber = obj[GlobalUtils.DB_TRANS_DETAIL_ORDER]
        [GlobalUtils.DB_TRANS_DETAIL_OR_APPLICATION_NU];
    usageText = obj[GlobalUtils.DB_TRANS_DETAIL_ORDER]
        [GlobalUtils.DB_TRANS_DETAIL_OR_USAGE_TEXT];
    panId = obj[GlobalUtils.DB_TRANS_DETAIL_ORDER]
        [GlobalUtils.DB_TRANS_DETAIL_OR_PAN_ID];
    reference = obj[GlobalUtils.DB_TRANS_DETAIL_ORDER]
        [GlobalUtils.DB_TRANS_DETAIL_OR_REFERENCE];
    if (obj[GlobalUtils.DB_TRANS_DETAIL_OR__IBAN] != null) {
      iban = obj[GlobalUtils.DB_TRANS_DETAIL_OR__IBAN];
    } else {
      iban = obj[GlobalUtils.DB_TRANS_DETAIL_OR_IBAN];
    }
  }
}

class CreditCalculation {}

class DetailsCustomer {}

class TDHistory {
  String action;
  String createdAt;
  String id;
  String paymentStatus;
  String _id;
  num amount;

  TDHistory.toMap(dynamic obj) {
    action = obj[GlobalUtils.DB_TRANS_DETAIL_HIST_ACTION];
    createdAt = obj[GlobalUtils.DB_TRANS_DETAIL_HIST_CREATED_AT];
    id = obj[GlobalUtils.DB_TRANS_DETAIL_HIST_ID];
    _id = obj[GlobalUtils.DB_TRANS_DETAIL_HIST__ID];
    paymentStatus = obj[GlobalUtils.DB_TRANS_DETAIL_HIST_PAY_STATUS];
    amount = obj[GlobalUtils.DB_TRANS_DETAIL_HIST_AMOUNT];
  }
}

class Merchant {
  String email;
  String name;

  Merchant.toMap(dynamic obj) {
    email = obj[GlobalUtils.DB_TRANS_DETAIL_MERC_EMAIL];
    name = obj[GlobalUtils.DB_TRANS_DETAIL_MERC_NAME];
  }
}

class PaymentFlow {
  String id;

  PaymentFlow.toMap(dynamic obj) {
    id = obj[GlobalUtils.DB_TRANS_DETAIL_PAYMENT_FLOW_ID];
  }
}

class PaymentOption {
  num downPayment;
  num id;
  String type;
  num paymentFee;

  PaymentOption.toMap(dynamic obj) {
    downPayment = obj[GlobalUtils.DB_TRANS_DETAIL_PAY_OPT_DOWN_PAY];
    id = obj[GlobalUtils.DB_TRANS_DETAIL_PAY_OPT_ID];
    type = obj[GlobalUtils.DB_TRANS_DETAIL_PAY_OPT_TYPE];
    paymentFee = obj[GlobalUtils.DB_TRANS_DETAIL_PAY_OPT_FEE];
  }
}

class ShippingOption {
  String methodName;
  num deliveryFee;

  ShippingOption.toMap(dynamic obj) {
    methodName = obj[GlobalUtils.DB_TRANS_DETAIL_SHIPPING_METHOD];
    deliveryFee = obj[GlobalUtils.DB_TRANS_DETAIL_SHIPPING_FEE];
  }
}

class Status {
  String general;
  String place;
  String specific;

  Status.toMap(dynamic obj) {
    general = obj[GlobalUtils.DB_TRANS_DETAIL_STATUS_GENERAL];
    place = obj[GlobalUtils.DB_TRANS_DETAIL_STATUS_PLACE];
    specific = obj[GlobalUtils.DB_TRANS_DETAIL_STATUS_SPECIFIC];
  }
}

class Store {
  String id;

  Store.toMap(dynamic obj) {
    id = obj[GlobalUtils.DB_TRANS_DETAIL_STORE];
  }
}

class TDTransaction {
  num amount;
  num amountRefunded;
  num amountRest;
  num total;
  String createdAt;
  String currency;
  String id;
  String originalID;
  String reference;
  String updatedAt;
  String uuid;

  TDTransaction.toMap(dynamic obj) {
    amount = obj[GlobalUtils.DB_TRANS_DETAIL_TRANS_AMOUNT];
    amountRefunded = obj[GlobalUtils.DB_TRANS_DETAIL_TRANS_AMOUNT_REF];
    amountRest = obj[GlobalUtils.DB_TRANS_DETAIL_TRANS_AMOUNT_REST];
    total = obj[GlobalUtils.DB_TRANS_DETAIL_TRANS_TOTAL];
    createdAt = obj[GlobalUtils.DB_TRANS_DETAIL_TRANS_CREATED_AT];
    currency = obj[GlobalUtils.DB_TRANS_DETAIL_TRANS_CURRENCY];
    id = obj[GlobalUtils.DB_TRANS_DETAIL_TRANS_ID];
    originalID = obj[GlobalUtils.DB_TRANS_DETAIL_TRANS_ORIGINAL_ID];
    reference = obj[GlobalUtils.DB_TRANS_DETAIL_TRANS_REFERENCE];
    updatedAt = obj[GlobalUtils.DB_TRANS_DETAIL_TRANS_UPDATED_AT];
    uuid = obj[GlobalUtils.DB_TRANS_DETAIL_TRANS_UUID];
  }
}

class UserId {
  String id;

  UserId.toMap(dynamic obj);
}

//------------not yet used-----------//
class DBTransaction {
  String _channel;
  num _amount;
  String _id;
  String _date;
  String _status;
  String _paymentM;

  DBTransaction(this._amount, this._channel, this._id, this._date,
      this._paymentM, this._status);

  String get channel => _channel;

  String get id => _id;

  num get amount => _amount;

  String get date => _date;

  String get status => _status;

  String get payment => _paymentM;

//  set id(String id) => _id = id;
//
//  set channel(String channel) => _channel = channel;
//
//  set amount(num amount) => _amount = amount;
//
//  set date(String date) => _date = date;
//
//  set status(String status) => _status = status;
//
//  set payment(String pay) => _paymentM = pay;

}
