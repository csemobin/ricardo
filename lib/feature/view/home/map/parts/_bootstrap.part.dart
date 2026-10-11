part of '../../map_screen.dart';

extension _Bootstrap on _MapScreenState {
  Future<void> loadStatus() async {
    final bool? data = await userController.fetchActiveRideStatus();
    if (data == true) {
      final rideStatus = mapOPTController.rideStatusData.value;
      if (rideStatus != null &&
          (rideStatus.acceptRide == true ||
              rideStatus.ongoingRide == true ||
              rideStatus.arrivingRide == true ||
              rideStatus.startRide == true)) {
        final rideId = rideStatus.ride?.id;
        if (rideId != null && rideId.isNotEmpty) {
          mapOPTController.startRideLocationSync(rideId);
        }
        if (rideStatus.ongoingRide == true) {
          await loadAcceptedRideRoute();
        } else if (rideStatus.startRide == true) {
          await pickupToDestinationRoute();
        } else if (rideStatus.arrivingRide == true) {
          _haltVehicleMotion(phase: VehicleMotionPhase.stopped);
          _routeGeneration++;
          _polylines = <Polyline>{};
          _clearRoadRoute();
        }
      }
    }
  }

  void clearRideState() {
    mapOPTController.clearRideSession();
  }

  void clearRideMapUi() {
    _routeGeneration++;
    // Replace the collections so Google Maps detects removals immediately.
    _polylines = <Polyline>{};
    markers = <Marker>{};
    _clearRoadRoute();
    _remoteDriverTarget = null;
    _selfMotionEngine.reset();
    _remoteMotionEngine.reset();
    mapOPTController.remoteVehiclePhase.value = VehicleMotionPhase.idle.name;
    _liveDriverTracker.reset();
    _navCamera.reset();
    _isReFetchingRoute = false;
    if (mounted) setState(() {});
  }

  Future<void> finishRide({String? rideId}) async {
    final role = userController.userModel.value?.userProfile?.role;
    debugPrint('🧹 finishRide() called | role=$role rideId=$rideId');

    // ── 1. IMMEDIATE STATE RESET (ensures Nav Bar & Slider show up instantly) ──
    rideController.isRideAccepted.value = false;
    rideController.acceptRideModel.value = null;
    rideController.viewInMap.value = true;
    rideController.viewInMapReturn.value = false;
    rideController.rideCancel.value = false;
    rideController.isSwippedButtonShow.value = false;
    rideController.drivers.clear();

    mapOPTController.acceptedRideDriverDataStatus.value = false;
    mapOPTController.acceptedRideDriverData.value = null;
    mapOPTController.isPassengerRequest.value = false;
    mapOPTController.rideStatusData.value = null;
    mapOPTController.rideRequestReceivedAt.value = null;
    mapOPTController.isCurrentMarkerShowOrNot.value = true;
    mapOPTController.getRideDriverLocation.value = null;
    mapOPTController.animatedRemoteDriverPosition.value = null;
    mapOPTController.liveOverlayRevision.value++;

    googleSearchLocationController.isModalOn.value = false;
    googleSearchLocationController.cleanField();

    // Force UI rebuild immediately
    if (mounted) setState(() {});

    // ── 2. BACKGROUND CLEANUP ─────────────────────────────────────────────
    final resolvedRideId = rideId ?? mapOPTController.activeRideId;
    if (resolvedRideId != null && resolvedRideId.isNotEmpty) {
      mapOPTController.markRideFinished(resolvedRideId);
    }

    clearRideState(); // Redundant clearing of rideStatusData
    clearRideMapUi();
    moveToCurrentLocation();

    // Sync status with server
    await userController.fetchActiveRideStatus();

    debugPrint('🧹 finishRide() background sync done');
    DriverLocationService().stop();

    // ── 3. FINAL REFRESH ──────────────────────────────────────────────────
    userController.userModel.refresh();
    if (mounted) setState(() {});

    // ── 4. PERSISTENCE CLEANUP ────────────────────────────────────────────
    PrefsHelper.setString('status', '');
    PrefsHelper.setString('ride-accepted-data', '');
    PrefsHelper.setString('driver-status', '');
    PrefsHelper.setString('ride-accepted-driver-data', '');
  }

  Future<void> initializeMap() async {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _errorMessage = '';
    });

    final bool hasPermission = await requestLocationPermission();
    if (!hasPermission) return;

    // This-app cache may pan the camera (tiles), never the user marker/address.
    await _hintCameraFromCachedPrefs();
    if (!mounted) return;

    startLocationTracking();
    await _captureInitialDeviceHeadingOnce();
    if (!mounted) return;
    unawaited(connectSocket());
    unawaited(userController.fetchUser());
    await getCurrentLocation();
    if (!mounted) return;
    await loadAcceptedRideRoute();
  }

  /// Camera-only hint from this app's last session. Not a user location.
  Future<void> _hintCameraFromCachedPrefs() async {
    if (mapOPTController.hasValidCoordinates) return;
    final cachedLat = double.tryParse(await PrefsHelper.getString('last_lat'));
    final cachedLng = double.tryParse(await PrefsHelper.getString('last_lng'));
    if (!isValidLatLng(cachedLat, cachedLng)) return;
    if (isAppFallbackCoordinate(cachedLat, cachedLng)) return;
    _pendingCameraTarget = LatLng(cachedLat!, cachedLng!);
    if (_mapController != null) {
      await _navCamera.applyInitial(
        target: _pendingCameraTarget!,
        zoom: currentZoom,
      );
    }
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showLocationPermissionDeniedDialog(
          context,
          onRetry: initializeMap,
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showLocationPermissionPermanentlyDeniedDialog(context);
      return false;
    }

    return true;
  }

  Future<void> getCurrentLocation() async {
    final Position? position = await resolveInitialPosition();

    if (!mounted) return;

    if (position == null) {
      if (mapOPTController.hasValidCoordinates) {
        unawaited(mapOPTController.maybeRefreshAddress());
      }
      return;
    }

    _applyResolvedPosition(position);
    await mapOPTController.getLocation(knownPosition: position);
  }

  void _applyResolvedPosition(Position position) {
    final applied = mapOPTController.applyCurrentGps(
      latitude: position.latitude,
      longitude: position.longitude,
      gpsTimestamp: position.timestamp,
    );
    if (!applied) return;

    PrefsHelper.setString('last_lat', position.latitude);
    PrefsHelper.setString('last_lng', position.longitude);

    if (mounted) {
      setState(() {
        _hasLocation = true;
        _errorMessage = '';
      });
    }

    _placeInitialDeviceMarkerIfNeeded(
      LatLng(position.latitude, position.longitude),
      heading: _initialMarkerHeading(position.heading),
    );
    final isPassenger = userController.userModel.value?.userProfile?.role ==
        AppConstants.passenger;
    if (!(mapOPTController.isInActiveRide && isPassenger)) {
      _queueCameraToCurrentLocation();
    }
  }

  bool _hasValidVisualDeviceMarker() {
    final visual = _selfMotionEngine.displayedPosition ??
        mapOPTController.animatedCurrentMarkerPosition.value;
    if (visual == null) return false;
    return isValidLatLng(visual.latitude, visual.longitude) &&
        !isAppFallbackCoordinate(visual.latitude, visual.longitude);
  }

  void _placeInitialDeviceMarkerIfNeeded(LatLng target, {double heading = 0}) {
    if (!isValidLatLng(target.latitude, target.longitude)) return;
    if (isAppFallbackCoordinate(target.latitude, target.longitude)) return;
    if (_hasValidVisualDeviceMarker()) return;

    final headingDegrees = heading.isFinite ? (heading % 360 + 360) % 360 : 0.0;
    _selfMotionEngine.displayedPosition = target;
    _selfMotionEngine.displayedHeading = headingDegrees;
    mapOPTController.animatedCurrentMarkerPosition.value = target;
    mapOPTController.animatedCurrentMarkerHeading.value = headingDegrees;
    mapOPTController.liveOverlayRevision.value++;
  }

  void _queueCameraToCurrentLocation() {
    final lat = mapOPTController.currentLatitudePosition?.value;
    final lng = mapOPTController.currentLongitudePosition?.value;
    if (!isValidLatLng(lat, lng) || isAppFallbackCoordinate(lat, lng)) return;
    final target = LatLng(lat!, lng!);
    if (_mapController == null) {
      _pendingCameraTarget = target;
      return;
    }
    _pendingCameraTarget = null;
      unawaited(
        _navCamera.applyInitial(
          target: target,
          zoom: currentZoom,
        ),
      );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _navCamera.attach(controller);
    final pending = _pendingCameraTarget;
    if (pending != null) {
      _pendingCameraTarget = null;
      unawaited(
        _navCamera.applyInitial(
          target: pending,
          zoom: currentZoom,
        ),
      );
      return;
    }
    _queueCameraToCurrentLocation();
  }
}
