class TodayUserReport {
  String attend, leave;
  int lateTime;
  TodayUserReport({this.attend, this.lateTime, this.leave});

  factory TodayUserReport.fromJson(json) {
    return TodayUserReport(
        attend: json["attendTime"],
        lateTime: json['lateTime'],
        leave: json["leaveTime"]);
  }
}
