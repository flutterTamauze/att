import 'package:qr_users/Network/Network.dart';
import 'package:qr_users/enums/request_type.dart';

class ReprotsRepo {
  Future<Object> getDailyReport(String url, String userToken) async {
    return NetworkApi().request(
      url,
      RequestType.GET,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
  }

  Future<Object> getUserReport(String url, String userToken) async {
    return NetworkApi().request(
      url,
      RequestType.GET,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
  }

  Future<Object> getLateAbsenceReport(String url, String userToken) async {
    return NetworkApi().request(
      url,
      RequestType.GET,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
  }
}
