class RideStatusModel {
  bool? acceptRide;
  bool? ongoingRide;
  bool? arrivingRide;
  bool? driverCancel;
  bool? passengerCancel;
  bool? completeRide;
  Ride? ride;
  Passenger? passenger;
  Driver? driver;
  DriverCar? driverCar;

  RideStatusModel(
      {this.acceptRide,
        this.ongoingRide,
        this.arrivingRide,
        this.driverCancel,
        this.passengerCancel,
        this.completeRide,
        this.ride,
        this.passenger,
        this.driver,
        this.driverCar});

  RideStatusModel.fromJson(Map<String, dynamic> json) {
    acceptRide = json['acceptRide'];
    ongoingRide = json['ongoingRide'];
    arrivingRide = json['arrivingRide'];
    driverCancel = json['driverCancel'];
    passengerCancel = json['passengerCancel'];
    completeRide = json['completeRide'];
    ride = json['ride'] != null ? new Ride.fromJson(json['ride']) : null;
    passenger = json['passenger'] != null
        ? new Passenger.fromJson(json['passenger'])
        : null;
    driver =
    json['driver'] != null ? new Driver.fromJson(json['driver']) : null;
    driverCar = json['driverCar'] != null
        ? new DriverCar.fromJson(json['driverCar'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['acceptRide'] = this.acceptRide;
    data['ongoingRide'] = this.ongoingRide;
    data['arrivingRide'] = this.arrivingRide;
    data['driverCancel'] = this.driverCancel;
    data['passengerCancel'] = this.passengerCancel;
    data['completeRide'] = this.completeRide;
    if (this.ride != null) {
      data['ride'] = this.ride!.toJson();
    }
    if (this.passenger != null) {
      data['passenger'] = this.passenger!.toJson();
    }
    if (this.driver != null) {
      data['driver'] = this.driver!.toJson();
    }
    if (this.driverCar != null) {
      data['driverCar'] = this.driverCar!.toJson();
    }
    return data;
  }
}

class Ride {
  String? sId;
  Passenger? passenger;
  Driver? driver;
  String? pickupAddress;
  String? destinationAddress;
  Location? pickupLocation;
  Location? destinationLocation;
  int? destinationMeters;
  double? fare;
  Null? note;
  String? status;
  int? waitingTime;
  int? waitingTimeFare;
  Null? cancelledBy;
  Null? cancellationReason;
  int? cancellationFine;
  Null? reviewId;
  int? totalPayAmount;
  String? acceptedAt;
  Null? completeAt;
  Null? cancelledAt;
  String? searchStartedAt;
  int? searchRadiusIndex;
  String? lastSearchAt;
  List<String>? notifiedDriverIds;
  String? createdAt;
  String? updatedAt;
  Location? driverAcceptedLocation;

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
    passenger = json['passenger'] != null
        ? new Passenger.fromJson(json['passenger'])
        : null;
    driver =
    json['driver'] != null ? new Driver.fromJson(json['driver']) : null;
    pickupAddress = json['pickupAddress'];
    destinationAddress = json['destinationAddress'];
    pickupLocation = json['pickupLocation'] != null
        ? new Location.fromJson(json['pickupLocation'])
        : null;
    destinationLocation = json['destinationLocation'] != null
        ? new Location.fromJson(json['destinationLocation'])
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
        ? new Location.fromJson(json['driverAcceptedLocation'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.passenger != null) {
      data['passenger'] = this.passenger!.toJson();
    }
    if (this.driver != null) {
      data['driver'] = this.driver!.toJson();
    }
    data['pickupAddress'] = this.pickupAddress;
    data['destinationAddress'] = this.destinationAddress;
    if (this.pickupLocation != null) {
      data['pickupLocation'] = this.pickupLocation!.toJson();
    }
    if (this.destinationLocation != null) {
      data['destinationLocation'] = this.destinationLocation!.toJson();
    }
    data['destinationMeters'] = this.destinationMeters;
    data['fare'] = this.fare;
    data['note'] = this.note;
    data['status'] = this.status;
    data['waitingTime'] = this.waitingTime;
    data['waitingTimeFare'] = this.waitingTimeFare;
    data['cancelledBy'] = this.cancelledBy;
    data['cancellationReason'] = this.cancellationReason;
    data['cancellationFine'] = this.cancellationFine;
    data['reviewId'] = this.reviewId;
    data['totalPayAmount'] = this.totalPayAmount;
    data['acceptedAt'] = this.acceptedAt;
    data['completeAt'] = this.completeAt;
    data['cancelledAt'] = this.cancelledAt;
    data['searchStartedAt'] = this.searchStartedAt;
    data['searchRadiusIndex'] = this.searchRadiusIndex;
    data['lastSearchAt'] = this.lastSearchAt;
    data['notifiedDriverIds'] = this.notifiedDriverIds;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.driverAcceptedLocation != null) {
      data['driverAcceptedLocation'] = this.driverAcceptedLocation!.toJson();
    }
    return data;
  }
}

class Passenger {
  Location? location;
  String? sId;
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
  Image? image;
  String? createdAt;
  String? updatedAt;
  String? aboutMe;
  String? dob;

  Passenger(
      {this.location,
        this.sId,
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
        this.dob});

  Passenger.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    gender = json['gender'];
    phone = json['phone'];
    wallet = json['wallet'];
    address = json['address'];
    isProfileCompleted = json['isProfileCompleted'];
    isActive = json['isActive'];
    role = json['role'];
    isDeleted = json['isDeleted'];
    isVerified = json['isVerified'];
    image = json['image'] != null ? new Image.fromJson(json['image']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    aboutMe = json['aboutMe'];
    dob = json['dob'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['gender'] = this.gender;
    data['phone'] = this.phone;
    data['wallet'] = this.wallet;
    data['address'] = this.address;
    data['isProfileCompleted'] = this.isProfileCompleted;
    data['isActive'] = this.isActive;
    data['role'] = this.role;
    data['isDeleted'] = this.isDeleted;
    data['isVerified'] = this.isVerified;
    if (this.image != null) {
      data['image'] = this.image!.toJson();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['aboutMe'] = this.aboutMe;
    data['dob'] = this.dob;
    return data;
  }
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['coordinates'] = this.coordinates;
    return data;
  }
}

class Image {
  String? publicFolderPath;
  String? filename;
  String? createdAt;
  String? updatedAt;

  Image({this.publicFolderPath, this.filename, this.createdAt, this.updatedAt});

  Image.fromJson(Map<String, dynamic> json) {
    publicFolderPath = json['publicFolderPath'];
    filename = json['filename'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['publicFolderPath'] = this.publicFolderPath;
    data['filename'] = this.filename;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class Driver {
  Location? location;
  String? sId;
  String? name;
  String? email;
  String? password;
  String? phone;
  double? wallet;
  bool? isProfileCompleted;
  String? isActive;
  String? role;
  bool? isDeleted;
  bool? isVerified;
  Image? image;
  String? createdAt;
  String? updatedAt;
  String? aboutMe;
  String? dob;
  String? gender;

  Driver(
      {this.location,
        this.sId,
        this.name,
        this.email,
        this.password,
        this.phone,
        this.wallet,
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
        this.gender});

  Driver.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    phone = json['phone'];
    wallet = json['wallet'];
    isProfileCompleted = json['isProfileCompleted'];
    isActive = json['isActive'];
    role = json['role'];
    isDeleted = json['isDeleted'];
    isVerified = json['isVerified'];
    image = json['image'] != null ? new Image.fromJson(json['image']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    aboutMe = json['aboutMe'];
    dob = json['dob'];
    gender = json['gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['phone'] = this.phone;
    data['wallet'] = this.wallet;
    data['isProfileCompleted'] = this.isProfileCompleted;
    data['isActive'] = this.isActive;
    data['role'] = this.role;
    data['isDeleted'] = this.isDeleted;
    data['isVerified'] = this.isVerified;
    if (this.image != null) {
      data['image'] = this.image!.toJson();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['aboutMe'] = this.aboutMe;
    data['dob'] = this.dob;
    data['gender'] = this.gender;
    return data;
  }
}

class DriverCar {
  String? sId;
  String? driverId;
  String? carName;
  String? carPlateNumber;
  Image? carImage;
  Image? registrationCardImage;
  Image? numberPlateImage;
  String? carRegistrationDate;
  int? numberOfSeat;
  String? vehicleType;
  bool? isReviewed;
  bool? isUploaded;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;

  DriverCar(
      {this.sId,
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
        this.updatedAt});

  DriverCar.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    driverId = json['driverId'];
    carName = json['carName'];
    carPlateNumber = json['carPlateNumber'];
    carImage =
    json['carImage'] != null ? new Image.fromJson(json['carImage']) : null;
    registrationCardImage = json['registrationCardImage'] != null
        ? new Image.fromJson(json['registrationCardImage'])
        : null;
    numberPlateImage = json['numberPlateImage'] != null
        ? new Image.fromJson(json['numberPlateImage'])
        : null;
    carRegistrationDate = json['carRegistrationDate'];
    numberOfSeat = json['numberOfSeat'];
    vehicleType = json['vehicleType'];
    isReviewed = json['isReviewed'];
    isUploaded = json['isUploaded'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['driverId'] = this.driverId;
    data['carName'] = this.carName;
    data['carPlateNumber'] = this.carPlateNumber;
    if (this.carImage != null) {
      data['carImage'] = this.carImage!.toJson();
    }
    if (this.registrationCardImage != null) {
      data['registrationCardImage'] = this.registrationCardImage!.toJson();
    }
    if (this.numberPlateImage != null) {
      data['numberPlateImage'] = this.numberPlateImage!.toJson();
    }
    data['carRegistrationDate'] = this.carRegistrationDate;
    data['numberOfSeat'] = this.numberOfSeat;
    data['vehicleType'] = this.vehicleType;
    data['isReviewed'] = this.isReviewed;
    data['isUploaded'] = this.isUploaded;
    data['isDeleted'] = this.isDeleted;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
