class UserModel {
  UserProfile? userProfile;
  DriverProfile? driverProfile;

  UserModel({this.userProfile, this.driverProfile});

  UserModel.fromJson(Map<String, dynamic> json) {
    userProfile = json['userProfile'] != null
        ? UserProfile.fromJson(json['userProfile'])
        : null;
    driverProfile = json['driverProfile'] != null
        ? DriverProfile.fromJson(json['driverProfile'])
        : null;
  }

  // ✅ Added toJson
  Map<String, dynamic> toJson() {
    return {
      'userProfile': userProfile?.toJson(),
      'driverProfile': driverProfile?.toJson(),
    };
  }
}

class UserProfile {
  Location? location;
  bool? isProfileCompleted;
  String? sId;
  String? name;
  String? email;
  String? password;
  String? gender;
  String? phone;
  double? wallet;
  String? address;
  Image? image;
  String? isActive;
  String? role;
  bool? isDeleted;
  bool? isVerified;
  String? createdAt;
  String? updatedAt;

  UserProfile({
    this.location,
    this.isProfileCompleted,
    this.sId,
    this.name,
    this.email,
    this.password,
    this.gender,
    this.phone,
    this.wallet,
    this.address,
    this.image,
    this.isActive,
    this.role,
    this.isDeleted,
    this.isVerified,
    this.createdAt,
    this.updatedAt,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? Location.fromJson(json['location'])
        : null;
    isProfileCompleted = json['isProfileCompleted'];
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    gender = json['gender'];
    phone = json['phone'];
    wallet = json['wallet']?.toDouble();
    address = json['address'];
    image = json['image'] != null ? Image.fromJson(json['image']) : null;
    isActive = json['isActive'];
    role = json['role'];
    isDeleted = json['isDeleted'];
    isVerified = json['isVerified'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  // ✅ Added toJson
  Map<String, dynamic> toJson() {
    return {
      'location': location?.toJson(),
      'isProfileCompleted': isProfileCompleted,
      '_id': sId,
      'name': name,
      'email': email,
      'password': password,
      'gender': gender,
      'phone': phone,
      'wallet': wallet,
      'address': address,
      'image': image?.toJson(),
      'isActive': isActive,
      'role': role,
      'isDeleted': isDeleted,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'] != null
        ? List<double>.from(json['coordinates'].map((x) => x.toDouble()))
        : null;
  }

  // ✅ Added toJson
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}

class Image {
  String? publicFolderPath;
  String? filename;
  String? createdAt;
  String? updatedAt;

  Image({
    this.publicFolderPath,
    this.filename,
    this.createdAt,
    this.updatedAt,
  });

  Image.fromJson(Map<String, dynamic> json) {
    publicFolderPath = json['publicFolderPath'];
    filename = json['filename'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  // ✅ Added toJson
  Map<String, dynamic> toJson() {
    return {
      'publicFolderPath': publicFolderPath,
      'filename': filename,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class DriverProfile {
  String? sId;
  String? userId;
  String? approvalStatus;
  bool? isApproved;
  bool? licenseUploaded;
  bool? vehicleDataUploaded;
  int? pricePerMile;
  bool? isOnline;
  bool? isBusy;
  double? ratingAverage;
  int? totalRatings;
  int? totalCompletedRides;
  int? cancellationRate;
  String? createdAt;
  String? updatedAt;

  DriverProfile({
    this.sId,
    this.userId,
    this.approvalStatus,
    this.isApproved,
    this.licenseUploaded,
    this.vehicleDataUploaded,
    this.pricePerMile,
    this.isOnline,
    this.isBusy,
    this.ratingAverage,
    this.totalRatings,
    this.totalCompletedRides,
    this.cancellationRate,
    this.createdAt,
    this.updatedAt,
  });

  DriverProfile.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    approvalStatus = json['approvalStatus'];
    isApproved = json['isApproved'];
    licenseUploaded = json['licenseUploaded'];
    vehicleDataUploaded = json['vehicleDataUploaded'];
    pricePerMile = json['pricePerMile'];
    isOnline = json['isOnline'];
    isBusy = json['isBusy'];
    ratingAverage = json['ratingAverage']?.toDouble();
    totalRatings = json['totalRatings'];
    totalCompletedRides = json['totalCompletedRides'];
    cancellationRate = json['cancellationRate'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  // ✅ Added toJson
  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'userId': userId,
      'approvalStatus': approvalStatus,
      'isApproved': isApproved,
      'licenseUploaded': licenseUploaded,
      'vehicleDataUploaded': vehicleDataUploaded,
      'pricePerMile': pricePerMile,
      'isOnline': isOnline,
      'isBusy': isBusy,
      'ratingAverage': ratingAverage,
      'totalRatings': totalRatings,
      'totalCompletedRides': totalCompletedRides,
      'cancellationRate': cancellationRate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}