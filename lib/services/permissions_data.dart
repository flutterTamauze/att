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
  Locale locale = Locale("en_US");
  bool showQr = true;
  bool attendProovTriggered = false;
  bool showNotification = false;
  bool showReport = true;
  bool showSettings = true;
  bool currentDialogOnstream = true;
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
  setNotificationbool(bool data) {
    showNotification = data;
    notifyListeners();
  }

  setDialogonStreambool(bool data) {
    currentDialogOnstream = data;
  }

  setLocale(Locale newLocale) {
    locale = newLocale;
    notifyListeners();
  }

  bool isEnglishLocale() {
    if (locale.toString() == "en_US") {
      return true;
    } else {
      return false;
    }
  }

  triggerAttendProof() {
    attendProovTriggered = true;
  }

  setAttendProoftoDefault() {
    attendProovTriggered = false;
    notifyListeners();
  }

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
