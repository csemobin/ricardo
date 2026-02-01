class RecentHistory {
  String? sId;
  UserId? userId;
  String? type;
  String? status;
  double? amount;
  String? currency;
  RideId? rideId;
  String? provider;
  String? title;
  String? description;
  Meta? meta;
  String? createdAt;
  String? updatedAt;
  String? withdrawRequestId;

  RecentHistory(
      {this.sId,
        this.userId,
        this.type,
        this.status,
        this.amount,
        this.currency,
        this.rideId,
        this.provider,
        this.title,
        this.description,
        this.meta,
        this.createdAt,
        this.updatedAt,
        this.withdrawRequestId});

  RecentHistory.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId =
    json['userId'] != null ? new UserId.fromJson(json['userId']) : null;
    type = json['type'];
    status = json['status'];
    amount = json['amount'];
    currency = json['currency'];
    rideId =
    json['rideId'] != null ? new RideId.fromJson(json['rideId']) : null;
    provider = json['provider'];
    title = json['title'];
    description = json['description'];
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    withdrawRequestId = json['withdrawRequestId'];
  }
}

class UserId {
  Location? location;
  String? sId;
  String? name;
  String? email;
  String? phone;
  Image? image;

  UserId(
      {this.location, this.sId, this.name, this.email, this.phone, this.image});

  UserId.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    image = json['image'] != null ? new Image.fromJson(json['image']) : null;
  }
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }
}

class Image {
  String? publicFolderPath;
  String? filename;
  String? createdAt;
  String? updatedAt;

  Image({this.publicFolderPath, this.filename, this.createdAt, this.updatedAt});

  Image.fromJson(Map<String, dynamic> json) {
    publicFolderPath = json['publicFolderPath'];
    filename = json['filename'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}

class RideId {
  String? sId;
  Location? pickupLocation;
  Location? destinationLocation;

  RideId({this.sId, this.pickupLocation, this.destinationLocation});

  RideId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    pickupLocation = json['pickupLocation'] != null
        ? new Location.fromJson(json['pickupLocation'])
        : null;
    destinationLocation = json['destinationLocation'] != null
        ? new Location.fromJson(json['destinationLocation'])
        : null;
  }
}

class Meta {
  double? baseFare;
  double? waitingMinutes;
  double? waitingFare;
  double? totalPayAmount;

  Meta(
      {this.baseFare,
        this.waitingMinutes,
        this.waitingFare,
        this.totalPayAmount});

  Meta.fromJson(Map<String, dynamic> json) {
    baseFare = json['baseFare'];
    waitingMinutes = json['waitingMinutes'];
    waitingFare = json['waitingFare'];
    totalPayAmount = json['totalPayAmount'];
  }
}
