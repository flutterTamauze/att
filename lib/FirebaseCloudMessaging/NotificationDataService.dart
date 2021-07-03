import 'package:audioplayers/audio_cache.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';

class NotificationDataService with ChangeNotifier {
  bool showNotificationDot = false;
  String notificationTitle = "";
  setNotificationTitle(String newTitle) {
    notificationTitle = newTitle;
    notifyListeners();
    print(newTitle);
  }
  // setNotificationList(List<NotificationMessage> notifyList) {
  //   notification = notifyList;
  // }

  firebaseMessagingConfig(BuildContext context) async {
    FirebaseMessaging.onBackgroundMessage((message) {
      print("current msg = $notificationTitle");
      print("Handling a background message: ${message.notification.body}");
      print("Handling a background message: ${message.notification.title}");
      setNotificationTitle(message.notification.body);
      print("current msg after = $notificationTitle");
      return;
    });
    FirebaseMessaging.onMessage.listen((event) {
      print(event.notification.body);
      print(event.notification.title);
    });
  }
}
// (
//         onBackgroundMessage: myBackgroundMessageHandler,
//         onMessage: (Map<String, dynamic> message) async {
//           print("onMesage:");
//           var notificationMsg = message["notification"];
//           print(message);
//         },
//         onLaunch: (Map<String, dynamic> message) async {
//           print("onLaunch:$message");
//         },
//         onResume: (Map<String, dynamic> message) async {
//           var dataMsg = message["data"];
//           print("onResume:$message");
//           // await Provider.of<NotificationDataService>(context, listen: false)
//           //     .addNotification(dataMsg["title"], dataMsg["body"],
//           //         DateTime.now().toString().substring(0, 10), dataMsg["category"]);

//           // switch (message["data"]["category"]) {
//           //   case "HealthCare":
//           //     {
//           //       BlocProvider.of<NavigationBloc>(context)
//           //           .add(NavigationEvents.HealthCareClickedEvent);

//           //       break;
//           //     }
//           //   case "HegOmra":
//           //     {
//           //       BlocProvider.of<NavigationBloc>(context)
//           //           .add(NavigationEvents.HegAndOmraClickedEvent);
//           //       break;
//           //     }
//           //   case "":
//           //     {
//           //       Navigator.pop(context);
//           //       break;
//           //     }
//           //   default:
//           //     {
//           //       BlocProvider.of<NavigationBloc>(context)
//           //           .add(NavigationEvents.HomePageClickedEvent);
//           //     }
//           //     break;
//           // }
//         });
//   }