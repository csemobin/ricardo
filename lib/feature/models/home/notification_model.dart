class NotificationModel {
  String? sId;
  String? title;
  String? message;
  String? receiverId;
  bool? viewStatus;
  String? createdAt;
  String? updatedAt;

  NotificationModel({
    this.sId,
    this.title,
    this.message,
    this.receiverId,
    this.viewStatus,
    this.createdAt,
    this.updatedAt,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    message = json['message'];
    receiverId = json['receiverId'];
    viewStatus = json['viewStatus'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}

class Meta {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  Meta({
    this.total,
    this.page,
    this.limit,
    this.totalPages,
  });

  Meta.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
  }
}
