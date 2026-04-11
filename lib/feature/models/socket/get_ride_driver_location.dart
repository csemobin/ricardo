class GetRideDriverLocation {
  bool? success;
  String? message;
  DriverLocation? driverLocation;
  DriverLocation? passengerLocation;
  DriverToPickup? driverToPickup;
  DriverToPickup? driverToDestination;

  GetRideDriverLocation(
      {this.success,
        this.message,
        this.driverLocation,
        this.passengerLocation,
        this.driverToPickup,
        this.driverToDestination,
      });

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
}

class Distance {
  String? text;
  int? value;

  Distance({this.text, this.value});

  Distance.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    value = json['value'];
  }
}
