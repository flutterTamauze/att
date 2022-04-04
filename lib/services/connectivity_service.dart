import 'dart:async';

// import 'package:audioplayers/audioplayers.dart';
import 'package:qr_users/enums/connectivity_status.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qr_users/services/permissions_data.dart';

import '../main.dart';

class ConnectivityService {
  StreamController<ConnectivityStatus> connectionStatusController =
      StreamController<ConnectivityStatus>();
  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult event) {
      var status = _getStatusResult(event);
      connectionStatusController.add(status);
    });
  }
  ConnectivityStatus _getStatusResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
        locator.locator<PermissionHan>().setInternetConnection(true);
        return ConnectivityStatus.Cellular;
      case ConnectivityResult.wifi:
        locator.locator<PermissionHan>().setInternetConnection(true);
        return ConnectivityStatus.Wifi;
      case ConnectivityResult.none:
        locator.locator<PermissionHan>().setInternetConnection(false);
        return ConnectivityStatus.Offline;
      default:
        return ConnectivityStatus.Offline;
    }
  }
}
