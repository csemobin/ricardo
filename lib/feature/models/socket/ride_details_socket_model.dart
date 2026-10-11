class RideDetailsSocketModel {
  String? driverId;
  String? rideId;
  String? pickupAddress;
  String? destinationAddress;
  int? destinationMeters;
  double? fare;
  String? passengerName;
  String? passengerPhone;
  String? passengerEmail;
  String? note;
  PassengerLocation? passengerLocation;
  String? passengerImage;

  RideDetailsSocketModel({
    this.rideId,
    this.driverId,
    this.pickupAddress,
    this.destinationAddress,
    this.destinationMeters,
    this.fare,
    this.passengerName,
    this.passengerPhone,
    this.passengerEmail,
    this.note,
    this.passengerLocation,
    this.passengerImage,
  });

  factory RideDetailsSocketModel.fromJson(Map<String, dynamic> json) {
    final ride = json['ride'];
    final rideMap = ride is Map ? Map<String, dynamic>.from(ride) : null;

    String? readRideId() {
      final direct = json['rideId'] ?? json['_id'];
      if (direct != null && direct.toString().isNotEmpty) {
        return direct.toString();
      }
      final nested = rideMap?['_id'] ?? rideMap?['id'];
      if (nested != null && nested.toString().isNotEmpty) {
        return nested.toString();
      }
      return null;
    }

    String? readImage(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) return value;
      if (value is Map) {
        final filename = value['filename'];
        if (filename != null && filename.toString().isNotEmpty) {
          return filename.toString();
        }
      }
      return null;
    }

    return RideDetailsSocketModel(
      rideId: readRideId(),
      driverId: json['driverId']?.toString(),
      pickupAddress: json['pickupAddress']?.toString(),
      destinationAddress: json['destinationAddress']?.toString(),
      destinationMeters: (json['destinationMeters'] as num?)?.toInt(),
      fare: (json['fare'] as num?)?.toDouble(),
      passengerName: json['passengerName']?.toString(),
      passengerPhone: json['passengerPhone']?.toString(),
      passengerEmail: json['passengerEmail']?.toString(),
      note: json['note']?.toString(),
      passengerLocation: json['passengerLocation'] is Map<String, dynamic>
          ? PassengerLocation.fromJson(
              Map<String, dynamic>.from(json['passengerLocation']))
          : null,
      passengerImage: readImage(json['passengerImage']),
    );
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
    type = json['type']?.toString();
    final raw = json['coordinates'];
    if (raw is List) {
      coordinates = raw.map((e) => (e as num).toDouble()).toList();
    }
  }
}
