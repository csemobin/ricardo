class PaymentCardInfoModel {
  String? sId;
  String? userId;
  String? bankName;
  String? accountName;
  String? accountNumber;
  String? routingNumber;
  String? country;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;

  PaymentCardInfoModel(
      {this.sId,
      this.userId,
      this.bankName,
      this.accountName,
      this.accountNumber,
      this.routingNumber,
      this.country,
      this.isDeleted,
      this.createdAt,
      this.updatedAt});

  PaymentCardInfoModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    bankName = json['bankName'];
    accountName = json['accountName'];
    accountNumber = json['accountNumber'];
    routingNumber = json['routingNumber'];
    country = json['country'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}
