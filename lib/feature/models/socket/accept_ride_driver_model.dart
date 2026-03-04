class AcceptRideDriverModel {
  final bool? isRideAcceptedDriver;
  final dynamic ride; // replace with your Ride model if you have one
  final PassengerInfo? passenger;

  AcceptRideDriverModel({
    this.isRideAcceptedDriver,
    this.ride,
    this.passenger,
  });

  factory AcceptRideDriverModel.fromJson(Map<String, dynamic> json) {
    return AcceptRideDriverModel(
      isRideAcceptedDriver: json['isRideAcceptedDriver'] as bool?,
      ride: json['ride'],
      passenger: json['passenger'] != null
          ? PassengerInfo.fromJson(json['passenger'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isRideAcceptedDriver': isRideAcceptedDriver,
      'ride': ride,
      'passenger': passenger?.toJson(),
    };
  }
}

class PassengerInfo {
  final dynamic passengerLocation; // replace with LatLng or Location model if needed
  final String? passengerName;
  final String? passengerPhone;
  final String? passengerEmail;
  final String? passengerImage;
  final String? passengerAddress;

  PassengerInfo({
    this.passengerLocation,
    this.passengerName,
    this.passengerPhone,
    this.passengerEmail,
    this.passengerImage,
    this.passengerAddress,
  });

  factory PassengerInfo.fromJson(Map<String, dynamic> json) {
    return PassengerInfo(
      passengerLocation: json['passengerLocation'],
      passengerName:    json['passengerName']    as String?,
      passengerPhone:   json['passengerPhone']   as String?,
      passengerEmail:   json['passengerEmail']   as String?,
      passengerImage:   json['passengerImage']   as String?,
      passengerAddress: json['passengerAddress'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passengerLocation': passengerLocation,
      'passengerName':     passengerName,
      'passengerPhone':    passengerPhone,
      'passengerEmail':    passengerEmail,
      'passengerImage':    passengerImage,
      'passengerAddress':  passengerAddress,
    };
  }
}