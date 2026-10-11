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
  PassengerUserImage? image;

  PassengerUserInfo({this.name, this.email, this.phone, this.image});

  PassengerUserInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    image = json['image'] != null
        ? PassengerUserImage.fromJson(json['image'])
        : null;
  }
}

class PassengerUserImage {
  String? filename;

  PassengerUserImage({this.filename});

  PassengerUserImage.fromJson(Map<String, dynamic> json) {
    filename = json['filename'];
  }
}
