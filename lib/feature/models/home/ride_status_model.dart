class RideStatusModel {
  bool? acceptRide;
  bool? ongoingRide;
  bool? arrivingRide;
  bool? driverCancel;
  bool? passengerCancel;
  bool? completeRide;

  Ride? ride;
  User? passenger;
  User? driver;
  DriverCar? driverCar;

  RideStatusModel({
    this.acceptRide,
    this.ongoingRide,
    this.arrivingRide,
    this.driverCancel,
    this.passengerCancel,
    this.completeRide,
    this.ride,
    this.passenger,
    this.driver,
    this.driverCar,
  });

  RideStatusModel.fromJson(Map<String, dynamic> json) {
    acceptRide = json['acceptRide'];
    ongoingRide = json['ongoingRide'];
    arrivingRide = json['arrivingRide'];
    driverCancel = json['driverCancel'];
    passengerCancel = json['passengerCancel'];
    completeRide = json['completeRide'];

    ride = json['ride'] is Map ? Ride.fromJson(json['ride']) : null;
    passenger = json['passenger'] is Map ? User.fromJson(json['passenger']) : null;
    driver = json['driver'] is Map ? User.fromJson(json['driver']) : null;
    driverCar = json['driverCar'] is Map ? DriverCar.fromJson(json['driverCar']) : null;
  }
}

class Ride {
  String? id;
  User? passenger;
  User? driver;

  String? pickupAddress;
  String? destinationAddress;

  Location? pickupLocation;
  Location? destinationLocation;
  Location? driverAcceptedLocation;

  int? destinationMeters;
  double? fare;

  String? status;

  String? acceptedAt;
  String? completeAt;

  Ride.fromJson(Map<String, dynamic> json) {
    id = json['_id'];

    passenger = json['passenger'] is Map ? User.fromJson(json['passenger']) : null;
    driver = json['driver'] is Map ? User.fromJson(json['driver']) : null;

    pickupAddress = json['pickupAddress'];
    destinationAddress = json['destinationAddress'];

    pickupLocation = json['pickupLocation'] is Map
        ? Location.fromJson(json['pickupLocation'])
        : null;

    destinationLocation = json['destinationLocation'] is Map
        ? Location.fromJson(json['destinationLocation'])
        : null;

    driverAcceptedLocation = json['driverAcceptedLocation'] is Map
        ? Location.fromJson(json['driverAcceptedLocation'])
        : null;

    destinationMeters = json['destinationMeters'];
    fare = (json['fare'] as num?)?.toDouble();

    status = json['status'];

    acceptedAt = json['acceptedAt'];
    completeAt = json['completeAt'];
  }
}

class User {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? role;
  String? gender;
  double? wallet;
  String? address;

  bool? isVerified;
  bool? isProfileCompleted;

  Location? location;
  AppImage? image;

  User.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    role = json['role'];
    gender = json['gender'];
    wallet = (json['wallet'] as num?)?.toDouble();
    address = json['address'];

    isVerified = json['isVerified'];
    isProfileCompleted = json['isProfileCompleted'];

    location = json['location'] is Map
        ? Location.fromJson(json['location'])
        : null;

    image = json['image'] is Map
        ? AppImage.fromJson(json['image'])
        : null;
  }
}

class DriverCar {
  String? id;
  String? driverId;
  String? carName;
  String? carPlateNumber;

  int? numberOfSeat;
  String? vehicleType;

  AppImage? carImage;
  AppImage? registrationCardImage;
  AppImage? numberPlateImage;

  DriverCar.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    driverId = json['driverId'];
    carName = json['carName'];
    carPlateNumber = json['carPlateNumber'];

    numberOfSeat = json['numberOfSeat'];
    vehicleType = json['vehicleType'];

    carImage = json['carImage'] is Map
        ? AppImage.fromJson(json['carImage'])
        : null;

    registrationCardImage = json['registrationCardImage'] is Map
        ? AppImage.fromJson(json['registrationCardImage'])
        : null;

    numberPlateImage = json['numberPlateImage'] is Map
        ? AppImage.fromJson(json['numberPlateImage'])
        : null;
  }
}

class Location {
  String? type;
  List<double>? coordinates;

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];

    coordinates = (json['coordinates'] as List?)
        ?.map((e) => (e as num).toDouble())
        .toList();
  }
}

class AppImage {
  String? publicFolderPath;
  String? filename;
  String? createdAt;
  String? updatedAt;

  AppImage.fromJson(Map<String, dynamic> json) {
    publicFolderPath = json['publicFolderPath'];
    filename = json['filename'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}