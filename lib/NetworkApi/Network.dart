import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:qr_users/NetworkApi/NetworkException.dart';
import 'package:qr_users/constants.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:qr_users/enums/request_type.dart';

class NetworkApi {
  final timeOutDuration = Duration(seconds: 20);
  final defaultErrorMessage = "حدث خطأ ما";
  final defaultNetworkMessage = "لا يوجد اتصال بالأنترنت";
  Future<dynamic> request(String endPoint, RequestType requestType,
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
      final result = json.decode(res.body);
      if (result["message"] != null) {
        return res;
      } else {
        throw NetworkException(defaultErrorMessage);
      }
    } on SocketException catch (_) {
      throw NetworkException(defaultNetworkMessage);
    } on HandshakeException catch (_) {
      throw NetworkException(defaultNetworkMessage);
    } on TimeoutException catch (_) {
      throw NetworkException("Connection timeout");
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<http.Response> _get(endPoint, headers) async {
    return await http
        .get(Uri.parse(baseURL + endPoint), headers: headers)
        .timeout(timeOutDuration);
  }

  // ignore: unused_element
  Future<http.Response> _post(endPoint, headers, {body}) async {
    return await http
        .post(Uri.parse(baseURL + endPoint), headers: headers, body: body)
        .timeout(timeOutDuration);
  }

  Future<http.Response> _put(endPoint, headers, {body}) async {
    return await http
        .put(Uri.parse(baseURL + endPoint), headers: headers, body: body)
        .timeout(timeOutDuration);
  }

  Future<http.Response> _delete(
    endPoint,
    headers,
  ) async {
    return await http
        .delete(
          Uri.parse(baseURL + endPoint),
          headers: headers,
        )
        .timeout(timeOutDuration);
  }
}
