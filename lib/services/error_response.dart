class ErrorResponse {
  final String? status;
  final int? statusCode;
  final String? message;

  ErrorResponse({
    this.status,
    this.statusCode,
    this.message,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    String? parsedStatus;
    if (json["status"] is String) {
      parsedStatus = json["status"];
    } else if (json["status"] is List) {
      parsedStatus = (json["status"] as List).join(", ");
    }
    String? parsedMessage;
    if (json["message"] is String) {
      parsedMessage = json["message"];
    } else if (json["message"] is List) {
      parsedMessage = (json["message"] as List).join(", ");
    }

    return ErrorResponse(
      status: parsedStatus,
      statusCode: json["statusCode"],
      message: parsedMessage,
    );
  }
}
