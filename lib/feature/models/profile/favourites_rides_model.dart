class FavouritesRiderModel{
  String? sId;
  String?driverId;
  String? driverName;
  String? driverPhone;
  DriverProfileImage? driverProfileImage;
  DriverLocation? driverLocation;
  int? driverRating;
  int? driverTotalRating;
  int? totalCompletedRides;
  String? vehicleName;
  String? vehiclePlateNumber;
  DriverProfileImage? vehicleImage;
  int? vehicleSeats;

  FavouritesRiderModel(
      {this.sId,
        this.driverId,
        this.driverName,
        this.driverPhone,
        this.driverProfileImage,
        this.driverLocation,
        this.driverRating,
        this.driverTotalRating,
        this.totalCompletedRides,
        this.vehicleName,
        this.vehiclePlateNumber,
        this.vehicleImage,
        this.vehicleSeats});

  FavouritesRiderModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    driverId = json['driverId'];
    driverName = json['driverName'];
    driverPhone = json['driverPhone'];
    driverProfileImage = json['driverProfileImage'] != null
        ? new DriverProfileImage.fromJson(json['driverProfileImage'])
        : null;
    driverLocation = json['driverLocation'] != null
        ? new DriverLocation.fromJson(json['driverLocation'])
        : null;
    driverRating = json['driverRating'];
    driverTotalRating = json['driverTotalRating'];
    totalCompletedRides = json['totalCompletedRides'];
    vehicleName = json['vehicleName'];
    vehiclePlateNumber = json['vehiclePlateNumber'];
    vehicleImage = json['vehicleImage'] != null
        ? new DriverProfileImage.fromJson(json['vehicleImage'])
        : null;
    vehicleSeats = json['vehicleSeats'];
  }
}

class DriverProfileImage {
  String? publicFolderPath;
  String? filename;
  String? createdAt;
  String? updatedAt;

  DriverProfileImage(
      {this.publicFolderPath, this.filename, this.createdAt, this.updatedAt});

  DriverProfileImage.fromJson(Map<String, dynamic> json) {
    publicFolderPath = json['publicFolderPath'];
    filename = json['filename'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}

class DriverLocation {
  String? type;
  List<double>? coordinates;

  DriverLocation({this.type, this.coordinates});

  DriverLocation.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }
}
