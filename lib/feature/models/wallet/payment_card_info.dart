class PaymentCardInfoModel {
  String? sId;
  String? userId;
  String? bankName;
  String? accountName;
  String? accountNumber;
  String? country;
  String? bankCode;
  String? moreInfo;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;

  PaymentCardInfoModel(
      {this.sId,
      this.userId,
      this.bankName,
      this.accountName,
      this.accountNumber,
      this.country,
      this.bankCode,
        this.moreInfo,
      this.isDeleted,
      this.createdAt,
      this.updatedAt,
      });

  PaymentCardInfoModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    bankName = json['bankName'];
    accountName = json['accountName'];
    accountNumber = json['accountNumber'];
    country = json['country'];
    bankCode = json['bankCode'];
    moreInfo = json['moreInfo'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}
