import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/socket_services.dart';

import '../app/helpers/prefs_helper.dart';
import '../app/utils/app_constants.dart';
import 'api_urls.dart';
import 'error_response.dart';
import 'logger.dart';


final log = logger(ApiClient);

class ApiClient extends GetxService  {
  static var client = http.Client();
  static const String noInternetMessage = "Can't connect to the internet!";
  static const int timeoutInSeconds = 60;
  static String bearerToken = "";
  static bool _isHandlingExpiredToken = false;

  // <==========================================> Get Data <======================================>
  static Future<Response> getData(String uri, {Map<String, String>? headers}) async {
    bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken'
    };
    try {
      log.i(
          '|📍📍📍|-----------------[[ GET ]] method details start -----------------|📍📍📍|');
      log.i('URL: $uri \n Headers: ${headers ?? mainHeaders}');

      http.Response response = await client.get(
        Uri.parse(ApiUrls.baseUrl + uri),
        headers: headers ?? mainHeaders,
      ).timeout(const Duration(seconds: timeoutInSeconds));

      return handleResponse(response, uri);
    } catch (e, s) {
      log.e('🐞🐞🐞 Error in getData: ${e.toString()}');
      log.e('Stacktrace: ${s.toString()}');
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  static Future<Response> getDataWithoutVersion(String uri, {Map<String, String>? headers}) async {
    bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken'
    };
    try {
      log.i(
          '|📍📍📍|-----------------[[ GET ]] method details start -----------------|📍📍📍|');
      log.i('URL: $uri \n Headers: ${headers ?? mainHeaders}');

      http.Response response = await client.get(
        Uri.parse(uri),
        headers: headers ?? mainHeaders,
      ).timeout(const Duration(seconds: timeoutInSeconds));

      return handleResponse(response, uri);
    } catch (e, s) {
      log.e('🐞🐞🐞 Error in getData: ${e.toString()}');
      log.e('Stacktrace: ${s.toString()}');
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  //==========================================> Post Data <======================================
  static Future<Response> postData(String uri, dynamic body, {Map<String, String>? headers}) async {
    String bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    };

    try {
      log.i(
          '|📍📍📍|-----------------[[ POST ]] method details start -----------------|📍📍📍|');
      log.i('URL: $uri \n ${headers ?? mainHeaders} \n $body');

      http.Response response = await client.post(
        Uri.parse(ApiUrls.baseUrl + uri),
        body: jsonEncode(body),
        headers: headers ?? mainHeaders,
      ).timeout(const Duration(seconds: timeoutInSeconds));

      log.i("==========> Response Post Method: ${response.statusCode}");
      return handleResponse(response, uri);
    } catch (e, s) {
      log.e("🐞🐞🐞 Error in postData: ${e.toString()}");
      log.e("Stacktrace: ${s.toString()}");
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }


  //==========================================> Patch Data <======================================
  static Future<Response> patch(String uri, dynamic body,
      {Map<String, String>? headers}) async {
    bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken'
    };

    if (headers != null) {
      mainHeaders.addAll(headers);
    }

    try {
      log.i('|📍📍📍|-----------------[[ PATCH ]] method details start -----------------|📍📍📍|');
      log.i('URL: $uri');
      log.i('Headers: $mainHeaders');
      log.i('API Body: $body');

      http.Response response = await client
          .patch(
        Uri.parse(ApiUrls.baseUrl + uri),
        body: body is String ? body : jsonEncode(body),
        headers: mainHeaders,
      )
          .timeout(const Duration(seconds: timeoutInSeconds));

      log.i("==========> Response Patch Method: ${response.statusCode}");
      return handleResponse(response, uri);
    } catch (e) {
      log.e("🐞🐞🐞 Error in patch: ${e.toString()}");
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }


  //==========================================> put Data <======================================
  static Future<Response> put(String uri, var body, {Map<String, String>? headers}) async {
    bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      //'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken'
    };
    try {
      log.i(
          '|📍📍📍|-----------------[[ PUT ]] method details start -----------------|📍📍📍|');
      log.i('URL: $uri');
      log.i('Headers: ${headers ?? mainHeaders}');
      log.i('API Body: $body');

      http.Response response = await client
          .put(
        Uri.parse(ApiUrls.baseUrl + uri),
        body: body,
        headers: headers ?? mainHeaders,
      )
          .timeout(const Duration(seconds: timeoutInSeconds));

      log.i(
          "==========> Response Patch Method: ${response.statusCode}");
      return handleResponse(response, uri);
    } catch (e) {
      log.e("🐞🐞🐞 Error in patch: ${e.toString()}");
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  //==========================================> Post Multipart Data <======================================
  static Future<Response> postMultipartData(String uri, Map<dynamic, dynamic> body, {List<MultipartBody>? multipartBody, Map<String, String>? headers}) async {
    try {
      // Fetch Bearer Token
      bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);

      // Headers
      var mainHeaders = {
        'Authorization': 'Bearer $bearerToken',
      };

      // Log API Call
      log.i(
          '|📍📍📍|-----------------[[ POST MULTIPART ]] method details start -----------------|📍📍📍|');
      log.i('URL: $uri');
      log.i('Headers: ${headers ?? mainHeaders}');
      log.i('API Body: $body with ${multipartBody?.length ?? 0} files');

      // Create Multipart Request
      var request = http.MultipartRequest('POST', Uri.parse(ApiUrls.baseUrl + uri));

      // Add headers
      request.headers.addAll(headers ?? mainHeaders);

      // Add form fields
      body.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add files
      if (multipartBody != null && multipartBody.isNotEmpty) {
        for (var element in multipartBody) {
          log.i("File path: ${element.file.path}");
          if (element.file.existsSync()) {
            String? mimeType = mime(element.file.path);
            request.files.add(await http.MultipartFile.fromPath(
              element.key,
              element.file.path,
              contentType: MediaType.parse(mimeType!),
            ));
          } else {
            log.e("File does not exist: ${element.file.path}");
          }
        }
      }
      // Send the request
      http.StreamedResponse response = await request.send();

      // Convert response to HTTP Response
      http.Response httpResponse = await http.Response.fromStream(response);

      // Handle Response
      return handleResponse(httpResponse, uri);
    } catch (e, s) {
      log.e("🐞🐞🐞 Error in postMultipartData: ${e.toString()}");
      log.e("Stacktrace: ${s.toString()}");
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  //==========================================> Put Data <======================================
  Future<Response> putData(String uri, dynamic body, {Map<String, String>? headers}) async {
    bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken'
    };
    try {
      log.i(
          '|📍📍📍|-----------------[[ PUT ]] method details start -----------------|📍📍📍|');
      log.i('URL: $uri');
      log.i('Headers: ${headers ?? mainHeaders}');
      log.i('API Body: $body');

      http.Response response = await http
          .put(
        Uri.parse(ApiUrls.baseUrl + uri),
        body: jsonEncode(body),
        headers: headers ?? mainHeaders,
      )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      log.e("🐞🐞🐞 Error in putData: ${e.toString()}");
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  //==========================================> Put Multipart Data <======================================
  static Future<Response> putMultipartData(String uri, Map<String, String> body, {List<MultipartBody>? multipartBody, List<MultipartListBody>? multipartListBody, Map<String, String>? headers,}) async {
    try {
      // Fetch bearer token from preferences
      bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);

      // Set up main headers with Authorization and Content-Type for multipart data
      var mainHeaders = {
        'Content-Type': 'multipart/form-data', // Change to multipart form-data
        'Authorization': 'Bearer $bearerToken'
      };

      // Log API Call details for debugging
      log.i(
          '|📍📍📍|-----------------[[ PUT MULTIPART ]] method details start -----------------|📍📍📍|');
      log.i('URL: $uri');
      log.i('Headers: ${headers ?? mainHeaders}');
      log.i('API Body: $body with ${multipartBody?.length ?? 0} file(s)');

      // Create a MultipartRequest for PUT
      var request = http.MultipartRequest('PUT', Uri.parse(ApiUrls.baseUrl + uri));
      request.fields.addAll(body); // Add fields to request

      // Check if multipartBody exists and is not empty
      if (multipartBody != null && multipartBody.isNotEmpty) {
        for (var element in multipartBody) {
          log.i("File path: ${element.file.path}");
          if (element.file.existsSync()) {
            String? mimeType = mime(element.file.path);
            request.files.add(await http.MultipartFile.fromPath(
              element.key,
              element.file.path,
              contentType: MediaType.parse(mimeType!),
            ));
          } else {
            log.e("File does not exist: ${element.file.path}");
          }
        }
      }

      // Add headers to the request
      request.headers.addAll(mainHeaders);

      // Send the request and get the streamed response
      http.StreamedResponse response = await request.send();
      final content = await response.stream.bytesToString();

      log.i('====> API Response: [${response.statusCode}] $uri');
      log.i(content);

      dynamic decodedBody;
      try {
        decodedBody = json.decode(content);
      } catch (_) {
        decodedBody = content;
      }
      final multipartResponse = Response(
        statusCode: response.statusCode,
        statusText: response.statusCode == 200 ? 'Success' : noInternetMessage,
        body: decodedBody,
      );
      _maybeForceLogoutOnExpiredToken(multipartResponse);
      return multipartResponse;
    } catch (e, s) {
      log.e("==================================== Error in putMultipartData: ${e.toString()}");
      log.e("Stacktrace: ${s.toString()}");
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  //==========================================> Patch Multipart Data <======================================
  static Future<Response> patchMultipartData(
      String uri, Map<String, String> body,
      {List<MultipartBody>? multipartBody,
        List<MultipartListBody>? multipartListBody,
        Map<String, String>? headers}) async {
    try {
      bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);

      var mainHeaders = {
        'Content-Type': 'multipart/form-data', // Change to multipart form-data
        'Authorization': 'Bearer $bearerToken'
      };

      log.i(
          '|📍📍📍|-----------------[[ PATCH MULTIPART ]] method details start -----------------|📍📍📍|');
      log.i('URL: $uri');
      log.i('Headers: ${headers ?? mainHeaders}');
      log.i('API Body: $body with ${multipartBody?.length ?? 0} file(s)');

      var request =
      http.MultipartRequest('PATCH', Uri.parse(ApiUrls.baseUrl + uri));
      request.fields.addAll(body);

      if (multipartBody != null && multipartBody.isNotEmpty) {
        for (var element in multipartBody) {
          log.i("File path: ${element.file.path}");
          String? mimeType = mime(element.file.path);
          request.files.add(http.MultipartFile(
            element.key,
            element.file.readAsBytes().asStream(),
            element.file.lengthSync(),
            filename: element.file.path.split('/').last,
            contentType: MediaType.parse(mimeType!),
          ));
        }
      }
      request.headers.addAll(mainHeaders);
      http.StreamedResponse response = await request.send();
      final content = await response.stream.bytesToString();
      log.i('====> API Response: [${response.statusCode}] $uri');
      log.i(content);

      dynamic decodedBody;
      try {
        decodedBody = json.decode(content);
      } catch (_) {
        decodedBody = content;
      }
      final multipartResponse = Response(
          statusCode: response.statusCode,
          statusText: noInternetMessage,
          body: decodedBody);
      _maybeForceLogoutOnExpiredToken(multipartResponse);
      return multipartResponse;
    } catch (e) {
      log.e("==================================== Error in patchMultipartData: ${e.toString()}");
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  //==========================================> Delete Data <======================================
  static Future<Response> deleteData(String uri, {Map<String, String>? headers, dynamic body}) async {
    bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken'
    };
    try {
      log.i(
          '|📍📍📍|-----------------[[ DELETE ]] method details start -----------------|📍📍📍|');
      log.i('URL: $uri');
      log.i('Headers: ${headers ?? mainHeaders}');
      log.i('Body: $body');

      http.Response response = await http
          .delete(Uri.parse(ApiUrls.baseUrl + uri),
          headers: headers ?? mainHeaders, body: body)
          .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      log.e("🐞🐞🐞 Error in deleteData: ${e.toString()}");
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  //==========================================> Handle Response <======================================
  static Response handleResponse(http.Response response, String uri) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      log.e(e.toString());
    }
    Response response0 = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      request: Request(
          headers: response.request!.headers,
          method: response.request!.method,
          url: response.request!.url),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );

    if (response0.statusCode != 200 &&
        response0.body != null &&
        response0.body is! String) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
      response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: errorResponse.message);
    } else if (response0.statusCode != 200 && response0.body == null) {
      response0 = const Response(statusCode: 0, statusText: noInternetMessage);
    }

    _maybeForceLogoutOnExpiredToken(response0);

    if (!_isHandlingExpiredToken &&
        response0.statusCode != null &&
        response0.statusCode! >= 500 &&
        response0.statusCode! < 600) {
      Get.offAndToNamed(AppRoutes.fiveZeroScreen);
    }

    log.i(
        '====> API Response: [${response0.statusCode}] $uri\n${response0.body}');
    return response0;
  }

  static void _maybeForceLogoutOnExpiredToken(Response response) {
    if (!_isExpiredTokenResponse(
        response.statusCode, response.body, response.statusText)) {
      return;
    }
    if (_isHandlingExpiredToken) return;
    final route = Get.currentRoute;
    if (route == AppRoutes.signInScreen ||
        route.endsWith(AppRoutes.signInScreen) ||
        route.contains('sign_in')) {
      return;
    }
    _isHandlingExpiredToken = true;
    Future.microtask(_forceLogoutToSignIn);
  }

  static bool _isExpiredTokenResponse(
      int? statusCode, dynamic body, String? statusText) {
    if (statusCode == null || statusCode == 200 || statusCode == 201) {
      return false;
    }
    final haystack = _extractErrorMessage(body, statusText).toLowerCase();
    if (haystack.isEmpty) return false;
    final hasExpire = haystack.contains('expir');
    final hasToken = haystack.contains('token') || haystack.contains('jwt');
    return hasExpire && hasToken;
  }

  static String _extractErrorMessage(dynamic body, String? statusText) {
    final parts = <String>[];
    if (statusText != null && statusText.isNotEmpty) {
      parts.add(statusText);
    }
    void collect(dynamic value, [int depth = 0]) {
      if (value == null || depth > 3) return;
      if (value is String && value.isNotEmpty) {
        parts.add(value);
        return;
      }
      if (value is List) {
        for (final item in value) {
          collect(item, depth + 1);
        }
        return;
      }
      if (value is Map) {
        collect(value['message'], depth + 1);
        collect(value['error'], depth + 1);
        collect(value['errorMessage'], depth + 1);
        collect(value['errorCode'], depth + 1);
        collect(value['code'], depth + 1);
        collect(value['status'], depth + 1);
        collect(value['data'], depth + 1);
      }
    }

    collect(body);
    return parts.join(' ');
  }

  static Future<void> _forceLogoutToSignIn() async {
    try {
      bearerToken = "";
      await PrefsHelper.remove(AppConstants.bearerToken);
      await PrefsHelper.remove(AppConstants.fcmToken);
      await PrefsHelper.remove(AppConstants.deviceId);
      await PrefsHelper.remove(AppConstants.userModelCache);
      SocketServices.socket?.disconnect();
      SocketServices.socket?.dispose();
      SocketServices.socket = null;
      if (Get.isRegistered<UserController>()) {
        await Get.find<UserController>().clearCachedUser();
      }
    } catch (e) {
      log.e('Expired-token logout failed: $e');
    } finally {
      Get.offAllNamed(AppRoutes.signInScreen);
      _isHandlingExpiredToken = false;
    }
  }
}

class MultipartBody {
  String key;
  File file;

  MultipartBody(this.key, this.file);
}

class MultipartListBody {
  String key;
  String value;
  MultipartListBody(this.key, this.value);
}