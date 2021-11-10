import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:qr_users/constants.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:qr_users/enums/request_type.dart';

import 'ApiStatus.dart';

class NetworkApi {
  final timeOutDuration = Duration(seconds: 20);

  Future<Object> request(String endPoint, RequestType requestType,
      Map<String, String> headers, body) async {
    http.Response res;
    try {
      DateTime preTime = DateTime.now();
      switch (requestType) {
        case RequestType.GET:
          res = await _get(endPoint, headers);
          break;
        case RequestType.PUT:
          res = await _put(endPoint, headers);
          break;
        case RequestType.DELETE:
          res = await _delete(endPoint, headers);
          break;
        case RequestType.POST:
          res = await _post(endPoint, headers, body: body);
          break;
      }
      DateTime postTime = DateTime.now();
      log("Request Code : ${res.statusCode} time : ${postTime.difference(preTime).inMilliseconds} ms ");
      print(res.statusCode);
      if (res.statusCode == 200) {
        return res.body;
      } else if (res.statusCode == 400 || res.statusCode == 500) {
        return Faliure(
            code: USER_INVALID_RESPONSE, errorResponse: "Invalid Response");
      } else if (res.statusCode == 403 || res.statusCode == 401) {
        return Faliure(code: 401, errorResponse: UN_AUTHORIZED);
      }
    } on SocketException catch (_) {
      return Faliure(code: NO_INTERNET, errorResponse: "No Internet");
    } on TimeoutException catch (_) {
      throw Faliure(
          code: CONNECTION_TIMEOUT, errorResponse: "Connection timeout");
    } catch (e) {
      return Faliure(code: UNKNOWN_ERROR, errorResponse: "Unknown Error");
    }
  }

  Future<http.Response> _get(endPoint, headers) async {
    return await http
        .get(Uri.parse(endPoint), headers: headers)
        .timeout(timeOutDuration);
  }

  // ignore: unused_element
  Future<http.Response> _post(endPoint, headers, {body}) async {
    return await http
        .post(Uri.parse(endPoint), headers: headers, body: body)
        .timeout(timeOutDuration);
  }

  Future<http.Response> _put(endPoint, headers, {body}) async {
    return await http
        .put(Uri.parse(endPoint), headers: headers, body: body)
        .timeout(timeOutDuration);
  }

  Future<http.Response> _delete(
    endPoint,
    headers,
  ) async {
    return await http
        .delete(
          Uri.parse(endPoint),
          headers: headers,
        )
        .timeout(timeOutDuration);
  }
}
