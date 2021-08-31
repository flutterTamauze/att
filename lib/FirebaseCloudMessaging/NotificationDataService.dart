import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/MLmodule/db/SqlfliteDB.dart';
import 'package:qr_users/widgets/StackedNotificationAlert.dart';

import 'NotificationMessage.dart';

class NotificationDataService with ChangeNotifier {
  bool showNotificationDot = false;
  AudioCache player = AudioCache();

  List<NotificationMessage> notification = [];
  // setNotificationList(List<NotificationMessage> notifyList) {
  //   notification = notifyList;
  // }
  DatabaseHelper db = new DatabaseHelper();
  addNotification(String title, String msg, String dateTime, String category,
      String notifiTime, int id) {
    notification.add(NotificationMessage(
        dateTime: dateTime,
        message: msg,
        timeOfMessage: notifiTime,
        title: title,
        category: category,
        messageSeen: 0,
        id: id));
    print("adding temp not. . .");
    notifyListeners();
  }

  deleteNotification(int currentId) {
    notification.removeWhere((element) => element.id == currentId);
    notifyListeners();
  }

  int getUnSeenNotifications() {
    int counter = 0;
    if (notification.length != 0) {
      notification.forEach((element) {
        if (element.messageSeen == 0) {
          counter++;
        }
      });

      return counter;
    }
    return 0;
  }

  initializeNotification(BuildContext context) async {
    Provider.of<NotificationDataService>(context, listen: false)
        .notification
        .clear();
    if (await db.checkNotificationStatus()) {
      print("getting all notifications");
      List<NotificationMessage> dbMessages = await db.getAllNotifications();
      for (int i = 0; i < dbMessages.length; i++) {
        if (!Provider.of<NotificationDataService>(context, listen: false)
            .notification
            .contains(dbMessages[i])) {
          Provider.of<NotificationDataService>(context, listen: false)
              .notification
              .add(dbMessages[i]);
        }
      }

      notifyListeners();
    }
  }

  readMessage(int currentIndex) {
    notification[currentIndex].messageSeen = 1;
    notifyListeners();
  }

  setNotificationDot() {
    showNotificationDot = true;
    notifyListeners();
  }

  resetNotificationDot() {
    showNotificationDot = false;
    notifyListeners();
  }

  bool finshed = false;
  int counter = 0;
  firebaseMessagingConfig(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((event) async {
      counter++;
      print(event.notification.body);
      print(event.notification.title);
      print(counter);
      if (counter == 1) {
        if (event.data["category"] == "attend") {
          showAttendanceCheckDialog(context);
        }

        await db
            .insertNotification(
                NotificationMessage(
                    category: event.data["category"],
                    dateTime: DateTime.now().toString().substring(0, 10),
                    message: event.notification.body,
                    messageSeen: 0,
                    title: event.notification.title,
                    timeOfMessage:
                        DateFormat('kk:mm:a').format(DateTime.now())),
                context)
            .then((value) async => await addNotification(
                event.notification.title,
                event.notification.body,
                DateTime.now().toString().substring(0, 10),
                event.data["category"],
                DateFormat('kk:mm:a').format(DateTime.now()),
                value));

        player.play("notification.mp3");
      }
    });
  }

  showAttendanceCheckDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(minutes: 1), () {
          Navigator.of(context).pop();
        });
        return StackedNotificaitonAlert(
          notificationTitle: "اثبات حضور",
          notificationContent: "برجاء اثبات حضورك قبل انتهاء الوقت المحدد",
          roundedButtonTitle: "اثبات",
          lottieAsset: "resources/notificationalarm.json",
          notificationToast: "تم استقبال اثبات الحضور",
          showToast: true,
          popWidget: false,
          repeatAnimation: true,
        );
      },
    );
  }
}

// Provider.of<PermissionHan>(context, listen: false)
//     .setDialogonStreambool(false);
// Provider.of<PermissionHan>(context, listen: false)
//     .setNotificationbool(true);
