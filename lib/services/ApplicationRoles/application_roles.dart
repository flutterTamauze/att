class AppRoles {
  String id;
  String name, normalizedName;
  AppRoles({this.id, this.name, this.normalizedName});
  factory AppRoles.fromJson(dynamic json) {
    return AppRoles(
        id: json['id'],
        name: json["name"],
        normalizedName: json["normalizedName"]);
  }
}
