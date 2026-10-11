part of '../../map_screen.dart';

extension _Routes on _MapScreenState {
  Future<void> loadAcceptedRideRoute() async {
    try {
      final acceptedRide = mapOPTController.rideStatusData.value;
      if (acceptedRide == null) return;

      final bool isPassenger =
          userController.userModel.value?.userProfile?.role ==
              AppConstants.passenger;

      LatLng driverLocation;
      if (isPassenger) {
        final coords = mapOPTController
            .getRideDriverLocation.value?.driverLocation?.coordinates;
        if (coords == null || coords.length < 2) return;
        driverLocation = mapOPTController.animatedRemoteDriverPosition.value ??
            LatLng(coords[1], coords[0]);
      } else {
        final Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        driverLocation = mapOPTController.animatedCurrentMarkerPosition.value ??
            LatLng(
              currentPosition.latitude,
              currentPosition.longitude,
            );
      }

      final pickupCoords = acceptedRide.ride?.pickupLocation?.coordinates;
      if (pickupCoords == null || pickupCoords.length < 2) return;
      final LatLng pickupLocation = LatLng(pickupCoords[1], pickupCoords[0]);

      if (driverLocation.latitude == 0.0 || pickupLocation.latitude == 0.0) {
        debugPrint('Skipping — coords not ready');
        return;
      }

      final bool onGoingRide = acceptedRide.ongoingRide == true;
      if (!onGoingRide) return;

      final routeGeneration = ++_routeGeneration;
      final activeRoutePoints = await DirectionsService.getPolyline(
        driverLocation,
        pickupLocation,
      );
      if (routeGeneration != _routeGeneration) return;
      if (activeRoutePoints.isEmpty) return;

      _setRoadRoute(activeRoutePoints, pickupLocation, seed: driverLocation);

      if (!mounted) return;
      setState(() {
        markers.removeWhere((m) =>
            m.markerId.value == 'driver_location' ||
            m.markerId.value == 'pickup_location');
        _polylines = {
          _buildRidePolyline('driver_to_pickup', activeRoutePoints),
        };
        final isPassenger = userController.userModel.value?.userProfile?.role ==
            AppConstants.passenger;
        markers.add(
          Marker(
            markerId: const MarkerId('pickup_location'),
            position: pickupLocation,
            icon: (isPassenger && customUserMarker != null)
                ? customMarker!
                : customUserMarker!,
          ),
        );
      });

      final bounds = boundsFromLatLng(activeRoutePoints);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 48),
      );
    } catch (e) {
      debugPrint('_loadAcceptedRideRoute error: $e');
    }
  }

  Future<void> pickupToDestinationRoute() async {
    try {
      final acceptedRide = mapOPTController.rideStatusData.value;
      if (acceptedRide == null) return;

      final bool isPassenger =
          userController.userModel.value?.userProfile?.role ==
              AppConstants.passenger;

      LatLng driverLocation;
      if (isPassenger) {
        final coords = mapOPTController
            .getRideDriverLocation.value?.driverLocation?.coordinates;
        if (coords == null || coords.length < 2) return;
        driverLocation = mapOPTController.animatedRemoteDriverPosition.value ??
            LatLng(coords[1], coords[0]);
      } else {
        final Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        driverLocation = mapOPTController.animatedCurrentMarkerPosition.value ??
            LatLng(
              currentPosition.latitude,
              currentPosition.longitude,
            );
      }

      final destinationCoords =
          acceptedRide.ride?.destinationLocation?.coordinates;
      if (destinationCoords == null || destinationCoords.length < 2) return;
      final LatLng destinationLocation =
          LatLng(destinationCoords[1], destinationCoords[0]);

      if (driverLocation.latitude == 0.0 ||
          destinationLocation.latitude == 0.0) {
        debugPrint('Skipping — coords not ready');
        return;
      }

      final bool startRide = acceptedRide.startRide == true;
      if (!startRide) return;

      final routeGeneration = ++_routeGeneration;
      final activeRoutePoints = await DirectionsService.getPolyline(
        driverLocation,
        destinationLocation,
      );
      if (routeGeneration != _routeGeneration) return;
      if (activeRoutePoints.isEmpty) return;

      _setRoadRoute(activeRoutePoints, destinationLocation, seed: driverLocation);

      if (!mounted) return;
      setState(() {
        markers.removeWhere((m) =>
            m.markerId.value == 'driver_location' ||
            m.markerId.value == 'pickup_location');
        _polylines = {
          _buildRidePolyline('driver_to_destination', activeRoutePoints),
        };
        final isPassenger = userController.userModel.value?.userProfile?.role ==
            AppConstants.passenger;
        markers.add(
          Marker(
            markerId: const MarkerId('pickup_location'),
            position: destinationLocation,
            icon: (isPassenger && customUserMarker != null)
                ? customMarker!
                : destinationMarker!,
          ),
        );
      });

      final bounds = boundsFromLatLng(activeRoutePoints);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 48),
      );
    } catch (e) {
      debugPrint('_loadAcceptedRideRoute error: $e');
    }
  }

  void _setRoadRoute(List<LatLng> points, LatLng target, {LatLng? seed}) {
    _fullRoutePoints = List<LatLng>.from(points);
    _routeProgressIndex = 0;
    _routeTarget = target;
    _lastAnimatedRouteUpdateAt = null;
    if (seed != null && _fullRoutePoints.length >= 2) {
      final projection = _nearestPointOnRoute(seed, _fullRoutePoints);
      _routeProgressIndex = projection.segmentIndex;
    }
  }

  void _clearRoadRoute() {
    _fullRoutePoints = <LatLng>[];
    _routeProgressIndex = 0;
    _routeTarget = null;
    _lastAnimatedRouteUpdateAt = null;
  }

  void _updateRouteForAnimatedCar(LatLng driverPos) {
    final status = mapOPTController.rideStatusData.value;
    if (status?.ongoingRide != true && status?.startRide != true) return;
    if (_fullRoutePoints.isEmpty || _routeTarget == null) return;

    final now = DateTime.now();
    if (_lastAnimatedRouteUpdateAt != null &&
        now.difference(_lastAnimatedRouteUpdateAt!) <
            const Duration(milliseconds: 100)) {
      return;
    }
    _lastAnimatedRouteUpdateAt = now;
    updatePolylineForDriverPosition(driverPos, allowReroute: false);
  }

  void updatePolylineForDriverPosition(
    LatLng driverPos, {
    bool allowReroute = true,
  }) {
    if (_fullRoutePoints.isEmpty || _routeTarget == null) return;

    final projection = _nearestPointOnRoute(driverPos, _fullRoutePoints);
    final closestDist = projection.distanceMeters;

    if (closestDist > 50 && !allowReroute) return;
    if (closestDist > 50 && !_isReFetchingRoute) {
      _isReFetchingRoute = true;
      reFetchRouteFromDriver(driverPos);
      return;
    }

    _routeProgressIndex = math.max(
      _routeProgressIndex,
      math.max(0, projection.nextPointIndex - 1),
    );

    // Display remaining road ahead only — never mutate [_fullRoutePoints].
    // Trimming the source geometry removed turn vertices and caused footpath
    // chords on the next animation.
    final remaining = _fullRoutePoints.sublist(projection.nextPointIndex);
    final updatedPoints = [projection.point, ...remaining];

    if (!mounted) return;
    setState(() {
      final rideStatus = mapOPTController.rideStatusData.value;
      final bool isPickupPhase =
          rideStatus?.acceptRide == true || rideStatus?.ongoingRide == true;

      _polylines = {
        _buildRidePolyline(
          isPickupPhase ? 'driver_to_pickup' : 'driver_to_destination',
          updatedPoints,
        ),
      };
    });
  }

  /// Nearest point on the driving polyline, biased forward from
  /// [_routeProgressIndex] so sidewalk GPS at turns does not snap onto a
  /// behind / parallel segment.
  ({
    LatLng point,
    int nextPointIndex,
    double distanceMeters,
    int segmentIndex,
  }) _nearestPointOnRoute(
    LatLng position,
    List<LatLng> route, {
    bool relaxForwardBias = false,
  }) {
    if (route.length == 1) {
      return (
        point: route.first,
        nextPointIndex: 1,
        distanceMeters: Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          route.first.latitude,
          route.first.longitude,
        ),
        segmentIndex: 0,
      );
    }

    // Dense step polylines put vertices every few meters — look back ~80m /
    // 25 segments so a turn still finds the correct roadway segment.
    final lookback = relaxForwardBias ? route.length : 25;
    final searchStart =
        math.max(0, _routeProgressIndex - lookback).clamp(0, route.length - 2);
    final searchEnd = route.length - 1;

    var bestPoint = route[searchStart];
    var bestNextIndex = searchStart + 1;
    var bestSegmentIndex = searchStart;
    var bestDistance = double.infinity;
    final longitudeScale =
        math.cos(position.latitude * math.pi / 180).abs().clamp(0.01, 1.0);
    final positionX = position.longitude * longitudeScale;
    final positionY = position.latitude;

    for (var i = searchStart; i < searchEnd; i++) {
      final start = route[i];
      final end = route[i + 1];
      final startX = start.longitude * longitudeScale;
      final startY = start.latitude;
      final endX = end.longitude * longitudeScale;
      final endY = end.latitude;
      final deltaX = endX - startX;
      final deltaY = endY - startY;
      final segmentLengthSquared = deltaX * deltaX + deltaY * deltaY;
      final rawProgress = segmentLengthSquared == 0
          ? 0.0
          : ((positionX - startX) * deltaX + (positionY - startY) * deltaY) /
              segmentLengthSquared;
      final progress = rawProgress.clamp(0.0, 1.0);
      final projected = LatLng(
        startY + deltaY * progress,
        (startX + deltaX * progress) / longitudeScale,
      );
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        projected.latitude,
        projected.longitude,
      );

      if (distance < bestDistance) {
        bestDistance = distance;
        bestPoint = projected;
        bestNextIndex = i + 1;
        bestSegmentIndex = i;
      }
    }

    return (
      point: bestPoint,
      nextPointIndex: bestNextIndex,
      distanceMeters: bestDistance,
      segmentIndex: bestSegmentIndex,
    );
  }

  /// Hard snap onto the drivable route. Returns null when no route is loaded
  /// or the position is too far for a safe snap (reroute territory).
  LatLng? _snapToRoute(LatLng position, {bool advanceCursor = false}) {
    if (_fullRoutePoints.length < 2) return null;
    var projection = _nearestPointOnRoute(position, _fullRoutePoints);
    // At sharp turns sidewalk GPS can sit closer to a parallel segment —
    // widen search once before giving up.
    if (projection.distanceMeters > 35) {
      final relaxed = _nearestPointOnRoute(
        position,
        _fullRoutePoints,
        relaxForwardBias: true,
      );
      if (relaxed.distanceMeters + 5 < projection.distanceMeters) {
        projection = relaxed;
      }
    }
    // Allow lateral snap at turns (sidewalk / lane offset).
    if (projection.distanceMeters > 80) return null;
    if (advanceCursor) {
      _routeProgressIndex = math.max(
        _routeProgressIndex,
        projection.segmentIndex,
      );
    }
    return projection.point;
  }

  /// Builds a polyline path between [from] and [to] using ONLY road-projected
  /// coordinates. Raw GPS is never used as a path endpoint — GPS often drifts
  /// onto the sidewalk at turns, which would pull the marker off the road.
  List<LatLng>? _routeAnimationPath(LatLng from, LatLng to) {
    if (_fullRoutePoints.length < 2) return null;

    final fromProj = _nearestPointOnRoute(from, _fullRoutePoints);
    // Prefer road ahead for [to], but fall back to a wider search if needed.
    var toProj = _nearestPointOnRoute(to, _fullRoutePoints);
    if (toProj.distanceMeters > 40) {
      toProj = _nearestPointOnRoute(
        to,
        _fullRoutePoints,
        relaxForwardBias: true,
      );
    }

    if (fromProj.distanceMeters > 80 || toProj.distanceMeters > 80) {
      return null;
    }

    // Never emit a straight chord when GPS projects "backward" — that chord
    // cuts the corner onto footpaths. Hold on the roadway only.
    if (toProj.segmentIndex < fromProj.segmentIndex) {
      return [fromProj.point];
    }

    // Road points only — never raw GPS (sidewalk drift).
    final path = <LatLng>[fromProj.point];
    if (fromProj.nextPointIndex < toProj.nextPointIndex) {
      path.addAll(
        _fullRoutePoints.sublist(
          fromProj.nextPointIndex,
          toProj.nextPointIndex,
        ),
      );
    }
    if (Geolocator.distanceBetween(
          path.last.latitude,
          path.last.longitude,
          toProj.point.latitude,
          toProj.point.longitude,
        ) >
        0.01) {
      path.add(toProj.point);
    }

    // Same-segment hop still needs 2 points so the marker eases along the road.
    if (path.length == 1 &&
        Geolocator.distanceBetween(
              fromProj.point.latitude,
              fromProj.point.longitude,
              toProj.point.latitude,
              toProj.point.longitude,
            ) >
            0.2) {
      path.add(toProj.point);
    }

    return path.isEmpty ? null : path;
  }

  /// Position and road bearing at [progress] along a route path (0..1).
  ({LatLng position, double bearing}) _positionAlongRoutePath(
    List<LatLng> path,
    double progress,
  ) {
    if (path.length == 1) {
      return (position: path.first, bearing: 0);
    }

    final segmentLengths = <double>[];
    var totalLength = 0.0;
    for (var i = 0; i < path.length - 1; i++) {
      final length = Geolocator.distanceBetween(
        path[i].latitude,
        path[i].longitude,
        path[i + 1].latitude,
        path[i + 1].longitude,
      );
      segmentLengths.add(length);
      totalLength += length;
    }

    if (totalLength < 0.01) {
      return (
        position: path.last,
        bearing: _bearingBetween(path[path.length - 2], path.last),
      );
    }

    final targetDistance = progress.clamp(0.0, 1.0) * totalLength;
    var covered = 0.0;

    for (var i = 0; i < segmentLengths.length; i++) {
      final segmentLength = segmentLengths[i];
      if (covered + segmentLength >= targetDistance) {
        final segmentProgress = segmentLength < 0.001
            ? 0.0
            : (targetDistance - covered) / segmentLength;
        final start = path[i];
        final end = path[i + 1];
        return (
          position: LatLng(
            start.latitude + (end.latitude - start.latitude) * segmentProgress,
            start.longitude +
                (end.longitude - start.longitude) * segmentProgress,
          ),
          bearing: _bearingBetween(start, end),
        );
      }
      covered += segmentLength;
    }

    final lastStart = path[path.length - 2];
    final lastEnd = path.last;
    return (
      position: lastEnd,
      bearing: _bearingBetween(lastStart, lastEnd),
    );
  }

  /// Bearing of the segment [lookAheadMeters] ahead of [progress] (0..1).
  /// Speed-dependent look-ahead is chosen by the caller.
  double _lookAheadBearing(
    List<LatLng> path,
    double progress,
    double lookAheadMeters,
  ) {
    if (path.length < 2) return 0;
    final total = _routePathLengthMeters(path);
    if (total < 0.01) {
      return _bearingBetween(path[path.length - 2], path.last);
    }
    final ahead = progress.clamp(0.0, 1.0) * total + lookAheadMeters;
    final aheadProgress = (ahead / total).clamp(0.0, 1.0);
    return _positionAlongRoutePath(path, aheadProgress).bearing;
  }

  double? _remainingRouteMeters(LatLng from) {
    if (_fullRoutePoints.length < 2 || _routeTarget == null) return null;
    final path = _routeAnimationPath(from, _routeTarget!);
    if (path == null || path.length < 2) {
      return Geolocator.distanceBetween(
        from.latitude,
        from.longitude,
        _routeTarget!.latitude,
        _routeTarget!.longitude,
      );
    }
    return _routePathLengthMeters(path);
  }

  Future<void> reFetchRouteFromDriver(LatLng driverPos) async {
    final routeGeneration = ++_routeGeneration;
    try {
      if (_routeTarget == null) return;
      final newRoute =
          await DirectionsService.getPolyline(driverPos, _routeTarget!);
      if (routeGeneration == _routeGeneration && newRoute.isNotEmpty) {
        _setRoadRoute(newRoute, _routeTarget!, seed: driverPos);
        updatePolylineForDriverPosition(driverPos);
      }
    } catch (e) {
      debugPrint('_reFetchRouteFromDriver error: $e');
    } finally {
      _isReFetchingRoute = false;
    }
  }

  Polyline _buildRidePolyline(String id, List<LatLng> points) {
    return Polyline(
      polylineId: PolylineId(id),
      points: points,
      color: const Color(0xFF4285F4),
      width: 7,
      jointType: JointType.round,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      zIndex: 2,
    );
  }

  LatLngBounds boundsFromLatLng(List<LatLng> points) {
    double? minLat, minLng, maxLat, maxLng;
    for (var point in points) {
      minLat = minLat == null
          ? point.latitude
          : minLat < point.latitude
              ? minLat
              : point.latitude;
      minLng = minLng == null
          ? point.longitude
          : minLng < point.longitude
              ? minLng
              : point.longitude;
      maxLat = maxLat == null
          ? point.latitude
          : maxLat > point.latitude
              ? maxLat
              : point.latitude;
      maxLng = maxLng == null
          ? point.longitude
          : maxLng > point.longitude
              ? maxLng
              : point.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }
}
