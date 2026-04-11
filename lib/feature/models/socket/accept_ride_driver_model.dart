class AcceptRideDriverModel {
  bool? isRideAcceptedDriver;
  Ride? ride;
  Passenger? passenger;

  AcceptRideDriverModel({this.isRideAcceptedDriver, this.ride, this.passenger});

  AcceptRideDriverModel.fromJson(Map<String, dynamic> json) {
    isRideAcceptedDriver = json['isRideAcceptedDriver'];
    ride = json['ride'] != null ? new Ride.fromJson(json['ride']) : null;
    passenger = json['passenger'] != null
        ? new Passenger.fromJson(json['passenger'])
        : null;
  }
}

class Ride {
  String? sId;
  String? passenger;
  String? driver;
  String? pickupAddress;
  String? destinationAddress;
  PickupLocation? pickupLocation;
  PickupLocation? destinationLocation;
  int? destinationMeters;
  double? fare;
  String? note;
  String? status;
  int? waitingTime;
  int? waitingTimeFare;
  String? cancelledBy;
  String? cancellationReason;
  int? cancellationFine;
  String? reviewId;
  int? totalPayAmount;
  String? acceptedAt;
  String? completeAt;
  String? cancelledAt;
  String? searchStartedAt;
  int? searchRadiusIndex;
  String? lastSearchAt;
  List<String>? notifiedDriverIds;
  String? createdAt;
  String? updatedAt;
  PickupLocation? driverAcceptedLocation;

  Ride(
      {this.sId,
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
        this.driverAcceptedLocation});

  Ride.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    passenger = json['passenger'];
    driver = json['driver'];
    pickupAddress = json['pickupAddress'];
    destinationAddress = json['destinationAddress'];
    pickupLocation = json['pickupLocation'] != null
        ? new PickupLocation.fromJson(json['pickupLocation'])
        : null;
    destinationLocation = json['destinationLocation'] != null
        ? new PickupLocation.fromJson(json['destinationLocation'])
        : null;
    destinationMeters = json['destinationMeters'];
    fare = json['fare'];
    note = json['note'];
    status = json['status'];
    waitingTime = json['waitingTime'];
    waitingTimeFare = json['waitingTimeFare'];
    cancelledBy = json['cancelledBy'];
    cancellationReason = json['cancellationReason'];
    cancellationFine = json['cancellationFine'];
    reviewId = json['reviewId'];
    totalPayAmount = json['totalPayAmount'];
    acceptedAt = json['acceptedAt'];
    completeAt = json['completeAt'];
    cancelledAt = json['cancelledAt'];
    searchStartedAt = json['searchStartedAt'];
    searchRadiusIndex = json['searchRadiusIndex'];
    lastSearchAt = json['lastSearchAt'];
    notifiedDriverIds = json['notifiedDriverIds'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    driverAcceptedLocation = json['driverAcceptedLocation'] != null
        ? new PickupLocation.fromJson(json['driverAcceptedLocation'])
        : null;
  }
}

class PickupLocation {
  String? type;
  List<double>? coordinates;

  PickupLocation({this.type, this.coordinates});

  PickupLocation.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }
}

class Passenger {
  PickupLocation? passengerLocation;
  String? passengerName;
  String? passengerPhone;
  String? passengerEmail;
  String? passengerImage;
  String? passengerAddress;

  Passenger(
      {this.passengerLocation,
        this.passengerName,
        this.passengerPhone,
        this.passengerEmail,
        this.passengerImage,
        this.passengerAddress});

  Passenger.fromJson(Map<String, dynamic> json) {
    passengerLocation = json['passengerLocation'] != null
        ? new PickupLocation.fromJson(json['passengerLocation'])
        : null;
    passengerName = json['passengerName'];
    passengerPhone = json['passengerPhone'];
    passengerEmail = json['passengerEmail'];
    passengerImage = json['passengerImage'];
    passengerAddress = json['passengerAddress'];
  }
}
