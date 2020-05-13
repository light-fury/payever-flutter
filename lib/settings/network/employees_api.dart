import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../commons/network/network.dart';
import '../utils/utils.dart';

class EmployeesApi extends RestDataSource {
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

  Future<dynamic> getAppsBusiness(String idBusiness, String token) {
    print("TAG - getAppsBusiness()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(RestDataSource.businessApps + idBusiness, headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> addEmployee(Object data, String token, String businessId) {
    print("TAG - addEmployee()");
    var body = jsonEncode(data);
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .post(RestDataSource.newEmployee + businessId,
            headers: headers, body: body)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> updateEmployee(
      Object data, String token, String businessId, String userId) {
    print("TAG - updateEmployee()");
//    var body = jsonEncode(data);
    var body = jsonEncode({"position": "Marketing"});
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .patch(RestDataSource.employeesList + businessId + "/" + userId,
            headers: headers, body: body)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> addEmployeesToGroup(
      String token, String businessId, String groupId, Object data) {
    print("TAG - addEmployeesToGroup()");
    var body = jsonEncode(data);
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .post(
            RestDataSource.employeeGroups +
                businessId +
                "/" +
                groupId +
                "/employees",
            headers: headers,
            body: body)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> deleteEmployeesFromGroup(
      String token, String businessId, String groupId, Object data) {
    print("TAG - deleteEmployeeFromGroup()");
    var body = jsonEncode(data);
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .deleteWithBody(
            RestDataSource.employeeGroups +
                businessId +
                "/" +
                groupId +
                "/employees",
            headers: headers,
            body: body)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> deleteEmployeeFromBusiness(
      String token, String businessId, String userId) {
    print("TAG - deleteEmployeeFromBusiness()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .delete(RestDataSource.employeesList + businessId + "/" + userId,
            headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getEmployeesList(
      String id, String token, BuildContext context) {
    print("TAG - getEmployeesList()");

    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };

    return _netUtil
        .get(RestDataSource.employeesList + id, headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getEmployeeDetails(
      String businessId, String userId, String token, BuildContext context) {
    print("TAG - getEmployeeDetails()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(RestDataSource.employeeDetails + businessId + '/' + userId,
            headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getEmployeeGroupsList(
      String businessId, String userId, String token, BuildContext context) {
    print("TAG - getEmployeeGroupsList()");

    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(RestDataSource.employeeGroups + businessId + '/' + userId,
            headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getBusinessEmployeesGroupsList(
      String businessId, String token, BuildContext context) {
    print("TAG - getBusinessEmployeesGroupsList()");

    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(RestDataSource.employeeGroups + businessId, headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> getBusinessEmployeesGroup(
      String token, String businessId, String groupId) {
    print("TAG - getBusinessEmployeesGroup()");

    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .get(RestDataSource.employeeGroups + businessId + "/" + groupId,
            headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> addNewGroup(Object data, String token, String businessId) {
    print("TAG - addNewGroup()");
    var body = jsonEncode(data);
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .post(RestDataSource.employeeGroups + businessId,
            headers: headers, body: body)
        .then((dynamic result) {
      return result;
    });
  }

  Future<dynamic> deleteGroup(String token, String businessId, String groupId) {
    print("TAG - deleteGroup()");
    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil
        .delete(RestDataSource.employeeGroups + businessId + "/" + groupId,
            headers: headers)
        .then((dynamic result) {
      return result;
    });
  }

    Future<dynamic> getWallpapers() {
    print("TAG - getWallpapers()");
    var headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil.get(RestDataSource.wallpaperAll, headers: headers).then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> postWallpaper(String token,String wallpaper,String business) {
    print("TAG - postWallpaper()");
    var body = jsonEncode({"wallpaper":"$wallpaper"});
    var headers = {HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil.post(RestDataSource.wallpaperUrl+business+"/wallpapers/active",headers: headers, body: body).then((dynamic res) {
      return res;
    });
  }
  Future<dynamic> patchLanguage(String token,String language) {
    print("TAG - patchLanguage()");
    var body = jsonEncode({"language": "$language"});
    var headers = {HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.userAgentHeader: GlobalUtils.fingerprint
    };
    return _netUtil.patch(RestDataSource.userUrl, headers: headers,body: body).then((dynamic res) {
      return res;
    });
  }

}
