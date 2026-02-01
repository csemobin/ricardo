class RecentHistory {
  String? sId;
  UserId? userId;
  String? type;
  String? status;
  double? amount;
  String? currency;
  RideId? rideId;
  String? provider;
  String? title;
  String? description;
  Meta? meta;
  String? createdAt;
  String? updatedAt;
  String? withdrawRequestId;

  RecentHistory({
    this.sId,
    this.userId,
    this.type,
    this.status,
    this.amount,
    this.currency,
    this.rideId,
    this.provider,
    this.title,
    this.description,
    this.meta,
    this.createdAt,
    this.updatedAt,
    this.withdrawRequestId,
  });

  RecentHistory.fromJson(Map<String, dynamic> json) {
    sId = json['_id']?.toString();
    userId = json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    type = json['type']?.toString();
    status = json['status']?.toString();

    // Safely parse amount
    amount = _parseToDouble(json['amount']);

    currency = json['currency']?.toString();
    rideId = json['rideId'] != null ? RideId.fromJson(json['rideId']) : null;
    provider = json['provider']?.toString();
    title = json['title']?.toString();
    description = json['description']?.toString();

    // Safely parse meta (handle null and different types)
    if (json['meta'] != null && json['meta'] is Map<String, dynamic>) {
      meta = Meta.fromJson(json['meta']);
    } else {
      meta = null;
    }

    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
    withdrawRequestId = json['withdrawRequestId']?.toString();
  }

  double? _parseToDouble(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value);
    } else if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (userId != null) {
      data['userId'] = userId!.toJson();
    }
    data['type'] = type;
    data['status'] = status;
    data['amount'] = amount;
    data['currency'] = currency;
    if (rideId != null) {
      data['rideId'] = rideId!.toJson();
    }
    data['provider'] = provider;
    data['title'] = title;
    data['description'] = description;
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['withdrawRequestId'] = withdrawRequestId;
    return data;
  }
}

class UserId {
  Location? location;
  String? sId;
  String? name;
  String? email;
  String? phone;
  Image? image;

  UserId({
    this.location,
    this.sId,
    this.name,
    this.email,
    this.phone,
    this.image,
  });

  UserId.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? Location.fromJson(json['location'])
        : null;
    sId = json['_id']?.toString();
    name = json['name']?.toString();
    email = json['email']?.toString();
    phone = json['phone']?.toString();
    image = json['image'] != null ? Image.fromJson(json['image']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    if (image != null) {
      data['image'] = image!.toJson();
    }
    return data;
  }
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();

    // Safely parse coordinates
    if (json['coordinates'] is List) {
      coordinates = (json['coordinates'] as List).map((coord) {
        if (coord is int) {
          return coord.toDouble();
        } else if (coord is double) {
          return coord;
        } else if (coord is String) {
          return double.tryParse(coord) ?? 0.0;
        } else if (coord is num) {
          return coord.toDouble();
        }
        return 0.0;
      }).toList();
    } else {
      coordinates = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}

class Image {
  String? publicFolderPath;
  String? filename;
  String? createdAt;
  String? updatedAt;

  Image({
    this.publicFolderPath,
    this.filename,
    this.createdAt,
    this.updatedAt,
  });

  Image.fromJson(Map<String, dynamic> json) {
    publicFolderPath = json['publicFolderPath']?.toString();
    filename = json['filename']?.toString();
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['publicFolderPath'] = publicFolderPath;
    data['filename'] = filename;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class RideId {
  String? sId;
  Location? pickupLocation;
  Location? destinationLocation;

  RideId({
    this.sId,
    this.pickupLocation,
    this.destinationLocation,
  });

  RideId.fromJson(Map<String, dynamic> json) {
    sId = json['_id']?.toString();
    pickupLocation = json['pickupLocation'] != null
        ? Location.fromJson(json['pickupLocation'])
        : null;
    destinationLocation = json['destinationLocation'] != null
        ? Location.fromJson(json['destinationLocation'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (pickupLocation != null) {
      data['pickupLocation'] = pickupLocation!.toJson();
    }
    if (destinationLocation != null) {
      data['destinationLocation'] = destinationLocation!.toJson();
    }
    return data;
  }
}

class Meta {
  double? baseFare;
  double? waitingMinutes;
  double? waitingFare;
  double? totalPayAmount;

  Meta({
    this.baseFare,
    this.waitingMinutes,
    this.waitingFare,
    this.totalPayAmount,
  });

  Meta.fromJson(Map<String, dynamic> json) {
    baseFare = _parseToDouble(json['baseFare']);
    waitingMinutes = _parseToDouble(json['waitingMinutes']);
    waitingFare = _parseToDouble(json['waitingFare']);
    totalPayAmount = _parseToDouble(json['totalPayAmount']);
  }

  double? _parseToDouble(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value);
    } else if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['baseFare'] = baseFare;
    data['waitingMinutes'] = waitingMinutes;
    data['waitingFare'] = waitingFare;
    data['totalPayAmount'] = totalPayAmount;
    return data;
  }
}