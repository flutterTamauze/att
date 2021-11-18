class AttendProofModel {
  String username;
  bool isAttended;
  String userId;
  int id;
  String time;
  AttendProofModel(
      {this.isAttended, this.username, this.time, this.userId, this.id});
  factory AttendProofModel.fromJson(dynamic json) {
    return AttendProofModel(
        isAttended: json["isInLocation"],
        username: json["userName1"],
        id: json["id"],
        userId: json["userId"],
        time: json["startTime"]);
  }
}
