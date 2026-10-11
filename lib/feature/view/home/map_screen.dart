library map_screen;

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:ricardo/feature/models/home/ride_status_model.dart'
    as RideModel;
import 'package:ricardo/feature/models/socket/accept_ride_model.dart';
import 'package:ricardo/app/helpers/screen_awake_helper.dart';
import 'package:ricardo/feature/view/home/map/helpers/live_driver_location_tracker.dart';
import 'package:ricardo/feature/view/home/map/helpers/map_navigation_camera.dart';
import 'link_export_file.dart';

part 'map/parts/_bootstrap.part.dart';
part 'map/parts/_markers.part.dart';
part 'map/parts/_routes.part.dart';
part 'map/parts/_sockets.part.dart';
part 'map/parts/_tracking.part.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  final userController = Get.find<UserController>();
  final googleSearchLocationController =
      Get.find<GoogleSearchLocationController>();
  final rideController = Get.find<RideController>();
  final mapOPTController = Get.find<MapOPTController>();

  GoogleMapController? _mapController;
  Set<Marker> markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  StreamSubscription<Position>? positionStream;

  /// Full driving-route geometry (immutable until refetch). Never trim this —
  /// trimming destroyed turn vertices and let the car cut corners / footpaths.
  List<LatLng> _fullRoutePoints = [];

  /// Forward progress cursor into [_fullRoutePoints] so snaps prefer the road
  /// ahead through turns instead of a nearer sidewalk-side segment behind.
  int _routeProgressIndex = 0;
  LatLng? _routeTarget;
  bool _isReFetchingRoute = false;
  int _routeGeneration = 0;
  DateTime? _lastAnimatedRouteUpdateAt;

  BitmapDescriptor? customMarker;
  BitmapDescriptor? customCarMarker;
  BitmapDescriptor? customUserMarker;
  BitmapDescriptor? destinationMarker;

  double currentZoom = 18.5;
  bool _isLoading = false;
  bool _hasLocation = true;
  String _errorMessage = '';

  final LatLng _defaultLocation = const LatLng(
    kMapFallbackLatitude,
    kMapFallbackLongitude,
  );

  StreamSubscription<Position>? _positionStream;
  Position? _lastSentPosition;
  DateTime? _lastLocationSentAt;
  bool _isTracking = false;
  bool _didCaptureDeviceHeading = false;
  double? _initialDeviceHeading;
  LatLng? _remoteDriverTarget;
  final LiveDriverLocationTracker _liveDriverTracker =
      LiveDriverLocationTracker();
  final VehicleMotionEngine _selfMotionEngine =
      VehicleMotionEngine(smoothObservedSpeed: true);
  final VehicleMotionEngine _remoteMotionEngine =
      VehicleMotionEngine(smoothObservedSpeed: false);
  LatLng? _pendingCameraTarget;
  late final MapNavigationCamera _navCamera = MapNavigationCamera(
    onProgrammaticMove: ({Duration hold = const Duration(milliseconds: 500)}) {
      mapOPTController.beginProgrammaticCamera(hold: hold);
    },
  );
  // Toggle live location pipeline diagnostics in debug consoles.
  final bool _liveLocationDiag = false;
  DateTime? _lastMarkerRenderLogAt;
  Worker? _screenAwakeWorker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initMarkers();
    _bindVehicleMotionEngines();
    _bindScreenAwake();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initializeMap();
      await loadStatus();
      _syncScreenAwake();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Always keep GoogleMap mounted — never replace it with a loading/error page.
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: MapView(
            mapOPTController: mapOPTController,
            currentZoom: currentZoom,
            defaultLocation: _defaultLocation,
            markersBuilder: buildMarkers,
            polylines: _polylines,
            onMapCreated: _onMapCreated,
            onCameraMove: (position) {
              currentZoom = position.zoom;
            },
            onCameraMoveStarted: _onCameraMoveStarted,
          ),
          ),
          ...buildPassengerOverlays(
            userController: userController,
            googleSearchLocationController: googleSearchLocationController,
            rideController: rideController,
            mapOPTController: mapOPTController,
          ),
          SafeArea(
            child: Column(
              children: [
                DriverTopSection(
                  userController: userController,
                  rideController: rideController,
                  mapOPTController: mapOPTController,
                ),
                const Spacer(),
                SwipeToSearchButton(
                  userController: userController,
                  googleSearchLocationController:
                      googleSearchLocationController,
                  rideController: rideController,
                  mapOPTController: mapOPTController,
                ),
                DriverBottomPanel(
                  userController: userController,
                  rideController: rideController,
                  mapOPTController: mapOPTController,
                  onRideCancelled: () => finishRide(),
                ),
              ],
            ),
          ),
          const LocationStatusBanner(),
          DraggableLocationShowButton(
            mapOPTController: mapOPTController,
            onTap: moveToCurrentLocation,
          )
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _syncScreenAwake(lifecycle: state);

    if (state != AppLifecycleState.resumed) return;
    if (!mapOPTController.hasValidCoordinates) {
      unawaited(getCurrentLocation());
    } else {
      unawaited(mapOPTController.maybeRefreshAddress());
    }
  }

  void _bindScreenAwake() {
    final sources = <RxInterface<dynamic>>[
      mapOPTController.rideStatusData,
      rideController.isRideAccepted,
    ];
    if (Get.isRegistered<CustomBottomNavBarController>()) {
      sources.add(Get.find<CustomBottomNavBarController>().selectedIndex);
    }
    _screenAwakeWorker = everAll(sources, (_) => _syncScreenAwake());
    _syncScreenAwake();
  }

  /// Screen stays awake only while this tracking view is in the foreground
  /// during an active ride. Leaving the tab, backgrounding, or ending the
  /// ride restores the system timeout.
  void _syncScreenAwake({AppLifecycleState? lifecycle}) {
    if (!mounted) {
      unawaited(ScreenAwakeHelper.release());
      return;
    }

    final state = lifecycle ?? WidgetsBinding.instance.lifecycleState;
    final inForeground = state == null ||
        state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive;

    var onTrackingTab = true;
    if (Get.isRegistered<CustomBottomNavBarController>()) {
      onTrackingTab =
          Get.find<CustomBottomNavBarController>().selectedIndex.value == 0;
    }

    final trackingActive = mapOPTController.isInActiveRide ||
        rideController.isRideAccepted.value == true;

    unawaited(
      ScreenAwakeHelper.setDesired(
        trackingActive && onTrackingTab && inForeground,
      ),
    );
  }

  /// Read the phone compass once at screen open. Never a continuous stream.
  Future<void> _captureInitialDeviceHeadingOnce() async {
    if (_didCaptureDeviceHeading) return;
    _didCaptureDeviceHeading = true;
    try {
      final events = FlutterCompass.events;
      if (events == null) return;
      final event = await events.first.timeout(
        const Duration(milliseconds: 800),
      );
      final heading = event.heading;
      if (heading == null || !heading.isFinite) return;
      _initialDeviceHeading = (heading % 360 + 360) % 360;
      mapOPTController.headingDegrees.value = _initialDeviceHeading!;
    } catch (_) {
      // Compass unavailable — driver GPS heading takes over the marker.
    }
  }

  double _initialMarkerHeading(double? gpsHeading) {
    if (gpsHeading != null && gpsHeading.isFinite && gpsHeading > 0) {
      return (gpsHeading % 360 + 360) % 360;
    }
    return _initialDeviceHeading ?? 0;
  }

  void moveToCurrentLocation() {
    mapOPTController.hideLocationButton();
    _navCamera.resumeFollow();
    final pose = _trackingVehiclePose();
    if (pose == null) return;
    unawaited(
      _navCamera.recapture(
        target: pose.position,
        zoom: currentZoom,
      ),
    );
  }

  ({LatLng position, double heading, bool moving})? _trackingVehiclePose() {
    final isPassenger =
        userController.userModel.value?.userProfile?.role ==
            AppConstants.passenger;
    if (isPassenger) {
      final pos = _remoteMotionEngine.displayedPosition ??
          mapOPTController.animatedRemoteDriverPosition.value;
      if (pos == null) return null;
      return (
        position: pos,
        heading: _remoteMotionEngine.displayedHeading,
        moving: _remoteMotionEngine.smoothedSpeedMps >= 0.5,
      );
    }
    final pos = _selfMotionEngine.displayedPosition ??
        mapOPTController.animatedCurrentMarkerPosition.value;
    if (pos == null) {
      final lat = mapOPTController.currentLatitudePosition?.value;
      final lng = mapOPTController.currentLongitudePosition?.value;
      if (!isValidLatLng(lat, lng)) return null;
      return (
        position: LatLng(lat!, lng!),
        heading: _selfMotionEngine.displayedHeading,
        moving: false,
      );
    }
    return (
      position: pos,
      heading: _selfMotionEngine.displayedHeading,
      moving: _selfMotionEngine.smoothedSpeedMps >= 0.5,
    );
  }

  void _onCameraMoveStarted() {
    if (_navCamera.programmatic) return;
    if (!_navCamera.initialApplied) return;
    _navCamera.pauseFollow();
    mapOPTController.notifyMapMoved();
  }

  void _followTrackingVehicle(LatLng position) {
    if (!_navCamera.followEnabled) return;
    _navCamera.followVisual(
      visual: position,
      zoom: currentZoom,
    );
  }

  Future<void> _ensureInitialNavCamera(LatLng target) {
    return _navCamera.applyInitial(
      target: target,
      zoom: currentZoom,
    );
  }

  @override
  void dispose() {
    _screenAwakeWorker?.dispose();
    _screenAwakeWorker = null;
    unawaited(ScreenAwakeHelper.release());
    _selfMotionEngine.dispose();
    _remoteMotionEngine.dispose();
    _navCamera.dispose();
    _mapController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    positionStream?.cancel();
    disconnectSocket();
    stopLocationTracking();
    super.dispose();
  }
}
