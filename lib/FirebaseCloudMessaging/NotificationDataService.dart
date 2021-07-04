import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/permissions_data.dart';

class NotificationDataService with ChangeNotifier {
  bool showNotificationDot = false;

  // setNotificationList(List<NotificationMessage> notifyList) {
  //   notification = notifyList;
  // }

  firebaseMessagingConfig(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((event) {
      print(event.notification.body);
      print(event.notification.title);
      Provider.of<PermissionHan>(context, listen: false)
          .setDialogonStreambool(false);
      Provider.of<PermissionHan>(context, listen: false)
          .setNotificationbool(true);
    });
  }
}
