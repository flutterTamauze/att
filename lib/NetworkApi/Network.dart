import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:qr_users/enums/request_type.dart';

import '../Core/constants.dart';
import 'NetworkFaliure.dart';

class NetworkApi {
  final timeOutDuration = Duration(seconds: 20);

  Future<Object> request(
      String endPoint, RequestType requestType, Map<String, String> headers,
      [body]) async {
    var res;
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
      print(
          "Request Code : ${res.statusCode} time : ${postTime.difference(preTime).inMilliseconds} ms ");
      if (res.statusCode == 200) {
        print("not faliure");
        return res.body;
      }
    } on SocketException catch (_) {
      return Faliure(code: NO_INTERNET, errorResponse: "No Internet");
    } on TimeoutException catch (_) {
      return Faliure(
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

  Future<bool> isConnectedToInternet(String url) async {
    try {
      final result = await InternetAddress.lookup(url);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      }
    } on SocketException catch (_) {
      print('not connected');
      return false;
    }
    return false;
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
