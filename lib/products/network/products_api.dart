import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';

import '../../commons/network/network.dart';
import '../utils/utils.dart';

class ProductsApi extends RestDataSource {
  NetworkUtil _netUtil = NetworkUtil();

  Future<dynamic> checkSKU(String idBusiness, String token, String sku) async {
    print("TAG - checkSKU()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .getWithError(
            RestDataSource.inventoryUrl +
                idBusiness +
                RestDataSource.skuMid +
                sku,
            headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> postInventory(String idBusiness, String token, String sku,
      String barcode, bool track) async {
    print("TAG - postInventory()");
    var body = jsonEncode({
      "sku": sku,
      "barcode": barcode,
      "isNegativeStockAllowed": false,
      "isTrackable": track
    });
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .post(
            RestDataSource.inventoryUrl +
                idBusiness +
                RestDataSource.inventoryEnd,
            headers: headers,
            body: body)
        .then((dynamic res) {
      return res;
    });
  }

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

  Future<dynamic> getShop(
      String idBusiness, String token, BuildContext context) {
    print("TAG - getShop()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(RestDataSource.shopUrl + idBusiness + RestDataSource.shopEnd,
            headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> postImage(File logo, String business, String token) async {
    print("TAG - postImage()");
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
                RestDataSource.mediaProductsEnd,
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
