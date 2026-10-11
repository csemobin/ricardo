part of '../../map_screen.dart';

extension _Markers on _MapScreenState {
  Future<void> initMarkers() async {
    const markerSize = 48.0;
    const configuration = ImageConfiguration(size: Size.square(markerSize));

    customMarker = await BitmapDescriptor.asset(
      configuration,
      "assets/images/passenger_location_marker.png",
      width: markerSize,
      height: markerSize,
    );
    customCarMarker = await BitmapDescriptor.asset(
      configuration,
      "assets/images/car_marker.png",
      width: markerSize,
      height: markerSize,
    );
    customUserMarker = await BitmapDescriptor.asset(
      configuration,
      'assets/images/passenger_marker.png',
      width: markerSize,
      height: markerSize,
    );
    destinationMarker = await BitmapDescriptor.asset(
      configuration,
      'assets/images/destination_marker.png',
      width: markerSize,
      height: markerSize,
    );
    mapOPTController.markerAssetsRevision.value++;
  }

  void _bindVehicleMotionEngines() {
    _selfMotionEngine
      ..displayedPosition = mapOPTController.animatedCurrentMarkerPosition.value
      ..displayedHeading = mapOPTController.animatedCurrentMarkerHeading.value
      ..alongPath = _positionAlongRoutePath
      ..lookAheadBearing = _lookAheadBearing
      ..isMounted = () {
        return mounted;
      }
      ..onFrame = (position, heading) {
        mapOPTController.animatedCurrentMarkerPosition.value = position;
        mapOPTController.animatedCurrentMarkerHeading.value = heading;
        mapOPTController.animatedCurrentMarkerSpeedMps.value =
            _selfMotionEngine.smoothedSpeedMps;
        mapOPTController.liveOverlayRevision.value++;
        _logMarkerRender(position, heading, 'self');
        final isPassenger = userController.userModel.value?.userProfile?.role ==
            AppConstants.passenger;
        if (!isPassenger) {
          _followTrackingVehicle(position);
        }
      }
      ..onSettled = () {
        final pos = _selfMotionEngine.displayedPosition;
        if (pos != null) updatePolylineForDriverPosition(pos);
      };

    _remoteMotionEngine
      ..displayedPosition = mapOPTController.animatedRemoteDriverPosition.value
      ..displayedHeading = mapOPTController.animatedRemoteDriverHeading.value
      ..alongPath = _positionAlongRoutePath
      ..lookAheadBearing = _lookAheadBearing
      ..isMounted = () {
        return mounted;
      }
      ..onFrame = (position, heading) {
        mapOPTController.animatedRemoteDriverPosition.value = position;
        mapOPTController.animatedRemoteDriverHeading.value = heading;
        mapOPTController.animatedRemoteDriverSpeedMps.value =
            _remoteMotionEngine.smoothedSpeedMps;
        mapOPTController.remoteVehiclePhase.value =
            _remoteMotionEngine.phase.name;
        mapOPTController.liveOverlayRevision.value++;
        _logMarkerRender(position, heading, 'remote');
        final isPassenger = userController.userModel.value?.userProfile?.role ==
            AppConstants.passenger;
        if (isPassenger) {
          _followTrackingVehicle(position);
        }
      }
      ..onSettled = () {
        final isPassenger = userController.userModel.value?.userProfile?.role ==
            AppConstants.passenger;
        final pos = _remoteMotionEngine.displayedPosition;
        if (isPassenger && pos != null) {
          _updateRouteForAnimatedCar(pos);
          updatePolylineForDriverPosition(pos);
        }
      };
  }

  Set<Marker> buildMarkers() {
    final Set<Marker> result = {};
    final markerAssetsReady = mapOPTController.markerAssetsRevision.value > 0;
    final carIcon = markerAssetsReady && customCarMarker != null
        ? customCarMarker!
        : BitmapDescriptor.defaultMarker;

    final currentLat = mapOPTController.currentLatitudePosition?.value ?? 0.0;
    final currentLng = mapOPTController.currentLongitudePosition?.value ?? 0.0;
    final currentPosition =
        mapOPTController.animatedCurrentMarkerPosition.value ??
            LatLng(currentLat, currentLng);
    final rideStatus = mapOPTController.rideStatusData.value;

    final bool isPassenger =
        userController.userModel.value?.userProfile?.role ==
            AppConstants.passenger;

    if (mapOPTController.hasValidCoordinates) {
      final double heading =
          mapOPTController.animatedCurrentMarkerHeading.value;
      final BitmapDescriptor selfIcon = isPassenger
          ? (markerAssetsReady
              ? (customMarker ?? BitmapDescriptor.defaultMarker)
              : BitmapDescriptor.defaultMarker)
          : carIcon;
      final bool inActiveRide = rideStatus?.acceptRide == true ||
          rideStatus?.ongoingRide == true ||
          rideStatus?.arrivingRide == true ||
          rideStatus?.startRide == true ||
          rideStatus?.completeRide == true;
      final BitmapDescriptor activeIcon = carIcon;

      result.add(
        Marker(
          markerId: const MarkerId('currentPassenger'),
          position: currentPosition,
          icon: isPassenger ? selfIcon : (inActiveRide ? activeIcon : selfIcon),
          rotation: !isPassenger ? heading : 0,
          anchor:
              !isPassenger ? const Offset(0.5, 0.5) : const Offset(0.5, 1.0),
          flat: !isPassenger,
        ),
      );
    }
    if (isPassenger && mapOPTController.showPassengerDriverCar) {
      final driverCoords = mapOPTController
          .getRideDriverLocation.value?.driverLocation?.coordinates;
      if (driverCoords != null && driverCoords.length >= 2) {
        result.add(Marker(
          markerId: const MarkerId('live_driver'),
          position: mapOPTController.animatedRemoteDriverPosition.value ??
              LatLng(driverCoords[1], driverCoords[0]),
          icon: carIcon,
          rotation: mapOPTController.animatedRemoteDriverHeading.value,
          anchor: const Offset(0.5, 0.5),
          flat: true,
        ));
      }
    }

    for (final m in markers) {
      if (m.markerId.value != 'currentPassenger') {
        result.add(m);
      }
    }

    final bool isRouteActive = markers.any(
      (m) =>
          m.markerId.value == 'Pick-Up-Location' ||
          m.markerId.value == 'Destination' ||
          m.markerId.value == 'pickup_location' ||
          m.markerId.value == 'destination_location',
    );

    final bool showDriverIcons =
        rideController.viewInMapReturn.value || !isRouteActive;

    if (showDriverIcons) {
      final drivers = rideController.drivers;
      for (var driver in drivers) {
        final coords = driver.location?.coordinates;
        if (coords != null && coords.length == 2) {
          result.add(Marker(
            markerId: MarkerId(driver.sId ?? UniqueKey().toString()),
            position: LatLng(coords[1], coords[0]),
            icon: carIcon,
            onTap: () => showDriverInfoDialog(context, driver, rideController),
          ));
        }
      }
    }

    return result;
  }

  void _logMarkerRender(LatLng position, double heading, String source) {
    if (!_liveLocationDiag) return;
    final now = DateTime.now();
    final last = _lastMarkerRenderLogAt;
    if (last != null &&
        now.difference(last) < const Duration(milliseconds: 500)) {
      return;
    }
    _lastMarkerRenderLogAt = now;
    debugPrint(
      'MARKER_RENDER ${now.toIso8601String()} '
      'src=$source '
      'visual=${position.latitude.toStringAsFixed(6)},'
      '${position.longitude.toStringAsFixed(6)} '
      'heading=${heading.toStringAsFixed(1)} '
      'target=${(_remoteMotionEngine.latestTargetPosition ?? _selfMotionEngine.latestTargetPosition)?.latitude.toStringAsFixed(6)}',
    );
  }

  void _animateCurrentMarkerTo(
    LatLng target, {
    required double reportedSpeedMps,
    double? reportedHeading,
  }) {
    if (_selfMotionEngine.phase == VehicleMotionPhase.arrived &&
        mapOPTController.rideStatusData.value?.completeRide != true) {
      _selfMotionEngine.halt(to: VehicleMotionPhase.idle);
    }

    final visual = _selfMotionEngine.displayedPosition ??
        mapOPTController.animatedCurrentMarkerPosition.value;
    final hasValidVisual = visual != null &&
        isValidLatLng(visual.latitude, visual.longitude) &&
        !isAppFallbackCoordinate(visual.latitude, visual.longitude);
    if (!hasValidVisual) {
      _placeInitialDeviceMarkerIfNeeded(
        target,
        heading: _initialMarkerHeading(reportedHeading),
      );
      return;
    }

    final start = visual;
    final liveTarget = _liveMarkerTarget(target);
    final isStopped = !reportedSpeedMps.isFinite || reportedSpeedMps < 0.5;

    unawaited(_ensureInitialNavCamera(start));
    _selfMotionEngine.observe(
      target: liveTarget,
      path: [liveTarget],
      observedSpeedMps: reportedSpeedMps,
      isStopped: isStopped,
      offRoute: _fullRoutePoints.length < 2,
      observedHeading: reportedHeading,
    );
  }

  /// Passenger live-car update from a validated socket sample.
  void _applyLiveDriverSample(LiveDriverLocationSample sample) {
    if (_remoteMotionEngine.phase == VehicleMotionPhase.arrived &&
        mapOPTController.rideStatusData.value?.completeRide != true) {
      _remoteMotionEngine.halt(to: VehicleMotionPhase.idle);
    }

    final rawTarget = sample.position;
    final start = _remoteMotionEngine.displayedPosition ??
        mapOPTController.animatedRemoteDriverPosition.value ??
        sample.previousPosition ??
        rawTarget;
    final target = _liveMarkerTarget(rawTarget);

    final hasValidRemoteVisual = () {
      final visual = _remoteMotionEngine.displayedPosition ??
          mapOPTController.animatedRemoteDriverPosition.value;
      return visual != null &&
          isValidLatLng(visual.latitude, visual.longitude) &&
          !isAppFallbackCoordinate(visual.latitude, visual.longitude);
    }();
    if (!hasValidRemoteVisual) {
      final heading = sample.headingDegrees.isFinite
          ? (sample.headingDegrees % 360 + 360) % 360
          : 0.0;
      _remoteMotionEngine.displayedPosition = target;
      _remoteMotionEngine.displayedHeading = heading;
      _remoteMotionEngine.latestTargetPosition = target;
      _remoteMotionEngine.latestTargetRotation = heading;
      mapOPTController.animatedRemoteDriverPosition.value = target;
      mapOPTController.animatedRemoteDriverHeading.value = heading;
      mapOPTController.liveOverlayRevision.value++;
    }

    if (_liveLocationDiag) {
      debugPrint(
        'NEW_TARGET ${DateTime.now().toIso8601String()} '
        'seq=${sample.sequence} '
        'target=${target.latitude.toStringAsFixed(6)},'
        '${target.longitude.toStringAsFixed(6)} '
        'visual=${start.latitude.toStringAsFixed(6)},'
        '${start.longitude.toStringAsFixed(6)} '
        'speed=${sample.speedMps.toStringAsFixed(2)} '
        'dist=${sample.distanceFromPreviousMeters.toStringAsFixed(1)}m '
        'interval=${sample.intervalFromPrevious?.inMilliseconds ?? -1}ms '
        'dup=${sample.isDuplicate} stopped=${sample.isStopped}',
      );
    }

    if (sample.isDuplicate) {
      return;
    }

    mapOPTController.animatedRemoteDriverSpeedMps.value = sample.speedMps;

    unawaited(_ensureInitialNavCamera(start));
    _remoteMotionEngine.observe(
      target: target,
      path: [target],
      observedSpeedMps: sample.speedMps,
      isStopped: sample.isStopped,
      offRoute: _fullRoutePoints.length < 2,
      sampleInterval: sample.intervalFromPrevious,
      observedHeading: sample.headingDegrees,
    );
  }

  LatLng _liveMarkerTarget(LatLng rawTarget) {
    if (_fullRoutePoints.length < 2) return rawTarget;
    final snapped = _snapToRoute(rawTarget, advanceCursor: true);
    if (snapped == null) {
      if (!_isReFetchingRoute && _routeTarget != null) {
        _isReFetchingRoute = true;
        reFetchRouteFromDriver(rawTarget);
      }
      return rawTarget;
    }
    final snapMeters = Geolocator.distanceBetween(
      rawTarget.latitude,
      rawTarget.longitude,
      snapped.latitude,
      snapped.longitude,
    );
    return snapMeters <= 20 ? snapped : rawTarget;
  }

  void _haltVehicleMotion({
    VehicleMotionPhase phase = VehicleMotionPhase.arrived,
  }) {
    _selfMotionEngine.halt(to: phase);
    _remoteMotionEngine.halt(to: phase);
    _remoteDriverTarget = null;
    mapOPTController.remoteVehiclePhase.value = phase.name;
  }

  double _routePathLengthMeters(List<LatLng> path) {
    var total = 0.0;
    for (var i = 0; i < path.length - 1; i++) {
      total += Geolocator.distanceBetween(
        path[i].latitude,
        path[i].longitude,
        path[i + 1].latitude,
        path[i + 1].longitude,
      );
    }
    return total;
  }

  double _bearingBetween(LatLng from, LatLng to) {
    final fromLat = from.latitude * math.pi / 180;
    final toLat = to.latitude * math.pi / 180;
    final lngDelta = (to.longitude - from.longitude) * math.pi / 180;
    final y = math.sin(lngDelta) * math.cos(toLat);
    final x = math.cos(fromLat) * math.sin(toLat) -
        math.sin(fromLat) * math.cos(toLat) * math.cos(lngDelta);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }
}
