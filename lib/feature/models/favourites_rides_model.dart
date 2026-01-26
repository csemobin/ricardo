class FavouritesRiderModel {
  String? sId;
  String? user;
  Driver? driver;
  String? createdAt;
  String? updatedAt;

  FavouritesRiderModel({
    this.sId,
    this.user,
    this.driver,
    this.createdAt,
    this.updatedAt,
  });

  FavouritesRiderModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'];
    driver = json['driver'] != null ? Driver.fromJson(json['driver']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}

class Driver {
  Location? location;
  String? sId;
  String? name;
  String? email;
  String? gender;
  String? phone;
  num? wallet; // Can be int or double
  String? address;
  ImageData? image;
  String? isActive;
  String? role;
  bool? isDeleted;
  bool? isVerified;
  String? createdAt;
  String? updatedAt;
  String? aboutMe;
  String? dob;
  bool? isProfileCompleted;

  Driver({
    this.location,
    this.sId,
    this.name,
    this.email,
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
    this.aboutMe,
    this.dob,
    this.isProfileCompleted,
  });

  Driver.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null ? Location.fromJson(json['location']) : null;
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    gender = json['gender'];
    phone = json['phone'];
    wallet = json['wallet']; // Handles both int and double
    address = json['address'];
    image = json['image'] != null ? ImageData.fromJson(json['image']) : null;
    isActive = json['isActive'];
    role = json['role'];
    isDeleted = json['isDeleted'];
    isVerified = json['isVerified'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    aboutMe = json['aboutMe'];
    dob = json['dob'];
    isProfileCompleted = json['isProfileCompleted'];
  }
}

class Location {
  String? type;
  List<num>? coordinates; // Using num to handle both int and double

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['coordinates'] != null) {
      coordinates = List<num>.from(json['coordinates']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}

class ImageData {
  String? publicFolderPath;
  String? filename;
  String? createdAt;
  String? updatedAt;

  ImageData({
    this.publicFolderPath,
    this.filename,
    this.createdAt,
    this.updatedAt,
  });

  ImageData.fromJson(Map<String, dynamic> json) {
    publicFolderPath = json['publicFolderPath'];
    filename = json['filename'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['publicFolderPath'] = publicFolderPath;
    data['filename'] = filename;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}