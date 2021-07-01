import 'package:audioplayers/audio_cache.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class NotificationDataService with ChangeNotifier {
  bool showNotificationDot = false;
  // setNotificationList(List<NotificationMessage> notifyList) {
  //   notification = notifyList;
  // }

  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  firebaseMessagingConfig(BuildContext context) async {
    AudioCache player = AudioCache(prefix: "resources/audios/");
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print("onMesage:");
      var notificationMsg = message["notification"];
      print(message);
    }, onLaunch: (Map<String, dynamic> message) async {
      print("onLaunch:$message");
    }, onResume: (Map<String, dynamic> message) async {
      var dataMsg = message["data"];
      print("onResume:$message");
      // await Provider.of<NotificationDataService>(context, listen: false)
      //     .addNotification(dataMsg["title"], dataMsg["body"],
      //         DateTime.now().toString().substring(0, 10), dataMsg["category"]);

      // switch (message["data"]["category"]) {
      //   case "HealthCare":
      //     {
      //       BlocProvider.of<NavigationBloc>(context)
      //           .add(NavigationEvents.HealthCareClickedEvent);

      //       break;
      //     }
      //   case "HegOmra":
      //     {
      //       BlocProvider.of<NavigationBloc>(context)
      //           .add(NavigationEvents.HegAndOmraClickedEvent);
      //       break;
      //     }
      //   case "":
      //     {
      //       Navigator.pop(context);
      //       break;
      //     }
      //   default:
      //     {
      //       BlocProvider.of<NavigationBloc>(context)
      //           .add(NavigationEvents.HomePageClickedEvent);
      //     }
      //     break;
      // }
    });
  }
}
