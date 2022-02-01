import 'dart:convert';

class NotificationMessage {
  String title;
  String message;
  String dateTime;
  String category;
  String timeOfMessage;
  int id;
  int messageSeen = 0;
  NotificationMessage(
      {this.dateTime,
      this.message,
      this.timeOfMessage,
      this.title,
      this.messageSeen,
      this.id,
      this.category});

  NotificationMessage.fromMap(Map<String, dynamic> map) {
    this.title = map["title"];
    this.category = map["category"];
    this.dateTime = map["date"];
    this.message = map["message"];
    this.messageSeen = map["seen"];
    this.timeOfMessage = map["timeMessage"];
    this.id = map["id"];
  }
  Map<String, dynamic> toMap() {
    return {
      "title": this.title,
      "category": this.category,
      "date": this.dateTime,
      "timeMessage": this.timeOfMessage,
      "message": this.message,
      "seen": this.messageSeen,
    };
  }

  static Map<String, dynamic> toMsgMap(NotificationMessage msgs) => {
        "title": msgs.title,
        "category": msgs.category,
        "date": msgs.dateTime,
        "timeMessage": msgs.timeOfMessage,
        "message": msgs.message,
        "seen": msgs.messageSeen,
      };

  static String encode(List<NotificationMessage> msgs) => json.encode(
        msgs.map<Map<String, dynamic>>((music) => toMsgMap(music)).toList(),
      );

  static List<NotificationMessage> decode(String msgs) =>
      (json.decode(msgs) as List<dynamic>)
          .map<NotificationMessage>((item) => NotificationMessage.fromMap(item))
          .toList();
}
