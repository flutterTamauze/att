import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final String serverToken =
    'AAAAqlkCp6U:APA91bFsNmqiPSq_iLMFw0IvtFWR0oRE0NSjyH5sIVFKU9Ev_o9gBpbg4rMREfRBLMH1nbL5TidqVucBbgrHu8qheRu2TvSBFRPNaNb-lwKKLGRU1vTW_p4VQqoE5IPNRgUakYIfHMwC';

final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
Future<bool> sendFcmMessage(
    {String title, String message, String category}) async {
  try {
    String toParams = "/topics/" + 'nekaba';
    // await firebaseMessaging.subscribeToTopic("nekaba");
    // print(await firebaseMessaging.getToken());
    // firebaseMessaging.unsubscribeFromTopic("nekaba");
    print(toParams);
    var url = 'https://fcm.googleapis.com/fcm/send';
    var header = {
      "Content-Type": "application/json",
      "Authorization": "key=$serverToken",
    };
    var request = {
      "notification": {
        "title": title,
        "text": message,
        "image": "https://cdn.countryflags.com/thumbs/egypt/flag-400.png",
        "sound": "default",
        "color": "#000000",
      },
      "data": {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        "title": "$title",
        "body": "$message",
        "category": "$category",
        "status": "done",
      },
      "priority": "high",
      "to": await firebaseMessaging.getToken(),
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
