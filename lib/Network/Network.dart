import 'dart:developer';
import 'dart:io';

// import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Network/NetworkFaliure.dart';
import 'package:qr_users/enums/connectivity_status.dart';

import 'dart:async';

import 'package:qr_users/enums/request_type.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';

import '../main.dart';
import 'networkInfo.dart';

class NetworkApi {
  final timeOutDuration = const Duration(seconds: 40);

  Future<Object> request(
      String endPoint, RequestType requestType, Map<String, String> headers,
      [body]) async {
    var res;

    try {
      debugPrint("There is a connection");

      final DateTime preTime = DateTime.now();
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
      final DateTime postTime = DateTime.now();

      debugPrint(
          "Request Code : ${res.statusCode} time : ${postTime.difference(preTime).inMilliseconds} ms ");

      log(res.body);
      log(endPoint);
      if (res.statusCode == 500 || res.statusCode == 503) {
        locator.locator<PermissionHan>().setServerDown(true);
        if (_displayExceptionDialog()) {
          serverDownDialog(navigatorKey.currentState.overlay.context);
        }

        return Faliure(code: USER_INVALID_RESPONSE, errorResponse: "null");
      }

      // locator.locator<PermissionHan>().setServerDown(true);
      // debugPrint(locator.locator<UserData>().user.userToken);
      // if (locator.locator<UserData>().user.userToken != null) {
      //   serverDownDialog(navigatorKey.currentState.overlay.context);
      // }

      // return Faliure(code: USER_INVALID_RESPONSE, errorResponse: "null");
      locator.locator<PermissionHan>().setInternetConnection(true);
      locator.locator<PermissionHan>().setServerDown(false);
      return res.body;
    } on SocketException catch (e) {
      print(e);
      locator.locator<PermissionHan>().setInternetConnection(false);
      if (_displayExceptionDialog()) {
        noInternetDialog(navigatorKey.currentState.overlay.context);
      }

      return Faliure(code: NO_INTERNET, errorResponse: "NO INTERNET");
    } on TimeoutException catch (e) {
      print("timeout occured $e");
      debugPrint(locator.locator<UserData>().user.userToken);
      locator.locator<PermissionHan>().setInternetConnection(false);
      if ((_displayExceptionDialog())) {
        noInternetDialog(navigatorKey.currentState.overlay.context);
      }

      return Faliure(code: NO_INTERNET, errorResponse: "NO INTERNET");
    } on HandshakeException catch (e) {
      print("timeout occured $e");
      debugPrint(locator.locator<UserData>().user.userToken);
      locator.locator<PermissionHan>().setInternetConnection(false);
      if ((_displayExceptionDialog())) {
        noInternetDialog(navigatorKey.currentState.overlay.context);
      }

      return Faliure(code: NO_INTERNET, errorResponse: "NO INTERNET");
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
    debugPrint("body $body");
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

  bool _displayExceptionDialog() {
    if (locator.locator<UserData>().user.userToken != "") {
      return true;
    }
    return false;
  }

  Future<bool> isConnectedToInternet(String url) async {
    try {
      final result = await InternetAddress.lookup(url);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        debugPrint('connected');
        return true;
      }
    } on SocketException catch (_) {
      debugPrint('not connected');
      return false;
    }
    return false;
  }
}
