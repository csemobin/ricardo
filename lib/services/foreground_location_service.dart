import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

class ForegroundLocationService {

  // ✅ Initialize - FIXED (removed 'id')
  static void initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'ride_tracking_channel',
        channelName: 'Ride Tracking',
        channelDescription: 'This notification appears when tracking your location',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  // ✅ Start - FIXED (returns bool, not ServiceRequestResult.error)
  static Future<bool> startLocationTracking() async {
    // Check permission first
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    // ✅ FIXED - use startService with serviceId parameter
    final result = await FlutterForegroundTask.startService(
      serviceId: 100,
      notificationTitle: 'Faster pickups, safer rides',
      notificationText: 'When you\'re riding with us, your location is being collected for faster pickups and safety features.',
      notificationButtons: [
        const NotificationButton(id: 'learn_more', text: 'LEARN MORE'),
      ],
      callback: startCallback,
    );

    return true;
  }

  // ✅ Stop - FIXED
  static Future<bool> stopLocationTracking() async {
    final result = await FlutterForegroundTask.stopService();
    return true;
  }

  // ✅ Check if running
  static Future<bool> isRunningService() async {
    return await FlutterForegroundTask.isRunningService;
  }
}

// ✅ Callback
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

// ✅ Task Handler - FIXED (all methods return Future<void>)
class LocationTaskHandler extends TaskHandler {
  StreamSubscription<Position>? _positionStream;

  // ✅ FIXED - returns Future<void>
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('Foreground service started');

    // Start location tracking
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      print('Location: ${position.latitude}, ${position.longitude}');

      // Send to UI
      FlutterForegroundTask.sendDataToMain({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Called every 5 seconds
    // Remove print in production or use logger
  }

  // ✅ FIXED - returns Future<void>
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('Foreground service stopped');
    await _positionStream?.cancel();
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'learn_more') {
      FlutterForegroundTask.launchApp('/');
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
  }

  @override
  void onNotificationDismissed() {
    // Not dismissable
  }
}