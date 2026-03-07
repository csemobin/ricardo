import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ricardo/app/utils/app_constants.dart';
import 'package:ricardo/app/helpers/prefs_helper.dart';
import 'package:ricardo/app/helpers/custom_location_helper.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/feature/models/socket/accept_ride_model.dart';
import 'package:ricardo/feature/models/socket/ride_details_socket_model.dart';
import 'package:ricardo/services/api_urls.dart';
  import 'package:ricardo/services/socket_services.dart';

import '../../services/direction_services.dart';
import '../../services/get_fcm_tocken.dart';
import '../../services/location_permission_service.dart';
import 'home/google_search_location_controller.dart';
import 'home/map/map_opt_controller.dart';
import 'home/map/ride_controller.dart';

/// Drop-in GetX controller for [MapScreen].
///
/// Responsibilities:
///   • One-time socket initialisation (connect + register listeners).
///   • Live location streaming → socket `update-user-location`.
///   • Custom marker loading.
///   • Polyline / route computation.
///   • Exposing reactive state that the view Obx-binds to.
class MapScreenController extends GetxController with WidgetsBindingObserver {
  // ────────────────────────────────────────────────
  // External controllers (already registered in DI)
  // ────────────────────────────────────────────────
  late final UserController userController;
  late final GoogleSearchLocationController googleSearchLocationController;
  late final RideController rideController;
  late final MapOPTController mapOPTController;

  // ────────────────────────────────────────────────
  // Google Map
  // ────────────────────────────────────────────────
  GoogleMapController? mapController;

  // ────────────────────────────────────────────────
  // Reactive state
  // ────────────────────────────────────────────────
  final markers = RxSet<Marker>({});
  final polylines = RxSet<Polyline>({});

  final RxBool isLocationEnabled = true.obs;

  // ────────────────────────────────────────────────
  // Custom markers (loaded once from assets)
  // ────────────────────────────────────────────────
  BitmapDescriptor? customMarker;
  BitmapDescriptor? customCarMarker;

  // ────────────────────────────────────────────────
  // Internals
  // ────────────────────────────────────────────────
  StreamSubscription<Position>? _positionStream;
  Timer? _locationStatusTimer;

  // ────────────────────────────────────────────────
  // Lifecycle
  // ────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();

    userController = Get.find<UserController>();
    googleSearchLocationController =
        Get.find<GoogleSearchLocationController>();
    rideController = Get.find<RideController>();
    mapOPTController = Get.find<MapOPTController>();

    WidgetsBinding.instance.addObserver(this);

    _bootstrap();
  }

  /// Single entry-point called once from [onInit].
  Future<void> _bootstrap() async {
    await Future.wait([
      _loadCustomMarkers(),
      userController.fetchUser(),
    ]);

    // Socket must be ready before we register listeners.
    await _initSocket();

    // Start streaming device location → socket.
    await _startLiveLocation();

    // Kick off initial route if coords are already available.
    loadRoute();

    // React to ride-accepted changes.
    ever(rideController.isRideAccepted, (bool accepted) {
      if (accepted) loadRoute();
    });

    // Poll location-service status every 5 s.
    _startLocationStatusPolling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionStream?.cancel();
    _locationStatusTimer?.cancel();

    // Remove socket listeners registered by this controller.
    _removeSocketListeners();

    super.onClose();
  }

  // ────────────────────────────────────────────────
  // Socket
  // ────────────────────────────────────────────────

  /// Initialises the socket connection (no-op if already connected) and
  /// registers all event listeners **once**.
  Future<void> _initSocket() async {
    final accessToken = await PrefsHelper.getString(AppConstants.bearerToken);
    final fcmToken = await FirebaseNotificationService.getFCMToken();
    await PrefsHelper.setString(AppConstants.fcmToken, fcmToken);

    // SocketServices.init() is idempotent – safe to call here.
    // await SocketServices().init();
    //todo: socket

    // Announce this user to the server.
    // SocketServices.emit('user-connected', {
    //   'accessToken': accessToken,
    //   'fcmToken': fcmToken,
    // });

    _registerSocketListeners();
  }

  void _registerSocketListeners() {
    SocketServices.socket?.on('new-ride-request', _onNewRideRequest);
    SocketServices.socket?.on('cancel-ride-request', _onCancelRideRequest);
    SocketServices.socket?.on('ride-accepted', _onRideAccepted);
    SocketServices.socket?.on('ride-accepted-driver', _onRideAcceptedDriver);
  }

  void _removeSocketListeners() {
    SocketServices.socket?.off('new-ride-request');
    SocketServices.socket?.off('cancel-ride-request');
    SocketServices.socket?.off('ride-accepted');
    SocketServices.socket?.off('ride-accepted-driver');
    SocketServices.socket?.off('updated-user-location-data');
  }

  // ── Socket event handlers ──────────────────────

  void _onNewRideRequest(dynamic data) {
    debugPrint('🚕 new-ride-request: $data');
    if (data['newRideRequest'] == true) {
      mapOPTController.isPassengerRequest.value = true;
      mapOPTController.rideDetailsData.value =
          RideDetailsSocketModel.fromJson(data['rideDetails']);
    }
  }

  void _onCancelRideRequest(dynamic data) {
    if (data['isCancelPickRequest'] == true) {
      mapOPTController.isPassengerRequest.value = false;
    }
  }

  void _onRideAccepted(dynamic data) {
    debugPrint('✅ ride-accepted: $data');
    if (data is Map<String, dynamic> && data['isRideAccepted'] == true) {
      rideController.isRideAccepted.value = true;
      rideController.acceptedRideDriverName.value =
          data['driver']?['driverName'] ?? '';
      rideController.acceptRideModel.value = AcceptRideModel.fromJson(data);
    }
  }

  void _onRideAcceptedDriver(dynamic data) {
    debugPrint('🧑‍✈️ ride-accepted-driver: $data');
  }

  // ────────────────────────────────────────────────
  // Live location
  // ────────────────────────────────────────────────

  Future<void> _startLiveLocation() async {
    // Warm-up: obtain a single fix first so the map has a starting point.
    await CustomLocationHelper.getCurrentLocation();

    final token = await PrefsHelper.getString(AppConstants.bearerToken);

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      final newLocation = LatLng(position.latitude, position.longitude);

      SocketServices.emit('update-user-location', {
        'accessToken': token,
        'location': {
          'type': 'Point',
          'coordinates': [newLocation.longitude, newLocation.latitude],
        },
      });
    });

    SocketServices.socket
        ?.on('updated-user-location-data', (data) => debugPrint('📍 $data'));
  }

  // ────────────────────────────────────────────────
  // Custom markers
  // ────────────────────────────────────────────────

  Future<void> _loadCustomMarkers() async {
    customMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 1.0, size: Size(50, 50)),
      'assets/images/location_black_marker.png',
    );
    customCarMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 1.0, size: Size(50, 50)),
      'assets/images/car_marker.png',
    );
  }

  // ────────────────────────────────────────────────
  // Route / polyline
  // ────────────────────────────────────────────────

  Future<void> loadRoute() async {
    try {
      final acceptedRide = rideController.acceptRideModel.value;

      final pickupCoords = acceptedRide?.ride?.pickupLocation?.coordinates;
      final destCoords =
          acceptedRide?.ride?.destinationLocation?.coordinates;

      final origin = (pickupCoords != null && pickupCoords.length == 2)
          ? LatLng(pickupCoords[1], pickupCoords[0])
          : LatLng(
        googleSearchLocationController.selectedPickup.value?.lat ?? 0.0,
        googleSearchLocationController.selectedPickup.value?.lng ?? 0.0,
      );

      final dest = (destCoords != null && destCoords.length == 2)
          ? LatLng(destCoords[1], destCoords[0])
          : LatLng(
        googleSearchLocationController.selectedDrop.value?.lat ?? 0.0,
        googleSearchLocationController.selectedDrop.value?.lng ?? 0.0,
      );

      if (origin.latitude == 0.0 || dest.latitude == 0.0) {
        debugPrint('⚠️  Skipping route — coords not ready');
        return;
      }

      final points = await DirectionsService.getPolyline(origin, dest);

      if (points.isEmpty) {
        Get.snackbar('Error', 'Could not load route. Please check your API key.');
        return;
      }

      // ── Update markers ──────────────────────────
      final updatedMarkers = <Marker>{
        Marker(
          markerId: const MarkerId('Pick-Up-Location'),
          position: origin,
          icon: customCarMarker ?? BitmapDescriptor.defaultMarker,
        ),
        Marker(
          markerId: const MarkerId('Destination'),
          position: dest,
          icon: BitmapDescriptor.defaultMarker,
        ),
      };

      // ── Update polylines ────────────────────────
      final updatedPolylines = <Polyline>{
        Polyline(
          polylineId: const PolylineId('Pick-Up-Location'),
          points: points,
          color: Colors.red,
          width: 6,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
        Polyline(
          polylineId: const PolylineId('Destination'),
          points: [origin, points.first],
          color: Colors.red,
          width: 4,
          patterns: [PatternItem.dot, PatternItem.gap(12)],
        ),
      };

      markers.assignAll(updatedMarkers);
      polylines.assignAll(updatedPolylines);

      // Clear stale ride data after route is drawn.

      // rideController.drivers.clear();
      // rideController.acceptRideModel.close();
      // rideController.favouriteDrivers.clear();

      // Animate camera to fit the full route.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final bounds = _boundsFromLatLng(points);
        mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 80),
        );
      });
    } catch (e) {
      debugPrint('loadRoute error: $e');
    }
  }

  LatLngBounds _boundsFromLatLng(List<LatLng> points) {
    double minLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLat = points.first.latitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // ────────────────────────────────────────────────
  // Markers (called from the view's _buildMarkers)
  // ────────────────────────────────────────────────

  /// Returns a complete [Set<Marker>] combining the current-passenger pin and
  /// any nearby driver pins.  The view can call this directly inside its
  /// `_buildMarkers()` method without any logic changes.
  Set<Marker> buildMarkers(void Function(dynamic driver) onDriverTap) {
    final result = <Marker>{...markers};

    // Current passenger position.
    result.add(
      Marker(
        markerId: const MarkerId('currentPassenger'),
        position: LatLng(
          mapOPTController.currentLatitudePosition!.value,
          mapOPTController.currentLongitudePosition!.value,
        ),
        icon: customMarker ?? BitmapDescriptor.defaultMarker,
      ),
    );

    // Nearby driver pins.
    for (final driver in rideController.drivers) {
      final coords = driver.location?.coordinates;
      if (coords != null && coords.length == 2) {
        result.add(Marker(
          markerId: MarkerId(driver.sId ?? UniqueKey().toString()),
          position: LatLng(coords[1], coords[0]),
          icon: customCarMarker ?? BitmapDescriptor.defaultMarker,
          onTap: () => onDriverTap(driver),
        ));
      }
    }

    return result;
  }

  // ────────────────────────────────────────────────
  // Location permission helpers
  // ────────────────────────────────────────────────

  Future<void> _checkLocationPermission() async {
    final status = await LocationPermissionService.checkAndRequestLocation();
    if (status != LocationStatus.granted) {
      // Bubble up to the view to show the dialog.
      _showLocationDialogCallback?.call(status);
    }
  }

  /// The view sets this callback so the controller can trigger dialogs
  /// without importing BuildContext.
  void Function(LocationStatus status)? _showLocationDialogCallback;

  void setShowLocationDialogCallback(
      void Function(LocationStatus status) cb) {
    _showLocationDialogCallback = cb;
  }

  void _startLocationStatusPolling() {
    _locationStatusTimer =
        Timer.periodic(const Duration(seconds: 5), (_) async {
          isLocationEnabled.value =
          await LocationPermissionService.isLocationEnabled();
        });
  }

  // ────────────────────────────────────────────────
  // Map controller callback
  // ────────────────────────────────────────────────

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    loadRoute();
  }
}