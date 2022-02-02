import 'dart:developer';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:http/http.dart' as http;
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Network/NetworkFaliure.dart';

import 'dart:async';

import 'package:qr_users/enums/request_type.dart';

import '../main.dart';
import 'networkInfo.dart';

class NetworkApi {
  final timeOutDuration = const Duration(seconds: 40);

  Future<Object> request(
      String endPoint, RequestType requestType, Map<String, String> headers,
      [body]) async {
    var res;
    final DataConnectionChecker dataConnectionChecker = DataConnectionChecker();

    final NetworkInfoImp networkInfoImp = NetworkInfoImp(dataConnectionChecker);
    final bool isConnected = await networkInfoImp.isConnected;
    if (isConnected) {
      try {
        print("There is a connection");

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
        print(
            "Request Code : ${res.statusCode} time : ${postTime.difference(preTime).inMilliseconds} ms ");

        // print("not faliure");
        // log("Response body : ${res.body}");
        log(res.body);
        return res.body;
      } on TimeoutException catch (e) {
        print("timeout occured $e");
        weakInternetConnection(navigatorKey.currentState.overlay.context);
        return Faliure(code: NO_INTERNET, errorResponse: "NO INTERNET");
      }
    }

    return Faliure(errorResponse: "NO INTERNET", code: NO_INTERNET);
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
