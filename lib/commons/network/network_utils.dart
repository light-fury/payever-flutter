import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkUtil {
  static NetworkUtil _instance = NetworkUtil.internal();

  NetworkUtil.internal();

  factory NetworkUtil() => _instance;

  final JsonDecoder _decoder = JsonDecoder();

  Future<dynamic> get(String url, {Map headers}) {
    return http.get(url, headers: headers).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode >= 400 || json == null) {
        if (statusCode == 401) {}
        throw Exception("$res");
      }
      return _decoder.convert(res);
    });
  }

  Future<dynamic> getWithError(String url, {Map headers}) {
    return http.get(url, headers: headers).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode >= 400 || json == null) {
        throw Exception(statusCode);
      }
      return [_decoder.convert(res), statusCode];
    });
  }

  Future<dynamic> post(String url, {Map headers, body, encoding}) {
    return http
        .post(url, body: body, headers: headers, encoding: encoding)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode >= 400 || json == null) {
        throw Exception("Error while fetching data $statusCode");
      }
      return res == "" ? "" : _decoder.convert(res);
    });
  }

  Future<dynamic> delete(String url, {Map headers, body, encoding}) {
    return http.delete(url, headers: headers).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode >= 400 || json == null) {
        throw Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }

  Future<dynamic> deleteWithBody(String url, {Map headers, body, encoding}) {
    final client = http.Client();

    try {
      return client
          .send(http.Request("DELETE", Uri.parse(url))
            ..headers["authorization"] = "${headers['authorization']}"
            ..headers["content-type"] = "${headers['content-type']}"
            ..headers["user-agent"] = "${headers['user-agent']}"
            ..body = body)
          .then((streamedResponse) {
        http.Response.fromStream(streamedResponse).then((response) {
          final String res = response.body;
          final int statusCode = response.statusCode;
          if (statusCode < 200 || statusCode >= 400 || json == null) {
            throw Exception("Error while fetching data");
          }
          return _decoder.convert(res);
        });
      });
    } finally {
      client.close();
    }
  }

  Future<dynamic> patch(String url, {Map headers, body, encoding}) {
    return http
        .patch(url, body: body, headers: headers, encoding: encoding)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode >= 400 || json == null) {
        throw Exception("Error while fetching data $res");
      }

      return res == "" ? "" : _decoder.convert(res);
    });
  }
}
