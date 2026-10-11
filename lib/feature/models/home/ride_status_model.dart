class RideStatusModel {
  bool? acceptRide;
  bool? ongoingRide;
  bool? arrivingRide;
  bool? driverCancel;
  bool? passengerCancel;
  bool? completeRide;
  bool? startRide;
  Ride? ride;
  Passenger? passenger;
  Driver? driver;
  DriverCar? driverCar;

  RideStatusModel({
    this.acceptRide,
    this.ongoingRide,
    this.arrivingRide,
    this.driverCancel,
    this.passengerCancel,
    this.completeRide,
    this.startRide,
    this.ride,
    this.passenger,
    this.driver,
    this.driverCar,
  });

  factory RideStatusModel.fromJson(Map<String, dynamic> json) {
    return RideStatusModel(
      acceptRide: json['acceptRide'],
      ongoingRide: json['ongoingRide'],
      arrivingRide: json['arrivingRide'],
      driverCancel: json['driverCancel'],
      startRide: json['startRide'] ?? json['rideStart'],
      passengerCancel: json['passengerCancel'],
      completeRide: json['completeRide'],
      ride: json['ride'] != null ? Ride.fromJson(json['ride']) : null,
      passenger: _passengerFromDynamic(json['passenger']),
      driver: _driverFromDynamic(json['driver']),
      driverCar: json['driverCar'] != null
          ? DriverCar.fromJson(json['driverCar'])
          : null,
    );
  }
}

class Ride {
  String? id;
  Passenger? passenger;
  Passenger? driver;
  String? pickupAddress;
  String? destinationAddress;
  Location? pickupLocation;
  Location? destinationLocation;
  int? destinationMeters;
  double? fare;
  dynamic note;
  String? status;
  int? waitingTime;
  int? waitingTimeFare;
  dynamic cancelledBy;
  dynamic cancellationReason;
  int? cancellationFine;
  dynamic reviewId;
  double? totalPayAmount;
  String? acceptedAt;
  dynamic completeAt;
  dynamic cancelledAt;
  String? searchStartedAt;
  int? searchRadiusIndex;
  String? lastSearchAt;
  List<String>? notifiedDriverIds;
  String? createdAt;
  String? updatedAt;
  Location? driverAcceptedLocation;

  Ride({
    this.id,
    this.passenger,
    this.driver,
    this.pickupAddress,
    this.destinationAddress,
    this.pickupLocation,
    this.destinationLocation,
    this.destinationMeters,
    this.fare,
    this.note,
    this.status,
    this.waitingTime,
    this.waitingTimeFare,
    this.cancelledBy,
    this.cancellationReason,
    this.cancellationFine,
    this.reviewId,
    this.totalPayAmount,
    this.acceptedAt,
    this.completeAt,
    this.cancelledAt,
    this.searchStartedAt,
    this.searchRadiusIndex,
    this.lastSearchAt,
    this.notifiedDriverIds,
    this.createdAt,
    this.updatedAt,
    this.driverAcceptedLocation,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['_id'],
      passenger: _passengerFromDynamic(json['passenger']),
      driver: _passengerFromDynamic(json['driver']),
      pickupAddress: json['pickupAddress'],
      destinationAddress: json['destinationAddress'],
      pickupLocation: json['pickupLocation'] != null
          ? Location.fromJson(json['pickupLocation'])
          : null,
      destinationLocation: json['destinationLocation'] != null
          ? Location.fromJson(json['destinationLocation'])
          : null,
      destinationMeters: _toInt(json['destinationMeters']),
      fare: _toDouble(json['fare']),
      note: json['note'],
      status: json['status'],
      waitingTime: _toInt(json['waitingTime']),
      waitingTimeFare: _toInt(json['waitingTimeFare']),
      cancelledBy: json['cancelledBy'],
      cancellationReason: json['cancellationReason'],
      cancellationFine: _toInt(json['cancellationFine']),
      reviewId: json['reviewId'],
      totalPayAmount: _toDouble(json['totalPayAmount']),
      acceptedAt: json['acceptedAt'],
      completeAt: json['completeAt'],
      cancelledAt: json['cancelledAt'],
      searchStartedAt: json['searchStartedAt'],
      searchRadiusIndex: _toInt(json['searchRadiusIndex']),
      lastSearchAt: json['lastSearchAt'],
      notifiedDriverIds: (json['notifiedDriverIds'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      driverAcceptedLocation: json['driverAcceptedLocation'] != null
          ? Location.fromJson(json['driverAcceptedLocation'])
          : null,
    );
  }
}

Driver? _driverFromDynamic(dynamic value) {
  if (value == null) return null;
  if (value is Map) {
    return Driver.fromJson(Map<String, dynamic>.from(value));
  }
  return null;
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

Passenger? _passengerFromDynamic(dynamic value) {
  if (value == null) return null;
  if (value is Map) {
    return Passenger.fromJson(Map<String, dynamic>.from(value));
  }
  if (value is String && value.isNotEmpty) {
    return Passenger(id: value);
  }
  return null;
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'],
      coordinates: (json['coordinates'] as List?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}

class Passenger {
  Location? location;
  String? id;
  String? name;
  String? email;
  String? password;
  String? gender;
  String? phone;
  double? wallet;
  String? address;
  bool? isProfileCompleted;
  String? isActive;
  String? role;
  bool? isDeleted;
  bool? isVerified;
  ImageModel? image;
  String? createdAt;
  String? updatedAt;
  String? aboutMe;
  String? dob;

  Passenger({
    this.location,
    this.id,
    this.name,
    this.email,
    this.password,
    this.gender,
    this.phone,
    this.wallet,
    this.address,
    this.isProfileCompleted,
    this.isActive,
    this.role,
    this.isDeleted,
    this.isVerified,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.aboutMe,
    this.dob,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      gender: json['gender'],
      phone: json['phone'],
      wallet: _toDouble(json['wallet']),
      address: json['address'],
      isProfileCompleted: json['isProfileCompleted'],
      isActive: json['isActive'],
      role: json['role'],
      isDeleted: json['isDeleted'],
      isVerified: json['isVerified'],
      image: json['image'] != null ? ImageModel.fromJson(json['image']) : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      aboutMe: json['aboutMe'],
      dob: json['dob'],
    );
  }
}

class ImageModel {
  String? publicFolderPath;
  String? filename;
  String? createdAt;
  String? updatedAt;

  ImageModel({
    this.publicFolderPath,
    this.filename,
    this.createdAt,
    this.updatedAt,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      publicFolderPath: json['publicFolderPath'],
      filename: json['filename'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class Driver {
  String? id;
  String? name;
  String? phone;
  String? email;
  ImageModel? image;
  Location? location;
  double? averageRating;
  int? totalCompletedRides;
  int? totalRatings;

  Driver({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.image,
    this.location,
    this.averageRating,
    this.totalCompletedRides,
    this.totalRatings,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['_id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      image: json['image'] != null ? ImageModel.fromJson(json['image']) : null,
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      averageRating: _toDouble(json['averageRating']) ?? 0.0,
      totalCompletedRides: _toInt(json['totalCompletedRides']),
      totalRatings: _toInt(json['totalRatings']),
    );
  }
}

class DriverCar {
  String? id;
  String? driverId;
  String? carName;
  String? carPlateNumber;
  ImageModel? carImage;
  ImageModel? registrationCardImage;
  ImageModel? numberPlateImage;
  String? carRegistrationDate;
  int? numberOfSeat;
  String? vehicleType;
  bool? isReviewed;
  bool? isUploaded;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;

  DriverCar({
    this.id,
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

  factory DriverCar.fromJson(Map<String, dynamic> json) {
    return DriverCar(
      id: json['_id'],
      driverId: json['driverId'],
      carName: json['carName'],
      carPlateNumber: json['carPlateNumber'],
      carImage: json['carImage'] != null
          ? ImageModel.fromJson(json['carImage'])
          : null,
      registrationCardImage: json['registrationCardImage'] != null
          ? ImageModel.fromJson(json['registrationCardImage'])
          : null,
      numberPlateImage: json['numberPlateImage'] != null
          ? ImageModel.fromJson(json['numberPlateImage'])
          : null,
      carRegistrationDate: json['carRegistrationDate'],
      numberOfSeat: json['numberOfSeat'],
      vehicleType: json['vehicleType'],
      isReviewed: json['isReviewed'],
      isUploaded: json['isUploaded'],
      isDeleted: json['isDeleted'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
