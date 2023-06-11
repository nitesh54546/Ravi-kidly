// To parse this JSON data, do
//
//     final userDetails = userDetailsFromJson(jsonString);

class UserInfoModal {
  UserInfoModal(
      {this.id, this.name, this.mobile, this.active, this.schoolName});

  num? id;
  String? name;
  String? mobile;
  String? schoolName;
  String? active;
  num? subid;
  String? userId;
  String? subscriptionId;
  String? price;
  String? transactionId;
  DateTime? startDate;
  DateTime? endDate;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? subname;
  String? activities;
}
