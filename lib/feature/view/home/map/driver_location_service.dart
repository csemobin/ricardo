import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/controllers/home/map/map_opt_controller.dart';
import 'package:ricardo/feature/models/socket/get_ride_driver_location.dart';
import 'package:ricardo/services/socket_services.dart';

class DriverLocationService with WidgetsBindingObserver {
  // ─────────────────────────────────────────────
  // Singleton
  // ─────────────────────────────────────────────
  static final DriverLocationService _instance =
  DriverLocationService._internal();
  factory DriverLocationService() => _instance;
  DriverLocationService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  Timer? _timer;
  String? _rideId;

  // ─────────────────────────────────────────────
  // Start emitting every 3 seconds
  // ─────────────────────────────────────────────
  void startEmitting(String rideId) {
    stop();

    _rideId = rideId;

    _emit(rideId);

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _emit(rideId);
    });

    debugPrint('✅ Started emitting for rideId: $rideId');
  }

  // ─────────────────────────────────────────────
  // Listen to response from anywhere
  // ─────────────────────────────────────────────
  void listenResponse(Function(dynamic data) onData) {
    SocketServices.socket?.off('get-ride-driver-location');

    SocketServices.socket?.on('get-ride-driver-location', (data) {
      debugPrint('📍 Driver location received: $data');
      onData(data);
    });
  }

  // ─────────────────────────────────────────────
  // Stop manually anytime
  // ─────────────────────────────────────────────
  void stop() {
    _timer?.cancel();
    _timer = null;
    SocketServices.socket?.off('get-ride-driver-location');
    debugPrint('🛑 Stopped for rideId: $_rideId');
    _rideId = null;
  }

  // ─────────────────────────────────────────────
  // Check if running
  // ─────────────────────────────────────────────
  bool get isRunning => _timer != null && _timer!.isActive;

  // ─────────────────────────────────────────────
  // App lifecycle — ONLY stop when app is terminated
  // ─────────────────────────────────────────────
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {

    // ✅ Only stop on full app termination
      case AppLifecycleState.detached:
        stop();
        debugPrint('💀 App terminated — socket stopped');
        break;

    // ❌ Keep running when notification/other app opened
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.resumed:
      case AppLifecycleState.hidden:
        debugPrint('📱 Lifecycle: $state — socket still running');
        break;

      default:
        break;
    }
  }

  // ─────────────────────────────────────────────
  // Internal emit
  // ─────────────────────────────────────────────
  void _emit(String rideId) {
    SocketServices.socket?.emit('get-driver-location', {'rideId': rideId});
    debugPrint('📡 Emitting get-driver-location rideId: $rideId');
  }
}