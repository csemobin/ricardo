class DriverGetRatings {
  String? sId;
  double? rating;
  String? comment;
  List<String>? tags;
  String? createdAt;
  PassengerUserInfo? passengerUserInfo;

  DriverGetRatings(
      {this.sId,
        this.rating,
        this.comment,
        this.tags,
        this.createdAt,
        this.passengerUserInfo});




  DriverGetRatings.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    rating = (json['rating'] as num?)?.toDouble();
    comment = json['comment'];
    tags = json['tags'].cast<String>();
    createdAt = json['createdAt'];
    passengerUserInfo = json['passengerUserInfo'] != null
        ? new PassengerUserInfo.fromJson(json['passengerUserInfo'])
        : null;
  }
}

class PassengerUserInfo {
  String? name;
  String? email;
  String? phone;

  PassengerUserInfo({this.name, this.email, this.phone});

  PassengerUserInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
  }
}
