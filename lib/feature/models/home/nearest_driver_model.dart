class NearestDrivers {
  String? sId;
  String? name;
  String? email;
  String? phone;
  bool? isFavorite;
  Location? location;
  Vehicle? vehicle;
  String? image;
  double? rating;
  int? trips;
  int? totalRatings;

  NearestDrivers({
    this.sId,
    this.name,
    this.email,
    this.phone,
    this.isFavorite,
    this.location,
    this.vehicle,
    this.image,
    this.rating,
    this.trips,
    this.totalRatings,
  });

  NearestDrivers.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    isFavorite = json['isFavorite'];
    location = json['location'] != null
        ? Location.fromJson(json['location'])
        : null;
    vehicle =
    json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null;
    image = json['image'];
    rating = (json['rating'] as num?)?.toDouble();
    trips = (json['trips'] as num?)?.toInt();
    totalRatings = (json['totalRatings'] as num?)?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['isFavorite'] = isFavorite;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    if (vehicle != null) {
      data['vehicle'] = vehicle!.toJson();
    }
    data['image'] = image;
    data['rating'] = rating;
    data['trips'] = trips;
    data['totalRatings'] = totalRatings;
    return data;
  }
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({
    this.type,
    this.coordinates,
  });

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'] != null
        ? (json['coordinates'] as List)
        .map((e) => (e as num).toDouble())
        .toList()
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}

class Vehicle {
  String? sId;
  String? driverId;
  String? carName;
  String? carPlateNumber;
  CarImage? carImage;
  CarImage? registrationCardImage;
  CarImage? numberPlateImage;
  String? carRegistrationDate;
  int? numberOfSeat;
  String? vehicleType;
  bool? isReviewed;
  bool? isUploaded;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;

  Vehicle({
    this.sId,
    this.driverId,
    this.carName,
    this.carPlateNumber,
    this.carImage,
    this.registrationCardImage,
    this.numberPlateImage,
    this.carRegistrationDate,
    this.numberOfSeat,
    this.vehicleType,
    this.isReviewed,
    this.isUploaded,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  Vehicle.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    driverId = json['driverId'];
    carName = json['carName'];
    carPlateNumber = json['carPlateNumber'];
    carImage = json['carImage'] != null
        ? CarImage.fromJson(json['carImage'])
        : null;
    registrationCardImage = json['registrationCardImage'] != null
        ? CarImage.fromJson(json['registrationCardImage'])
        : null;
    numberPlateImage = json['numberPlateImage'] != null
        ? CarImage.fromJson(json['numberPlateImage'])
        : null;
    carRegistrationDate = json['carRegistrationDate'];
    numberOfSeat = (json['numberOfSeat'] as num?)?.toInt();
    vehicleType = json['vehicleType'];
    isReviewed = json['isReviewed'];
    isUploaded = json['isUploaded'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['driverId'] = driverId;
    data['carName'] = carName;
    data['carPlateNumber'] = carPlateNumber;
    if (carImage != null) {
      data['carImage'] = carImage!.toJson();
    }
    if (registrationCardImage != null) {
      data['registrationCardImage'] = registrationCardImage!.toJson();
    }
    if (numberPlateImage != null) {
      data['numberPlateImage'] = numberPlateImage!.toJson();
    }
    data['carRegistrationDate'] = carRegistrationDate;
    data['numberOfSeat'] = numberOfSeat;
    data['vehicleType'] = vehicleType;
    data['isReviewed'] = isReviewed;
    data['isUploaded'] = isUploaded;
    data['isDeleted'] = isDeleted;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class CarImage {
  String? publicFolderPath;
  String? filename;
  String? createdAt;
  String? updatedAt;

  CarImage({
    this.publicFolderPath,
    this.filename,
    this.createdAt,
    this.updatedAt,
  });

  CarImage.fromJson(Map<String, dynamic> json) {
    publicFolderPath = json['publicFolderPath'];
    filename = json['filename'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['publicFolderPath'] = publicFolderPath;
    data['filename'] = filename;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}