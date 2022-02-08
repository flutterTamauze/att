class CompanySites {
  int siteID;
  String siteName;
  List<ShiftsSites> shiftsList;
  CompanySites({
    this.shiftsList,
    this.siteID,
    this.siteName,
  });
  factory CompanySites.fromJson(dynamic json) {
    return CompanySites(
        siteID: json["siteId"],
        shiftsList: parseItems(json),
        siteName: json["siteName"]);
  }
  static List<ShiftsSites> parseItems(itemsJson) {
    // var list = itemsJson["goods"] as List;
    final list = itemsJson["shifts"] as List;
    final List<ShiftsSites> itemsList =
        list.map((data) => ShiftsSites.fromJson(data)).toList();
    return itemsList;
  }
}

class ShiftsSites {
  int shifID;
  String shiftName;
  ShiftsSites({this.shifID, this.shiftName});
  factory ShiftsSites.fromJson(dynamic json) {
    return ShiftsSites(shifID: json["shiftId"], shiftName: json["shiftName"]);
  }
}
