class FutureShiftSchedule {
  int siteId, shiftId;
  String siteName, shiftName, startTime, endTime;
  FutureShiftSchedule(
      {this.endTime,
      this.shiftId,
      this.shiftName,
      this.siteId,
      this.siteName,
      this.startTime});

  factory FutureShiftSchedule.fromJson(json) {
    return FutureShiftSchedule(
        endTime: json[0]["shiftEntime"],
        shiftId: json[0]["shiftId"],
        shiftName: json[0]["shiftName"],
        siteId: json[0]["siteId"],
        siteName: json[0]["siteName"],
        startTime: json[0]["shiftStTime"]);
  }
}
