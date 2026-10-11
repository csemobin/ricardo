import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Visual motion phase for the live car marker. Distinct from last GPS.
enum VehicleMotionPhase { idle, moving, stopping, stopped, arrived }

typedef VehiclePathPose = ({LatLng position, double bearing});
typedef VehicleAlongPath = VehiclePathPose Function(
  List<LatLng> path,
  double progress,
);
typedef VehicleLookAhead = double Function(
  List<LatLng> path,
  double progress,
  double lookAheadMeters,
);
typedef VehicleFrameCallback = void Function(LatLng position, double heading);

/// Applies each new GPS/socket sample to the car marker immediately.
///
/// The latest valid coordinate is the source of truth. [observe] replaces
/// [latestTargetPosition] and the displayed pose in the same call. It does
/// not chase at car speed, queue hops, or keep moving toward a stale point.
class VehicleMotionEngine {
  VehicleMotionEngine({this.smoothObservedSpeed = true});

  static const double stoppedSpeedMps = 0.5;
  static const double settleDistanceMeters = 0.45;
  static const double noiseTargetMeters = 0.7;
  static const double snapJumpMeters = 80;

  /// `car_marker.png` faces north (windshield at top). Marker.rotation is
  /// clockwise from north, so no extra offset.
  static const double carIconRotationOffset = 0;

  /// When false, [observe] treats [observedSpeedMps] as already smoothed.
  final bool smoothObservedSpeed;

  VehicleAlongPath? alongPath;
  VehicleLookAhead? lookAheadBearing;
  VehicleFrameCallback? onFrame;
  void Function()? onSettled;
  bool Function()? isMounted;

  VehicleMotionPhase phase = VehicleMotionPhase.idle;
  int generation = 0;

  LatLng? displayedPosition;
  double displayedHeading = 0;
  double smoothedSpeedMps = 0;

  LatLng? latestTargetPosition;
  double latestTargetRotation = 0;
  DateTime? lastLocationTimestamp;

  void observe({
    required LatLng target,
    required List<LatLng> path,
    required double observedSpeedMps,
    required bool isStopped,
    bool offRoute = false,
    double? remainingToDestinationMeters,
    Duration? sampleInterval,
    double? observedHeading,
  }) {
    if (phase == VehicleMotionPhase.arrived) return;

    final now = DateTime.now();
    final previousTarget = latestTargetPosition;
    final previousAt = lastLocationTimestamp;
    lastLocationTimestamp = now;
    latestTargetPosition = target;

    final interval = sampleInterval ??
        (previousAt == null ? null : now.difference(previousAt));
    _applyRealSpeed(
      observed: observedSpeedMps,
      isStopped: isStopped,
      gpsHopMeters:
          previousTarget == null ? 0 : _distance(previousTarget, target),
      sampleInterval: interval,
    );

    final from = displayedPosition;
    double? movementBearing;
    if (from != null && _distance(from, target) >= 1.0) {
      movementBearing = _bearing(from, target);
    }
    final resolvedHeading = resolveTravelHeading(
      reported: observedHeading,
      speedMps: smoothedSpeedMps,
      isStopped: isStopped,
      movementBearing: movementBearing,
      fallback: displayedHeading,
    );

    // Newest point wins: the marker is this sample, not a leftover hop.
    _syncDisplayedToLatest(
      heading: resolvedHeading,
      isStopped: isStopped || smoothedSpeedMps < stoppedSpeedMps,
    );
  }

  void halt({VehicleMotionPhase to = VehicleMotionPhase.arrived}) {
    generation++;
    smoothedSpeedMps = 0;
    latestTargetPosition = null;
    lastLocationTimestamp = null;
    phase = to;
  }

  void reset() {
    halt(to: VehicleMotionPhase.idle);
    displayedPosition = null;
    displayedHeading = 0;
    latestTargetRotation = 0;
  }

  void dispose() {
    halt(to: VehicleMotionPhase.idle);
    alongPath = null;
    lookAheadBearing = null;
    onFrame = null;
    onSettled = null;
    isMounted = null;
  }

  /// Marker speed is the real car speed: GPS `speed` when present, otherwise
  /// distance between the last two real points divided by elapsed time.
  void _applyRealSpeed({
    required double observed,
    required bool isStopped,
    required double gpsHopMeters,
    required Duration? sampleInterval,
  }) {
    final intervalSec = sampleInterval == null
        ? 0.0
        : sampleInterval.inMilliseconds / 1000.0;
    final implied = (intervalSec >= 0.05 && gpsHopMeters >= 0.5)
        ? gpsHopMeters / intervalSec
        : 0.0;

    if (observed.isFinite && observed >= stoppedSpeedMps) {
      smoothedSpeedMps = observed;
      return;
    }
    if (implied >= stoppedSpeedMps) {
      smoothedSpeedMps = implied;
      return;
    }
    if (isStopped || gpsHopMeters < settleDistanceMeters) {
      smoothedSpeedMps = 0;
    }
  }

  /// Place the marker on [latestTargetPosition] now.
  void _syncDisplayedToLatest({
    required double heading,
    required bool isStopped,
  }) {
    final target = latestTargetPosition;
    if (target == null) return;

    generation++;
    displayedPosition = target;
    displayedHeading = heading;
    latestTargetRotation = heading;
    phase = isStopped ? VehicleMotionPhase.stopped : VehicleMotionPhase.moving;
    _emitFrame();
    onSettled?.call();
  }

  void _emitFrame() {
    final pos = displayedPosition;
    if (pos == null) return;
    onFrame?.call(
      pos,
      (displayedHeading + carIconRotationOffset + 360) % 360,
    );
  }

  static double lerpHeading(double from, double to, double t) {
    final delta = shortestAngleDelta(from, to);
    return (from + delta * t.clamp(0.0, 1.0) + 360) % 360;
  }

  static double resolveTravelHeading({
    required double? reported,
    required double speedMps,
    required bool isStopped,
    required double? movementBearing,
    required double fallback,
  }) {
    if (isStopped || speedMps < stoppedSpeedMps) {
      return fallback;
    }

    final reportedOk = reported != null && reported.isFinite && reported >= 0;
    if (reportedOk) {
      final heading = (reported % 360 + 360) % 360;
      if (heading == 0 && movementBearing != null) {
        final delta = shortestAngleDelta(0, movementBearing).abs();
        if (delta > 45) return (movementBearing + 360) % 360;
      }
      return heading;
    }

    if (movementBearing != null) {
      return (movementBearing + 360) % 360;
    }
    return fallback;
  }

  static double lookAheadMeters(double speedMps) {
    return (0.8 * speedMps).clamp(6.0, 22.0);
  }

  static double shortestAngleDelta(double from, double to) {
    return ((to - from + 540) % 360) - 180;
  }

  static double stepHeading(double current, double target, double maxStep) {
    final delta = shortestAngleDelta(current, target);
    if (delta.abs() <= maxStep) return (target + 360) % 360;
    return (current + delta.sign * maxStep + 360) % 360;
  }

  static double pathLengthMeters(List<LatLng> path) {
    var total = 0.0;
    for (var i = 0; i < path.length - 1; i++) {
      total += _distance(path[i], path[i + 1]);
    }
    return total;
  }

  static double _bearing(LatLng from, LatLng to) {
    final fromLat = from.latitude * math.pi / 180;
    final toLat = to.latitude * math.pi / 180;
    final lngDelta = (to.longitude - from.longitude) * math.pi / 180;
    final y = math.sin(lngDelta) * math.cos(toLat);
    final x = math.cos(fromLat) * math.sin(toLat) -
        math.sin(fromLat) * math.cos(toLat) * math.cos(lngDelta);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  static double _distance(LatLng a, LatLng b) {
    return Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
  }
}
