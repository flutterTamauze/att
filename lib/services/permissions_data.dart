import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PrData {
  String interfaceName;
  IconData icon;
  final Permission permission;

  PrData({this.icon, this.interfaceName, this.permission});
}

class PermissionHan with ChangeNotifier {
  bool showHome = true;
  bool showQr = true;
  bool showReport = true;
  bool showSettings = true;
  List<PrData> permissionsList = [
    PrData(
        icon: Icons.location_on,
        interfaceName: "تصريح الموقع",
        permission: Permission.locationWhenInUse),

    // PrData(interfaceName: "تصريح الصور", permission: Permission.storage),
    // PrData(interfaceName: "تصريح الصوت", permission: Permission.microphone),
    PrData(
        icon: Icons.camera_alt_outlined,
        interfaceName: "تصريح الكاميرا",
        permission: Permission.camera)
  ];

  Future filterList() async {
    permissionsList.forEach((element) async {
      if (await element.permission.status == PermissionStatus.granted) {
        permissionsList.remove(element);
      }
      print(permissionsList.length);
    });
    notifyListeners();
  }

  deletePer(int id) {
    print(id);
    permissionsList.removeAt(id);
    notifyListeners();
  }
}
