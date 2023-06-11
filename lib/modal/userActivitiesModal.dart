// To parse this JSON data, do
//
//     final userActivities = userActivitiesFromJson(jsonString);

import 'dart:convert';

List<UserActivitiesModal> userActivitiesFromJson(String str) =>
    List<UserActivitiesModal>.from(
        json.decode(str).map((x) => UserActivitiesModal.fromJson(x)));

String userActivitiesToJson(List<UserActivitiesModal> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserActivitiesModal {
  UserActivitiesModal({
    this.id,
    this.name,
    this.image,
    this.url,
    this.description,
    this.isLocked,
  });

  num? id;
  String? name;
  String? image;
  String? url;
  String? description;
  num? isLocked;

  factory UserActivitiesModal.fromJson(Map<String, dynamic> json) =>
      UserActivitiesModal(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        url: json["url"],
        description: json["description"],
        isLocked: json["is_locked"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "url": url,
        "description": description,
        "is_locked": isLocked,
      };
}

enum Description { DESCRIPTION }

final descriptionValues = EnumValues({"Description": Description.DESCRIPTION});

enum Name { ACTIVITY_1 }

final nameValues = EnumValues({"Activity 1": Name.ACTIVITY_1});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap!;
  }
}
