import 'dart:convert';

List<RhymsModal> rhymsModalFromJson(String str) =>
    List<RhymsModal>.from(json.decode(str).map((x) => RhymsModal.fromJson(x)));

String rhymsModalToJson(List<RhymsModal> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RhymsModal {
  RhymsModal({
    this.id,
    this.teacherId,
    this.name,
    this.image,
    this.url,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  num? id;
  num? teacherId;
  String? name;
  String? image;
  String? url;
  dynamic description;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory RhymsModal.fromJson(Map<String, dynamic> json) => RhymsModal(
        id: json["id"],
        teacherId: json["teacher_id"],
        name: json["name"],
        image: json["image"],
        url: json["url"],
        description: json["description"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "teacher_id": teacherId,
        "name": name,
        "image": image,
        "url": url,
        "description": description,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
      };
}
