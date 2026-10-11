import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Camera follow for ride tracking.
///
/// The map tracks the **current** vehicle pose so the marker stays centered.
/// Bearing stays north-up (0°). Marker rotation is separate (GPS).
class MapNavigationCamera {
  MapNavigationCamera({required this.onProgrammaticMove});

  final void Function({Duration hold}) onProgrammaticMove;

  GoogleMapController? controller;

  /// When false, the user has panned and owns the camera.
  bool followEnabled = true;

  /// True while we are moving the camera. User-gesture callbacks must ignore.
  bool programmatic = false;

  bool initialApplied = false;

  DateTime? _lastFollowAt;
  int _programmaticGen = 0;

  static const Duration _minFollowInterval = Duration(milliseconds: 32);
  static const double northUpBearing = 0;

  void attach(GoogleMapController mapController) {
    controller = mapController;
  }

  void pauseFollow() {
    followEnabled = false;
  }

  void resumeFollow() {
    followEnabled = true;
  }

  void markProgrammatic({Duration hold = const Duration(milliseconds: 400)}) {
    programmatic = true;
    final gen = ++_programmaticGen;
    onProgrammaticMove(hold: hold);
    Future<void>.delayed(hold, () {
      if (gen == _programmaticGen) programmatic = false;
    });
  }

  void markIdle() {
    // Camera idle after a programmatic move is not a user gesture.
  }

  void reset() {
    followEnabled = true;
    programmatic = false;
    initialApplied = false;
    _lastFollowAt = null;
  }

  void dispose() {
    controller = null;
    _lastFollowAt = null;
  }

  Future<void> applyInitial({
    required LatLng target,
    required double zoom,
  }) async {
    final map = controller;
    if (map == null || initialApplied) return;
    initialApplied = true;
    markProgrammatic(hold: const Duration(milliseconds: 900));
    try {
      await map.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            zoom: zoom,
            bearing: northUpBearing,
            tilt: 0,
          ),
        ),
        duration: const Duration(milliseconds: 650),
      );
    } catch (_) {
      try {
        await map.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: target,
              zoom: zoom,
              bearing: northUpBearing,
              tilt: 0,
            ),
          ),
        );
      } catch (_) {}
    }
  }

  /// Keep the vehicle in the center of the viewport.
  void followVisual({
    required LatLng visual,
    required double zoom,
  }) {
    final map = controller;
    if (map == null || !followEnabled) return;

    final now = DateTime.now();
    final lastAt = _lastFollowAt;
    if (lastAt != null && now.difference(lastAt) < _minFollowInterval) {
      return;
    }
    _lastFollowAt = now;

    markProgrammatic(hold: const Duration(milliseconds: 250));
    try {
      map.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: visual,
            zoom: zoom,
            bearing: northUpBearing,
            tilt: 0,
          ),
        ),
      );
    } catch (_) {}
  }

  Future<void> recapture({
    required LatLng target,
    required double zoom,
  }) async {
    final map = controller;
    if (map == null) return;
    followEnabled = true;
    markProgrammatic(hold: const Duration(milliseconds: 900));
    try {
      await map.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            zoom: zoom,
            bearing: northUpBearing,
            tilt: 0,
          ),
        ),
        duration: const Duration(milliseconds: 700),
      );
    } catch (_) {
      try {
        map.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: target,
              zoom: zoom,
              bearing: northUpBearing,
              tilt: 0,
            ),
          ),
        );
      } catch (_) {}
    }
  }
}
