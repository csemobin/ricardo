class GetRideDriverLocation {
  bool? success;
  String? message;
  DriverLocation? driverLocation;
  DriverLocation? passengerLocation;
  DriverToPickup? driverToPickup;
  DriverToPickup? driverToDestination;
  DriverToPickup? userToDriver;

  GetRideDriverLocation(
      {this.success,
        this.message,
        this.driverLocation,
        this.passengerLocation,
        this.driverToPickup,
        this.driverToDestination,
        this.userToDriver});

  GetRideDriverLocation.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    driverLocation = json['driverLocation'] != null
        ? new DriverLocation.fromJson(json['driverLocation'])
        : null;
    passengerLocation = json['passengerLocation'] != null
        ? new DriverLocation.fromJson(json['passengerLocation'])
        : null;
    driverToPickup = json['driverToPickup'] != null
        ? new DriverToPickup.fromJson(json['driverToPickup'])
        : null;
    driverToDestination = json['driverToDestination'] != null
        ? new DriverToPickup.fromJson(json['driverToDestination'])
        : null;
    userToDriver = json['userToDriver'] != null
        ? new DriverToPickup.fromJson(json['userToDriver'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.driverLocation != null) {
      data['driverLocation'] = this.driverLocation!.toJson();
    }
    if (this.passengerLocation != null) {
      data['passengerLocation'] = this.passengerLocation!.toJson();
    }
    if (this.driverToPickup != null) {
      data['driverToPickup'] = this.driverToPickup!.toJson();
    }
    if (this.driverToDestination != null) {
      data['driverToDestination'] = this.driverToDestination!.toJson();
    }
    if (this.userToDriver != null) {
      data['userToDriver'] = this.userToDriver!.toJson();
    }
    return data;
  }
}

class DriverLocation {
  String? type;
  List<double>? coordinates;
  /// Optional extras — present only if the backend forwards them.
  double? speed;
  double? heading;
  double? accuracy;
  DateTime? updatedAt;

  DriverLocation({
    this.type,
    this.coordinates,
    this.speed,
    this.heading,
    this.accuracy,
    this.updatedAt,
  });

  DriverLocation.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    final rawCoords = json['coordinates'];
    if (rawCoords is List) {
      coordinates = rawCoords
          .map((e) => (e is num) ? e.toDouble() : double.tryParse('$e') ?? 0.0)
          .toList();
    }
    final rawSpeed = json['speed'] ?? json['speedMps'];
    if (rawSpeed is num) speed = rawSpeed.toDouble();
    final rawHeading = json['heading'] ?? json['bearing'] ?? json['headingDegrees'];
    if (rawHeading is num) heading = rawHeading.toDouble();
    final rawAccuracy = json['accuracy'] ?? json['accuracyMeters'];
    if (rawAccuracy is num) accuracy = rawAccuracy.toDouble();
    final rawUpdated = json['updatedAt'] ??
        json['timestamp'] ??
        json['locationUpdatedAt'] ??
        json['gpsTimestamp'];
    if (rawUpdated is String) {
      updatedAt = DateTime.tryParse(rawUpdated);
    } else if (rawUpdated is num) {
      final value = rawUpdated.toInt();
      updatedAt = DateTime.fromMillisecondsSinceEpoch(
        value < 1000000000000 ? value * 1000 : value,
        isUtc: true,
      ).toLocal();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    if (speed != null) data['speed'] = speed;
    if (heading != null) data['heading'] = heading;
    if (accuracy != null) data['accuracy'] = accuracy;
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();
    return data;
  }
}

class DriverToPickup {
  Distance? distance;
  Distance? time;

  DriverToPickup({this.distance, this.time});

  DriverToPickup.fromJson(Map<String, dynamic> json) {
    distance = json['distance'] != null
        ? new Distance.fromJson(json['distance'])
        : null;
    time = json['time'] != null ? new Distance.fromJson(json['time']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.distance != null) {
      data['distance'] = this.distance!.toJson();
    }
    if (this.time != null) {
      data['time'] = this.time!.toJson();
    }
    return data;
  }
}

class Distance {
  String? text;
  int? value;

  Distance({this.text, this.value});

  Distance.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['value'] = this.value;
    return data;
  }
}
