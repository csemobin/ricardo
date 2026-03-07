import 'dart:ffi';

class AcceptRideModel {
  final bool? isRideAccepted;
  final Ride? ride;
  final Driver? driver;
  final DriverCar? driverCar;

  AcceptRideModel({
    this.isRideAccepted,
    this.ride,
    this.driver,
    this.driverCar,
  });

  factory AcceptRideModel.fromJson(Map<String, dynamic> json) {
    return AcceptRideModel(
      isRideAccepted: json['isRideAccepted'] as bool?,
      ride: json['ride'] != null ? Ride.fromJson(json['ride']) : null,
      driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
      driverCar:
      json['driverCar'] != null ? DriverCar.fromJson(json['driverCar']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'isRideAccepted': isRideAccepted,
    'ride': ride?.toJson(),
    'driver': driver?.toJson(),
    'driverCar': driverCar?.toJson(),
  };
  @override
  String toString() {
    return 'AcceptRideModel('
        'isRideAccepted: $isRideAccepted, '
        'ride: $ride, '
        'driver: $driver, '
        'driverCar: $driverCar'
        ')';
  }
}

class Ride {
  final String? id;
  final String? passenger;
  final String? driver;
  final String? pickupAddress;
  final String? destinationAddress;
  final Location? pickupLocation;
  final Location? destinationLocation;
  final int? destinationMeters;
  final double? fare;
  final String? note;
  final String? status;
  final int? waitingTime;
  final int? waitingTimeFare;
  final String? cancelledBy;
  final String? cancellationReason;
  final int? cancellationFine;
  final String? reviewId;
  final int? totalPayAmount;
  final String? acceptedAt;
  final String? completeAt;
  final String? cancelledAt;
  final String? searchStartedAt;
  final int? searchRadiusIndex;
  final String? lastSearchAt;
  final List<String>? notifiedDriverIds;
  final String? createdAt;
  final String? updatedAt;
  final Location? driverAcceptedLocation;

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
      id: json['_id'] as String?,
      passenger: json['passenger'] as String?,
      driver: json['driver'] as String?,
      pickupAddress: json['pickupAddress'] as String?,
      destinationAddress: json['destinationAddress'] as String?,
      pickupLocation: json['pickupLocation'] != null
          ? Location.fromJson(json['pickupLocation'])
          : null,
      destinationLocation: json['destinationLocation'] != null
          ? Location.fromJson(json['destinationLocation'])
          : null,
      destinationMeters: json['destinationMeters'] as int?,
      fare: (json['fare'] as num?)?.toDouble(),
      note: json['note'] as String?,
      status: json['status'] as String?,
      waitingTime: json['waitingTime'] as int?,
      waitingTimeFare: json['waitingTimeFare'] as int?,
      cancelledBy: json['cancelledBy'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      cancellationFine: json['cancellationFine'] as int?,
      reviewId: json['reviewId'] as String?,
      totalPayAmount: json['totalPayAmount'] as int?,
      acceptedAt: json['acceptedAt'] as String?,
      completeAt: json['completeAt'] as String?,
      cancelledAt: json['cancelledAt'] as String?,
      searchStartedAt: json['searchStartedAt'] as String?,
      searchRadiusIndex: json['searchRadiusIndex'] as int?,
      lastSearchAt: json['lastSearchAt'] as String?,
      notifiedDriverIds: (json['notifiedDriverIds'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      driverAcceptedLocation: json['driverAcceptedLocation'] != null
          ? Location.fromJson(json['driverAcceptedLocation'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'passenger': passenger,
    'driver': driver,
    'pickupAddress': pickupAddress,
    'destinationAddress': destinationAddress,
    'pickupLocation': pickupLocation?.toJson(),
    'destinationLocation': destinationLocation?.toJson(),
    'destinationMeters': destinationMeters,
    'fare': fare,
    'note': note,
    'status': status,
    'waitingTime': waitingTime,
    'waitingTimeFare': waitingTimeFare,
    'cancelledBy': cancelledBy,
    'cancellationReason': cancellationReason,
    'cancellationFine': cancellationFine,
    'reviewId': reviewId,
    'totalPayAmount': totalPayAmount,
    'acceptedAt': acceptedAt,
    'completeAt': completeAt,
    'cancelledAt': cancelledAt,
    'searchStartedAt': searchStartedAt,
    'searchRadiusIndex': searchRadiusIndex,
    'lastSearchAt': lastSearchAt,
    'notifiedDriverIds': notifiedDriverIds,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'driverAcceptedLocation': driverAcceptedLocation?.toJson(),
  };
  @override
  String toString() {
    return 'Ride('
        'id: $id, '
        'passenger: $passenger, '
        'driver: $driver, '
        'pickupAddress: $pickupAddress, '
        'destinationAddress: $destinationAddress, '
        'destinationMeters: $destinationMeters, '
        'fare: $fare, '
        'status: $status'
        ')';
  }
}

class Location {
  final String? type;
  final List<double>? coordinates;

  Location({this.type, this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] as String?,
      coordinates: (json['coordinates'] as List?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'coordinates': coordinates,
  };
  @override
  String toString() {
    return 'Location(type: $type, coordinates: $coordinates)';
  }
}

class Driver {
  final Location? driverLocation;
  final String? driverName;
  final String? driverPhone;
  final String? driverEmail;
  final String? driverImage;
  final Double? ratingAverage;
  final int? totalRatings;
  final int? totalCompletedRides;

  Driver({
    this.driverLocation,
    this.driverName,
    this.driverPhone,
    this.driverEmail,
    this.driverImage,
    this.ratingAverage,
    this.totalRatings,
    this.totalCompletedRides,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      driverLocation: json['driverLocation'] != null
          ? Location.fromJson(json['driverLocation'])
          : null,
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      driverEmail: json['driverEmail'] as String?,
      driverImage: json['driverImage'] as String?,
      ratingAverage: json['ratingAverage'] as Double?,
      totalRatings: json['totalRatings'] as int?,
      totalCompletedRides: json['totalCompletedRides'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'driverLocation': driverLocation?.toJson(),
    'driverName': driverName,
    'driverPhone': driverPhone,
    'driverEmail': driverEmail,
    'driverImage': driverImage,
    'ratingAverage': ratingAverage,
    'totalRatings': totalRatings,
    'totalCompletedRides': totalCompletedRides,
  };
  @override
  String toString() {
    return 'Driver('
        'driverName: $driverName, '
        'driverPhone: $driverPhone, '
        'driverEmail: $driverEmail, '
        'driverLocation: $driverLocation, '
        'ratingAverage: $ratingAverage, '
        'totalRatings: $totalRatings, '
        'totalCompletedRides: $totalCompletedRides'
        ')';
  }
}

class DriverCar {
  final String? id;
  final String? driverId;
  final String? carName;
  final String? carPlateNumber;
  final CarImage? carImage;
  final CarImage? registrationCardImage;
  final CarImage? numberPlateImage;
  final String? carRegistrationDate;
  final int? numberOfSeat;
  final String? vehicleType;
  final bool? isReviewed;
  final bool? isUploaded;
  final bool? isDeleted;
  final String? createdAt;
  final String? updatedAt;

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
      id: json['_id'] as String?,
      driverId: json['driverId'] as String?,
      carName: json['carName'] as String?,
      carPlateNumber: json['carPlateNumber'] as String?,
      carImage:
      json['carImage'] != null ? CarImage.fromJson(json['carImage']) : null,
      registrationCardImage: json['registrationCardImage'] != null
          ? CarImage.fromJson(json['registrationCardImage'])
          : null,
      numberPlateImage: json['numberPlateImage'] != null
          ? CarImage.fromJson(json['numberPlateImage'])
          : null,
      carRegistrationDate: json['carRegistrationDate'] as String?,
      numberOfSeat: json['numberOfSeat'] as int?,
      vehicleType: json['vehicleType'] as String?,
      isReviewed: json['isReviewed'] as bool?,
      isUploaded: json['isUploaded'] as bool?,
      isDeleted: json['isDeleted'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'driverId': driverId,
    'carName': carName,
    'carPlateNumber': carPlateNumber,
    'carImage': carImage?.toJson(),
    'registrationCardImage': registrationCardImage?.toJson(),
    'numberPlateImage': numberPlateImage?.toJson(),
    'carRegistrationDate': carRegistrationDate,
    'numberOfSeat': numberOfSeat,
    'vehicleType': vehicleType,
    'isReviewed': isReviewed,
    'isUploaded': isUploaded,
    'isDeleted': isDeleted,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class CarImage {
  final String? publicFolderPath;
  final String? filename;
  final String? createdAt;
  final String? updatedAt;

  CarImage({
    this.publicFolderPath,
    this.filename,
    this.createdAt,
    this.updatedAt,
  });

  factory CarImage.fromJson(Map<String, dynamic> json) {
    return CarImage(
      publicFolderPath: json['publicFolderPath'] as String?,
      filename: json['filename'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'publicFolderPath': publicFolderPath,
    'filename': filename,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}