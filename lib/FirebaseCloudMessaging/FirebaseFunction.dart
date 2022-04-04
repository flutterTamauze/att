import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String serverToken =
    // ignore: lines_longer_than_80_chars
    'AAAAn_TIyyQ:APA91bFfj4S4VEA7ZU3zegTqeNwEODrGePKF7Wh-OsOeJCSb326VxWZ0OER7gV3irug0BJB4IXr_MNgkNtwpjeU58vVmQNByntX_hQDxD8bzFDC94txSITHBzXt22cTkRaq5B4VsrRmX';

final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
Future<bool> sendFcmMessage(
    {String title,
    String message,
    String category,
    String topicName,
    String userToken}) async {
  try {
    final String toParams = "/topics/" + topicName;
    debugPrint("user token $userToken");
    if (userToken == null) {
      debugPrint("sending to topic $toParams");
    }
    const url = 'https://fcm.googleapis.com/fcm/send';
    final header = {
      "Content-Type": "application/json",
      "Authorization": "key=$serverToken",
    };
    var request;

    request = {
      "notification": {
        "title": title,
        "body": message,
        "content_available": true,
        "text": message,
        "android_channel_id": "ChilangoNotifications",
        "sound": "your_sweet_sound.wav",
      },
      "data": {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        "title": "$title",
        "body": "$message",
        "category": "$category",
      },
      "priority": "high",
      "to": topicName == "" ? userToken : toParams
    };

//    "to": "$toParams",

    final client = new http.Client();
    final response = await client.post(Uri.parse(url),
        headers: header, body: json.encode(request));

    // Provider.of<UserData>(navigatorKey.currentState.overlay.context,
    //         listen: false)
    //     .addNotificationRequestID(DateTime.now().millisecond);
    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

Future<bool> sendFcmDataOnly(
    {String category, String topicName, String userToken}) async {
  try {
    final String toParams = "/topics/" + topicName;

    const url = 'https://fcm.googleapis.com/fcm/send';
    final header = {
      "Content-Type": "application/json",
      "Authorization": "key=$serverToken",
    };
    var request;
    if (Platform.isIOS) {
      request = {
        "data": {
          "category": "$category",
        },
        "priority": "high",
        "to": topicName == "" ? userToken : toParams
      };
    } else {
      request = {
        "notification": {},
        "data": {
          "category": "$category",
        },
        "priority": "high",
        "to": topicName == "" ? userToken : toParams
      };
    }

//    "to": "$toParams",
    final client = new http.Client();
    final response = await client.post(Uri.parse(url),
        headers: header, body: json.encode(request));
    return true;
  } catch (e) {
    print(e);
    return false;
  }
}
