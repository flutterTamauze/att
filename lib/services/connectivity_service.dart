import 'dart:async';

// import 'package:audioplayers/audioplayers.dart';
import 'package:qr_users/enums/connectivity_status.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  StreamController<ConnectivityStatus> connectionStatusController =
      StreamController<ConnectivityStatus>();
  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult event) {
      print("Connection changed : $event");
      var status = _getStatusResult(event);
      connectionStatusController.add(status);
    });
  }
  ConnectivityStatus _getStatusResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
        return ConnectivityStatus.Cellular;
      case ConnectivityResult.wifi:
        return ConnectivityStatus.Wifi;
      case ConnectivityResult.none:
        return ConnectivityStatus.Offline;
      default:
        return ConnectivityStatus.Offline;
    }
  }
}
