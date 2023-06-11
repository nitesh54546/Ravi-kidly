import 'dart:convert';

List<SubscriptionMoal> SubscriptionMoalFromJson(String str) =>
    List<SubscriptionMoal>.from(
        json.decode(str).map((x) => SubscriptionMoal.fromJson(x)));

String SubscriptionMoalToJson(List<SubscriptionMoal> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SubscriptionMoal {
  SubscriptionMoal({
    this.id,
    this.duration,
    this.price,
    this.activities,
    this.name,
  });

  num? id;
  num? duration;
  num? price;
  num? activities;
  String? name;

  factory SubscriptionMoal.fromJson(Map<String, dynamic> json) =>
      SubscriptionMoal(
        id: json["id"],
        duration: json["duration"],
        price: json["price"],
        activities: json["activities"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "duration": duration,
        "price": price,
        "activities": activities,
        "name": name,
      };
}
