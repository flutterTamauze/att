import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/MLmodule/db/SqlfliteDB.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/StackedNotificationAlert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NotificationMessage.dart';
// import 'package:huawei_push/huawei_push_library.dart' as hawawi;

class NotificationDataService with ChangeNotifier {
  bool showNotificationDot = false;
  AudioCache player = AudioCache();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
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
    notification = notification.reversed.toList();
    debugPrint("adding temp not. . .");
    notifyListeners();
  }

  readNotificationByTime(notifiTitle) {
    notification
        .firstWhere((element) => element.title == notifiTitle)
        .messageSeen = 1;
    notifyListeners();
    final int notificationID =
        notification.firstWhere((element) => element.title == notifiTitle).id;

    db.readMessage(1, notificationID);
  }

  // tokenRefresh() {
  //   firebaseMessaging.onTokenRefresh.listen((event) {
  //     if (locator.locator<UserData>().user.userType == 4 ||
  //         locator.locator<UserData>().user.userType == 3) {
  //       firebaseMessaging
  //           .subscribeToTopic("attend${locator.locator<CompanyData>().com.id}");
  //       debugPrint("subscribed to topic");
  //     }
  //     debugPrint("token changed");
  //   });
  // }

  deleteNotification(int currentId) {
    notification.removeWhere((element) => element.id == currentId);
    notification = notification.reversed.toList();
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

  clearNotifications() {
    notification.clear();
    notifyListeners();
  }

  initializeNotification(BuildContext context) async {
    Provider.of<NotificationDataService>(context, listen: false)
        .notification
        .clear();
    if (await db.checkNotificationStatus()) {
      debugPrint("getting all notifications");
      final List<NotificationMessage> dbMessages =
          await db.getAllNotifications();
      for (int i = 0; i < dbMessages.length; i++) {
        if (!notification.contains(dbMessages[i])) {
          notification.add(dbMessages[i]);
        }
      }
      notification = notification.reversed.toList();
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

  // void getInitialNotification(BuildContext context) async {
  //   final initialNotification = await hawawi.Push.getInitialNotification();
  //   debugPrint("getInitialNotification: " + initialNotification.toString());
  //   if (initialNotification.toString().contains("اثبات حضور")) {
  //     debugPrint("YES IT CONTAINS !");
  //     showAttendanceCheckDialog(context);
  //   }
  // }

  void notificationPermessions() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    final NotificationSettings settings =
        await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint("User granted permession ${settings.authorizationStatus}");
  }

  bool finshed = false;
  // int counter = 0;
  // huaweiMessagingConfig(BuildContext context) async {
  //   hawawi.Push.onMessageReceivedStream.listen((_onMessageReceived) async {
  //     log("huawei message recieved ");
  //     // NotificationDataService dataService = NotificationDataService();
  //     // dataService.showAttendanceCheckDialog(context);
  //     final String data = _onMessageReceived.data;

  //     final decodedResponse = json.decode(data);
  //     debugPrint(decodedResponse["pushbody"]);
  //     if (decodedResponse["pushbody"]["category"] == "attend") {
  //       showAttendanceCheckDialog(context);
  //     }
  //     await db
  //         .insertNotification(
  //             NotificationMessage(
  //                 category: decodedResponse["pushbody"]["category"],
  //                 dateTime: DateTime.now().toString().substring(0, 10),
  //                 message: decodedResponse["pushbody"]["description"],
  //                 messageSeen: 0,
  //                 title: decodedResponse["pushbody"]["title"],
  //                 timeOfMessage: DateFormat('kk:mm:a').format(DateTime.now())),
  //             context)
  //         // .then((value) => counter = 0)
  //         .then((value) => addNotification(
  //             decodedResponse["pushbody"]["title"],
  //             decodedResponse["pushbody"]["description"],
  //             DateTime.now().toString().substring(0, 10),
  //             decodedResponse["pushbody"]["category"],
  //             DateFormat('kk:mm:a').format(DateTime.now()),
  //             value));

  //     player.play("notification.mp3");
  //   });
  // }

  static int semaphore = 0;
  addNotificationToListAndDB(RemoteMessage event, BuildContext context) async {
    try {
      log("adding notification to database");
      await db
          .insertNotification(
              NotificationMessage(
                  category: event.data["category"],
                  dateTime: DateTime.now().toString().substring(0, 10),
                  message: event.notification.body,
                  messageSeen: 0,
                  title: event.notification.title,
                  timeOfMessage: DateFormat('kk:mm:a').format(DateTime.now())),
              context)
          // .then((value) => counter = 0)
          .then((value) async => await addNotification(
              event.notification.title,
              event.notification.body,
              DateTime.now().toString().substring(0, 10),
              event.data["category"],
              DateFormat('kk:mm:a').format(DateTime.now()),
              value));
    } catch (e) {
      print(e);
    }
  }

  firebaseMessagingConfig() async {
    final BuildContext context = navigatorKey.currentState.overlay.context;
    FirebaseMessaging.onMessage.listen((event) async {
      if (semaphore != 0) {
        return;
      }
      semaphore = 1;
      Future.delayed(const Duration(seconds: 1)).then((_) => semaphore = 0);
      // counter++;
      // debugPrint(counter);
      log('revieved ${event.data['category']} notification');
      if (event.data["category"] == "internalMission") {
        debugPrint("revieved internalMission ");
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final List<String> userData = (prefs.getStringList('userData') ?? null);
        addNotificationToListAndDB(event, context);
        player.play("notification.mp3");
        await Provider.of<UserData>(context, listen: false)
            .loginPost(userData[0], userData[1], context, true)
            .then((value) => debugPrint('login successs'));
      } else if (event.data["category"] == "reloadData") {
        debugPrint("recieved reloadData");
        Provider.of<SiteShiftsData>(context, listen: false)
            .getAllSitesAndShifts(
                Provider.of<CompanyData>(context, listen: false).com.id,
                Provider.of<UserData>(context, listen: false).user.userToken);
      } else {
        // if (counter == 1) {
        if (event.data["category"] == "attend") {
          await showAttendanceCheckDialog(context);
          // }
          addNotificationToListAndDB(event, context);
          player.play("notification.mp3");
        } else {
          addNotificationToListAndDB(event, context);
          player.play("notification.mp3");
        }
      }
    });
  }

  saveNotificationToCache(RemoteMessage event, BuildContext context) async {
    await db.insertNotification(
        NotificationMessage(
          category: event.data["category"],
          dateTime: DateTime.now().toString().substring(0, 10),
          message: event.notification.body,
          messageSeen: 0,
          title: event.notification.title,
        ),
        context);
    player.play("notification.mp3");
  }

  showAttendanceCheckDialog(BuildContext context) {
    return showDialog(
      context: navigatorKey.currentState.overlay.context,
      barrierDismissible: false,
      builder: (context) {
        return StackedNotificaitonAlert(
          notificationTitle: "اثبات حضور",
          notificationContent: "برجاء اثبات حضورك قبل انتهاء الوقت المحدد",
          roundedButtonTitle: "اثبات",
          lottieAsset: "resources/notificationalarm.json",
          notificationToast: "تم اثبات الحضور بنجاح",
          showToast: true,
          callBackFun: () {},
          popWidget: false,
          isFromBackground: false,
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
