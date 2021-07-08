import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_users/services/NotificationsRadioButton.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';

class UserNotifications extends StatefulWidget {
  @override
  _UserNotificationsState createState() => _UserNotificationsState();
}

class _UserNotificationsState extends State<UserNotifications> {
  // Default Radio Button Item
  String radioItem = 'Sweet Sound';
  AudioCache player = AudioCache();
  // Group Value for Radio Button.
  int id = 1;
  List<NotificationsRadio> notifList = [
    NotificationsRadio(
        notifName: "Sweet Sound", id: 1, notifSound: "your_sweet_sound.wav"),
    NotificationsRadio(
        notifName: "Sweet Sound2", id: 2, notifSound: "your_sweet_sound.wav2"),
    NotificationsRadio(
        notifName: "Sweet Sound3", id: 3, notifSound: "your_sweet_sound.wav3"),
    NotificationsRadio(
        notifName: "Sweet Sound4", id: 4, notifSound: "your_sweet_sound.wav4"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Header(
              nav: false,
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmallDirectoriesHeader(
                      Container(
                        child: Lottie.asset("resources/bellnotification.json",
                            repeat: false),
                      ),
                      "الأشعارات"),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: EdgeInsets.only(right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "النغمة",
                      style: TextStyle(fontSize: 18),
                    ),
                    Divider()
                  ],
                ),
              ),
            ),
            Expanded(
                child: ListView.builder(
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(notifList[index].notifName),
                          Radio(
                              activeColor: Colors.orange,
                              value: notifList[index].id,
                              groupValue: id,
                              onChanged: (val) {
                                player.play(notifList[index].notifSound);
                                setState(() {
                                  id = val;
                                });
                              })
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 0.5,
                        color: Colors.grey,
                      )
                    ],
                  ),
                );
              },
              itemCount: notifList.length,
            )),
          ],
        ),
      ),
    );
  }
}
