import 'dart:io';

import 'package:flutter/material.dart';

import '../../commons/network/network.dart';
import '../utils/utils.dart';

class TransactionsApi extends RestDataSource {
  NetworkUtil _netUtil = NetworkUtil();

  Future<dynamic> getTransactionDetail(
      String idBusiness, String token, String idTrans, BuildContext context) {
    print("TAG - getTransactionDetail()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };

    return _netUtil
        .get(
            RestDataSource.transactionWidUrl +
                idBusiness +
                RestDataSource.transactionWidDetails +
                idTrans,
            headers: headers)
        .then((dynamic result) {
      return result;
    });
  }
}
