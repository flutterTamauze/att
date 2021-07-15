class NotificationMessage {
  String title;
  String message;
  String dateTime;
  String category;
  int id;
  int messageSeen = 0;
  NotificationMessage(
      {this.dateTime,
      this.message,
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

    this.id = map["id"];
  }
  Map<String, dynamic> toMap() {
    return {
      "title": this.title,
      "category": this.category,
      "date": this.dateTime,
      "message": this.message,
      "seen": this.messageSeen,
    };
  }
}
