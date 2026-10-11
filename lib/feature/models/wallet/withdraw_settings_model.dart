class WithdrawSettingsModel {
  String? id;
  double? cancellationFeePerMile;
  List<String>? freeWithdrawDays;
  bool? isWithdrawEnabled;
  double? minimumWithdrawAmount;
  double? perMilePrice;
  double? platformFeePercentage;
  double? waitingTimeCharge;
  String? createdAt;
  String? updatedAt;

  WithdrawSettingsModel({
    this.id,
    this.cancellationFeePerMile,
    this.freeWithdrawDays,
    this.isWithdrawEnabled,
    this.minimumWithdrawAmount,
    this.perMilePrice,
    this.platformFeePercentage,
    this.waitingTimeCharge,
    this.createdAt,
    this.updatedAt,
  });

  WithdrawSettingsModel.fromJson(Map<String, dynamic> json) {
    id = json['_id']?.toString();
    cancellationFeePerMile = _toDouble(json['cancellationFeePerMile']);
    freeWithdrawDays = json['freeWithdrawDays'] != null
        ? List<String>.from(json['freeWithdrawDays'])
        : null;
    isWithdrawEnabled = json['isWithdrawEnabled'];
    minimumWithdrawAmount = _toDouble(json['minimumWithdrawAmount']);
    perMilePrice = _toDouble(json['perMilePrice']);
    platformFeePercentage = _toDouble(json['platformFeePercentage']);
    waitingTimeCharge = _toDouble(json['waitingTimeCharge']);
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
