import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceHelper {
  static const String deviceIdKey = 'device_id';

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();

    String? deviceId = prefs.getString(deviceIdKey);

    if (deviceId != null) {
      return deviceId;
    }

    deviceId = const Uuid().v4();

    await prefs.setString(
      deviceIdKey,
      deviceId,
    );

    return deviceId;
  }
}