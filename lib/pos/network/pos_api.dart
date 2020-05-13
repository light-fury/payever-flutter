import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../commons/network/network.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class PosApi extends RestDataSource {
  NetworkUtil _netUtil = NetworkUtil();

  Future<dynamic> getAllInventory(String idBusiness, String token) async {
    print("TAG - getAllInventory()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(
            RestDataSource.inventoryUrl +
                idBusiness +
                RestDataSource.inventoryEnd,
            headers: headers)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> patchInventoryAdd(
      String idBusiness, String token, String sku, num qt) async {
    print("TAG - patchInventoryAdd()");
    var body = jsonEncode({"quantity": qt});
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .patch(
            RestDataSource.inventoryUrl +
                idBusiness +
                RestDataSource.skuMid +
                sku +
                RestDataSource.addEnd,
            headers: headers,
            body: body)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> patchInventorySubtract(
      String idBusiness, String token, String sku, num qt) async {
    print("TAG - patchInventorySubtract()");
    var body = jsonEncode({"quantity": qt});
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .patch(
            RestDataSource.inventoryUrl +
                idBusiness +
                RestDataSource.skuMid +
                sku +
                RestDataSource.subtractEnd,
            headers: headers,
            body: body)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> patchInventory(String idBusiness, String token, String sku,
      String barcode, bool track) async {
    print("TAG - patchInventory()");
    var body =
        jsonEncode({"sku": sku, "barcode": barcode, "isTrackable": track});
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .patch(
            RestDataSource.inventoryUrl +
                idBusiness +
                RestDataSource.skuMid +
                sku,
            headers: headers,
            body: body)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> getInventory(
      String idBusiness, String token, String sku, BuildContext context) async {
    print("TAG - getInventory()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };

    return _netUtil
        .get(
            RestDataSource.inventoryUrl +
                idBusiness +
                RestDataSource.skuMid +
                sku,
            headers: headers)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> postFlow(String token, num amount, dynamic cart,
      dynamic channel, String currency) {
    print("TAG - postFlow()");
    var body = jsonEncode({
      "amount": amount,
      "cart": cart,
      "channel_set_id": channel,
      "currency": currency,
    });
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .post(RestDataSource.checkoutV1, headers: headers, body: body)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> patchCart(
      String token, num amount, dynamic cart, String host, String id) {
    print("TAG - postCart($id)");
    var body =
        jsonEncode({"amount": amount, "cart": cart, "x_frame_host": host});

    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .patch(RestDataSource.checkoutV1 + "/$id", headers: headers, body: body)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> patchCheckout(
      Cart cart, String token, String sku, String barcode, bool track) async {
    print("TAG - patchCheckout()");
    var body =
        jsonEncode({"sku": sku, "barcode": barcode, "isTrackable": track});
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .patch(RestDataSource.inventoryUrl + RestDataSource.skuMid + sku,
            headers: headers, body: body)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> getCheckout(String channel, String token) async {
    print("TAG - getCheckout()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(RestDataSource.checkoutFlow + channel + RestDataSource.endCheckout,
            headers: headers)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> postStorageSMS(String token, dynamic flow, dynamic storage,
      bool order, bool code, String numb, String source, String expiration) {
    print("TAG - postStorage()");
    var body = jsonEncode({
      "data": {
        "flow": flow,
        "force_no_order": order,
        "generate_payment_code": code,
        "phone_number": numb,
        "source": source
      },
      "expiresAt": expiration
    });
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .post(RestDataSource.storageUrl, headers: headers, body: body)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> postStorageSimple(
      String token,
      dynamic cart,
      dynamic storage,
      bool order,
      bool code,
      String source,
      String expiration,
      String channel,
      bool sms) {
    print("TAG - postStorage()");
    var body = jsonEncode({
      "data": {
        "flow": {"channel_set_id": channel, "cart": cart},
        "force_no_header": true,
        "force_no_send_to_device": sms,
        "force_no_order": order,
        "generate_payment_code": code
      },
      "expiresAt": expiration
    });
    print(body);
    print(RestDataSource.storageUrl);
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .post(RestDataSource.storageUrl, headers: headers, body: body)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> postStorageSimple2(
      String token,
      dynamic flow,
      dynamic storage,
      bool order,
      bool code,
      String source,
      String expiration,
      String channel,
      bool sms) {
    print("TAG - postStorageSimple2()");
    var body = jsonEncode({
      "data": {
        "flow": flow,
        "force_no_header": true,
        "force_no_send_to_device": sms,
        "force_no_order": order,
        "generate_payment_code": code
      },
      "expiresAt": expiration
    });
    print(body);
    print(RestDataSource.storageUrl);
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .post(RestDataSource.storageUrl, headers: headers, body: body)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> postOrder(String token, dynamic flow, String business) {
    print("TAG - postOrder()");
    var body = jsonEncode(flow);
    print(body);
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .post(RestDataSource.inventoryUrl + business + "/order",
            headers: headers, body: body)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> getStorage(String token, String id) {
    print("TAG - getStorage()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(RestDataSource.storageUrl + "/$id", headers: headers)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> postEditTerminal(
      String id, String name, String logo, String business, String token) {
    print("TAG - postEditTerminal()");
    var body = jsonEncode({"logo": logo, "name": name});
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .patch(
            RestDataSource.posBusiness +
                business +
                RestDataSource.posTerminalMid +
                id,
            headers: headers,
            body: body)
        .then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> postTerminalImage(
      File logo, String business, String token) async {
    print("TAG - postTerminalImage()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "*/*",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    Dio dio = Dio();
    FormData formData = FormData();
    formData.add("file",
        UploadFileInfo(logo, logo.path.substring(logo.path.length - 6)));
    return dio
        .post(
            RestDataSource.mediaBusiness +
                business +
                RestDataSource.mediaImageEnd,
            data: formData,
            options: Options(
                method: 'POST',
                headers: headers,
                responseType: ResponseType.json))
        .then((response) {
      return response.data;
    }).catchError((error) => print(error));
  }
}
