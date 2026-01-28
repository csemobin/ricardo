class CompleteRideHistoryModel {
  List<Rides>? rides;
  String? date;

  CompleteRideHistoryModel({this.rides, this.date});

  CompleteRideHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['rides'] != null) {
      rides = <Rides>[];
      json['rides'].forEach((v) {
        rides!.add(new Rides.fromJson(v));
      });
    }
    date = json['date'];
  }
}

class Rides {
  String? sId;
  String? passenger;
  String? driver;
  String? pickupAddress;
  String? destinationAddress;
  PickupLocation? pickupLocation;
  PickupLocation? destinationLocation;
  int? destinationMeters;
  double? fare;
  String? status;
  int? waitingTime;
  int? waitingTimeFare;
  String? cancelledBy;
  String? cancellationReason;
  int? cancellationFine;
  String? reviewId;
  double? totalPayAmount;
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
  String? completedDate;

  Rides(
      {this.sId,
        this.passenger,
        this.driver,
        this.pickupAddress,
        this.destinationAddress,
        this.pickupLocation,
        this.destinationLocation,
        this.destinationMeters,
        this.fare,
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
        this.completedDate});

  Rides.fromJson(Map<String, dynamic> json) {
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
    completedDate = json['completedDate'];
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
