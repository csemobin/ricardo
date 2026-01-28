class SupportModel {
  String? sId;
  String? key;
  int? iV;
  Value? value;

  SupportModel({this.sId, this.key, this.iV, this.value});

  SupportModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    key = json['key'];
    iV = json['__v'];
    value = json['value'] != null ? new Value.fromJson(json['value']) : null;
  }
}

class Value {
  String? details;
  String? phone;
  String? email;

  Value({this.details, this.phone, this.email});

  Value.fromJson(Map<String, dynamic> json) {
    details = json['details'];
    phone = json['phone'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['details'] = this.details;
    data['phone'] = this.phone;
    data['email'] = this.email;
    return data;
  }
}
