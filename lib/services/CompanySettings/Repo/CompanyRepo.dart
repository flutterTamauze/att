import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:qr_users/Network/Network.dart';
import 'package:qr_users/enums/request_type.dart';

import '../../../Core/constants.dart';

class CompanyRepo {
  Future<Object> getCompanyData(int companyId, String userToken) async {
    return NetworkApi().request(
      "$baseURL/api/Company/GetCompanyInfoById/$companyId",
      RequestType.GET,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
  }
}
