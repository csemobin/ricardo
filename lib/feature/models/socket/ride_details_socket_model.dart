class RideDetailsSocketModel {
  String? rideId;
  String? pickupAddress;
  String? destinationAddress;
  int? destinationMeters;
  double? fare;
  String? passengerName;
  String? passengerPhone;
  String? passengerEmail;
  PassengerLocation? passengerLocation;
  String? passengerImage;

  RideDetailsSocketModel({
    this.rideId,
    this.pickupAddress,
    this.destinationAddress,
    this.destinationMeters,
    this.fare,
    this.passengerName,
    this.passengerPhone,
    this.passengerEmail,
    this.passengerLocation,
    this.passengerImage,
  });

  RideDetailsSocketModel.fromJson(Map<String, dynamic> json) {
    rideId = json['rideId'];
    pickupAddress = json['pickupAddress'];
    destinationAddress = json['destinationAddress'];
    destinationMeters = json['destinationMeters'];
    fare = json['fare'];
    passengerName = json['passengerName'];
    passengerPhone = json['passengerPhone'];
    passengerEmail = json['passengerEmail'];
    passengerLocation = json['passengerLocation'] != null
        ? new PassengerLocation.fromJson(json['passengerLocation'])
        : null;
    passengerImage = json['passengerImage'];
  }
}

class PassengerLocation {
  String? type;
  List<double>? coordinates;

  PassengerLocation({
    this.type,
    this.coordinates,
  });

  PassengerLocation.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }
}
