import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ricardo/app/helpers/prefs_helper.dart';
import 'package:ricardo/app/utils/app_constants.dart';
import 'package:ricardo/services/socket_services.dart';

/// Pushes the driver's live GPS to the backend during an active ride so
/// passenger polls (`get-driver-location`) return fresh coordinates.
class DriverLocationService with WidgetsBindingObserver {
  static final DriverLocationService _instance =
      DriverLocationService._internal();

  factory DriverLocationService() => _instance;

  DriverLocationService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  StreamSubscription<Position>? _positionSubscription;
  Timer? _stoppedHeartbeat;
  Position? _lastEmittedPosition;
  DateTime? _lastEmittedAt;
  String? _rideId;
  String? _accessToken;

  bool get isRunning => _positionSubscription != null;

  /// Start listening location changes and push ride location to the backend.
  void startEmitting(String rideId) {
    stop();

    _rideId = rideId;
    unawaited(_loadToken());

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        // 1m so turns/short hops still produce samples (Uber-like).
        distanceFilter: 1,
      ),
    ).listen(
      (Position position) {
        if (SocketServices.socket?.connected != true) {
          debugPrint('❌ Socket disconnected');
          return;
        }

        if (!_shouldEmit(position)) return;
        _emitLocation(position);
      },
      onError: (e) {
        debugPrint('❌ Location stream error: $e');
      },
    );

    // While stationary, keep telling the backend/passenger we are still here
    // so the remote marker can settle at speed 0 instead of coasting.
    _stoppedHeartbeat = Timer.periodic(const Duration(seconds: 2), (_) {
      final last = _lastEmittedPosition;
      if (last == null) return;
      if (SocketServices.socket?.connected != true) return;
      if (last.speed >= 0.5) return;
      final lastAt = _lastEmittedAt;
      if (lastAt != null &&
          DateTime.now().difference(lastAt) < const Duration(seconds: 2)) {
        return;
      }
      _emitLocation(last);
    });

    debugPrint('✅ Started location stream for rideId: $rideId');
  }

  Future<void> _loadToken() async {
    _accessToken = await PrefsHelper.getString(AppConstants.bearerToken);
  }

  /// Push actual GPS — this is what the passenger eventually reads back.
  void _emitLocation(Position position) {
    _lastEmittedPosition = position;
    _lastEmittedAt = DateTime.now();

    final token = _accessToken;
    if (token == null || token.isEmpty) {
      unawaited(_loadToken());
    }

    SocketServices.socket?.emit('update-user-location', {
      'accessToken': _accessToken ?? token,
      'location': {
        'type': 'Point',
        'coordinates': [position.longitude, position.latitude],
      },
      'speed': position.speed.isFinite ? position.speed : 0,
      'heading': position.heading.isFinite ? position.heading : null,
      'accuracy': position.accuracy.isFinite ? position.accuracy : null,
      // Wall-clock emit time, not GPS fix time. GPS timestamps often stall
      // for 1–3s on Android; using them as updatedAt made the passenger
      // drop newer coordinates.
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      if (_rideId != null) 'rideId': _rideId,
    });

    // Also nudge the backend to fan out the latest stored point (passenger
    // apps that are mid-poll cycle pick it up immediately).
    final rideId = _rideId;
    if (rideId != null && rideId.isNotEmpty) {
      SocketServices.socket?.emit('get-driver-location', {'rideId': rideId});
    }
  }

  bool _shouldEmit(Position position) {
    if (position.accuracy > 75) return false;

    final previous = _lastEmittedPosition;
    final emittedAt = _lastEmittedAt;
    if (previous == null || emittedAt == null) return true;

    final elapsed = DateTime.now().difference(emittedAt);
    // Floor ~3 Hz while moving. Do not add a second 1s wait — that left the
    // passenger pulling a stale stored point.
    if (elapsed < const Duration(milliseconds: 300)) {
      return false;
    }

    final distance = Geolocator.distanceBetween(
      previous.latitude,
      previous.longitude,
      position.latitude,
      position.longitude,
    );
    final isStopped = position.speed >= 0 && position.speed < 0.5;
    if (!isStopped &&
        distance < 1.0 &&
        elapsed < const Duration(milliseconds: 700)) {
      return false;
    }
    if (isStopped && elapsed < const Duration(seconds: 2)) return false;
    if (position.accuracy > 35 && distance < 5) return false;
    return true;
  }

  void stop() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _stoppedHeartbeat?.cancel();
    _stoppedHeartbeat = null;
    _lastEmittedPosition = null;
    _lastEmittedAt = null;

    debugPrint('🛑 Stopped location stream for rideId: $_rideId');

    _rideId = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        stop();
        debugPrint('💀 App terminated');
        break;

      case AppLifecycleState.resumed:
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        debugPrint('📱 Lifecycle: $state');
        break;
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stop();
  }
}
