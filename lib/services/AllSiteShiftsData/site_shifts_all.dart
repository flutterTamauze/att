class SiteShiftsModel {
  int siteId;
  String siteName;
  List<Shifts> shifts;
  SiteShiftsModel({this.siteId, this.siteName, this.shifts});
  static List<Shifts> parseShifts(itemsJson) {
    var list = itemsJson["shifts"] as List;
    List<Shifts> itemsList = [];
    if (list.isNotEmpty) {
      itemsList = list.map((data) => Shifts.fromJson(data)).toList();
    }

    return itemsList;
  }

  factory SiteShiftsModel.fromJson(Map<String, dynamic> json) {
    return SiteShiftsModel(
        siteId: json['siteId'],
        siteName: json['siteName'],
        shifts: parseShifts(json) ?? []);
  }
}

class Shifts {
  int shiftId;
  String shiftName;
  String shiftStTime;
  String shiftEntime;

  Shifts({this.shiftId, this.shiftName, this.shiftStTime, this.shiftEntime});

  Shifts.fromJson(Map<String, dynamic> json) {
    shiftId = json['shiftId'];
    shiftName = json['shiftName'];
    shiftStTime = json['shiftStTime'];
    shiftEntime = json['shiftEntime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['shiftId'] = this.shiftId;
    data['shiftName'] = this.shiftName;
    data['shiftStTime'] = this.shiftStTime;
    data['shiftEntime'] = this.shiftEntime;
    return data;
  }
}
