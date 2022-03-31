import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:qr_users/Network/NetworkFaliure.dart';
import 'package:qr_users/Network/Network.dart';
import 'package:qr_users/enums/request_type.dart';

import '../../../Core/constants.dart';

class SuperCompaniesChartRepo {
  Future<Object> getSuperCharts(String token, int companyID) async {
    try {
      return NetworkApi().request(
          "$baseURL/api/Reports/GetDailyReport_BIO?companyId=$companyID",
          RequestType.GET,
          {
            'Content-type': 'application/json',
            'Authorization': "Bearer $token"
          },
          true);
    } catch (e) {
      print(e);
    }
    return Faliure();
  }
}
