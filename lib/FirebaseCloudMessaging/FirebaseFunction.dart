import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final String serverToken =
    'AAAAn_TIyyQ:APA91bFfj4S4VEA7ZU3zegTqeNwEODrGePKF7Wh-OsOeJCSb326VxWZ0OER7gV3irug0BJB4IXr_MNgkNtwpjeU58vVmQNByntX_hQDxD8bzFDC94txSITHBzXt22cTkRaq5B4VsrRmX';

final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
Future<bool> sendFcmMessage(
    {String title, String message, String category}) async {
  try {
    String toParams = "/topics/" + 'attendChilango';

    // print(await firebaseMessaging.getToken());
    // firebaseMessaging.unsubscribeFromTopic("nekaba");
    // print(toParams);
    var url = 'https://fcm.googleapis.com/fcm/send';
    var header = {
      "Content-Type": "application/json",
      "Authorization": "key=$serverToken",
    };
    var request = {
      "notification": {
        "title": title,
        "body": message,
        "text": message,
        // "image": "default",
        "android_channel_id": "ChilangoNotifications",
        "sound": "your_sweet_sound.wav",
        "color": "#f4a802",
      },
      "data": {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        "title": "$title",
        "body": "$message",
        "category": "$category",
      },
      "priority": "high",
      "to": toParams
    };
//    "to": "$toParams",
    var client = new http.Client();
    var response =
        await client.post(url, headers: header, body: json.encode(request));
    print(response.body);
    print(response.statusCode);
    return true;
  } catch (e) {
    print(e);
    return false;
  }
}
