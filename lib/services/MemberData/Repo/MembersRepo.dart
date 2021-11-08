import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:qr_users/NetworkApi/ApiStatus.dart';

import '../../../constants.dart';

class MemberRepo {
  Future<Object> getMemberData() async {
    final _apiToken = 'ByYM000OLlMQG6VVVp1OH7Xzyr7gHuw1qvUC5dcGt3SNM';
    var url = Uri.parse("$baseURL/api/Authenticate/login");
    try {
      var response = await http.post(url, headers: {
        'Content-type': 'application/json',
        'x-api-key': _apiToken
      }).timeout(Duration(seconds: 25));
      if (response.statusCode == 200) {
        return Success(response: response.body);
      }
      return Faliure(
          code: USER_INVALID_RESPONSE, errorResponse: "Invalid Response");
    } on SocketException catch (_) {
      return Faliure(code: NO_INTERNET, errorResponse: "No Internet");
    } on FormatException {
      return Faliure(code: INVALID_FORMAT, errorResponse: "Invalid Format");
    } on TimeoutException catch (_) {
      throw Faliure(
          code: CONNECTION_TIMEOUT, errorResponse: "Connection timeout");
    } catch (e) {
      return Faliure(code: UNKNOWN_ERROR, errorResponse: "Unknown Error");
    }
  }
}
