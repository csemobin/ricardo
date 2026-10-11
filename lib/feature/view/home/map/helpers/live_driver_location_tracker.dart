import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Turns each backend location payload into a marker sample.
///
/// The backend already decided what to share. This class only:
/// - rejects impossible coordinates (NaN / 0,0)
/// - records the previous point for heading/speed
/// It does not delay, queue, or drop a newer point because of timestamps.
class LiveDriverLocationTracker {
  static const double stoppedSpeedMps = 0.5;
  static const double duplicateDistanceMeters = 0.8;

  LatLng? lastAccepted;
  DateTime? lastAcceptedAt;
  DateTime? lastGpsTimestamp;
  double lastSpeedMps = 0;
  double lastHeading = 0;
  double lastAccuracyMeters = 0;
  int acceptedSequence = 0;
  Duration? lastUpdateInterval;

  void reset() {
    lastAccepted = null;
    lastAcceptedAt = null;
    lastGpsTimestamp = null;
    lastSpeedMps = 0;
    lastHeading = 0;
    lastAccuracyMeters = 0;
    acceptedSequence = 0;
    lastUpdateInterval = null;
  }

  LiveDriverLocationSample? accept({
    required double latitude,
    required double longitude,
    DateTime? gpsTimestamp,
    double? speedMps,
    double? headingDegrees,
    double? accuracyMeters,
    DateTime? receivedAt,
  }) {
    if (!_isValidCoordinate(latitude, longitude)) return null;

    final now = receivedAt ?? DateTime.now();
    final target = LatLng(latitude, longitude);
    final previous = lastAccepted;
    final previousAt = lastAcceptedAt;
    final distance = previous == null
        ? 0.0
        : Geolocator.distanceBetween(
            previous.latitude,
            previous.longitude,
            target.latitude,
            target.longitude,
          );
    final interval = previousAt == null ? null : now.difference(previousAt);
    if (interval != null) lastUpdateInterval = interval;

    final isDuplicate = previous != null && distance < duplicateDistanceMeters;
    final resolvedSpeed = _resolveSpeed(
      reported: speedMps,
      distanceMeters: distance,
      interval: interval,
      previousSpeed: lastSpeedMps,
      preferStopped: isDuplicate,
    );
    final heading = _resolveHeading(
      reported: headingDegrees,
      previous: previous,
      target: target,
      distance: distance,
      isStopped: resolvedSpeed < stoppedSpeedMps,
    );

    lastAccepted = isDuplicate ? previous : target;
    lastAcceptedAt = now;
    if (gpsTimestamp != null) lastGpsTimestamp = gpsTimestamp;
    lastSpeedMps = resolvedSpeed;
    lastHeading = heading;
    if (accuracyMeters != null && accuracyMeters.isFinite) {
      lastAccuracyMeters = accuracyMeters;
    }
    if (!isDuplicate) acceptedSequence += 1;

    return LiveDriverLocationSample(
      position: lastAccepted!,
      previousPosition: previous,
      receivedAt: now,
      gpsTimestamp: gpsTimestamp ?? lastGpsTimestamp,
      speedMps: resolvedSpeed,
      headingDegrees: heading,
      accuracyMeters: lastAccuracyMeters,
      distanceFromPreviousMeters: distance,
      intervalFromPrevious: interval,
      sequence: acceptedSequence,
      isDuplicate: isDuplicate,
      isStopped: resolvedSpeed < stoppedSpeedMps,
    );
  }

  double _resolveHeading({
    required double? reported,
    required LatLng? previous,
    required LatLng target,
    required double distance,
    required bool isStopped,
  }) {
    if (isStopped) return lastHeading;
    final movement = previous != null && distance >= 1.0
        ? _bearingBetween(previous, target)
        : null;
    if (reported != null && reported.isFinite && reported >= 0) {
      final h = (reported % 360 + 360) % 360;
      if (h == 0 && movement != null) {
        final delta = ((movement - 0 + 540) % 360) - 180;
        if (delta.abs() > 45) return movement;
      }
      return h;
    }
    return movement ?? lastHeading;
  }

  double _resolveSpeed({
    required double? reported,
    required double distanceMeters,
    required Duration? interval,
    required double previousSpeed,
    required bool preferStopped,
  }) {
    double raw;
    if (reported != null && reported.isFinite && reported >= 0) {
      raw = reported;
    } else {
      final seconds = (interval?.inMilliseconds ?? 0) / 1000.0;
      if (seconds <= 0) {
        raw = preferStopped ? 0.0 : previousSpeed;
      } else if (distanceMeters < duplicateDistanceMeters) {
        raw = 0.0;
      } else {
        raw = distanceMeters / seconds;
      }
    }
    if (preferStopped || raw < stoppedSpeedMps) {
      lastSpeedMps = 0;
      return 0;
    }
    lastSpeedMps = raw;
    return raw;
  }

  static bool _isValidCoordinate(double lat, double lng) {
    if (!lat.isFinite || !lng.isFinite) return false;
    if (lat == 0 && lng == 0) return false;
    if (lat < -90 || lat > 90) return false;
    if (lng < -180 || lng > 180) return false;
    return true;
  }

  static double _bearingBetween(LatLng from, LatLng to) {
    final fromLat = from.latitude * math.pi / 180;
    final toLat = to.latitude * math.pi / 180;
    final lngDelta = (to.longitude - from.longitude) * math.pi / 180;
    final y = math.sin(lngDelta) * math.cos(toLat);
    final x = math.cos(fromLat) * math.sin(toLat) -
        math.sin(fromLat) * math.cos(toLat) * math.cos(lngDelta);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }
}

class LiveDriverLocationSample {
  final LatLng position;
  final LatLng? previousPosition;
  final DateTime receivedAt;
  final DateTime? gpsTimestamp;
  final double speedMps;
  final double headingDegrees;
  final double accuracyMeters;
  final double distanceFromPreviousMeters;
  final Duration? intervalFromPrevious;
  final int sequence;
  final bool isDuplicate;
  final bool isStopped;

  const LiveDriverLocationSample({
    required this.position,
    required this.previousPosition,
    required this.receivedAt,
    required this.gpsTimestamp,
    required this.speedMps,
    required this.headingDegrees,
    required this.accuracyMeters,
    required this.distanceFromPreviousMeters,
    required this.intervalFromPrevious,
    required this.sequence,
    required this.isDuplicate,
    required this.isStopped,
  });
}
