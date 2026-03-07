/*
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:ricardo/app/helpers/custom_location_helper.dart';
import 'package:ricardo/feature/models/socket/accept_ride_driver_model.dart';
import 'package:ricardo/feature/models/socket/accept_ride_model.dart';
import 'package:ricardo/feature/view/home/map/draggable_bottom_sheet.dart';
import 'package:ricardo/feature/view/home/map/custom_header.dart';
import 'package:ricardo/widgets/accepted_ride_button.dart';
import 'package:ricardo/widgets/glass_background_multiple_children_widget.dart';
import 'package:ricardo/widgets/glass_background_widget.dart';
import 'package:ricardo/widgets/map_custom_header_back.dart';
import 'package:ricardo/widgets/no_internet_message_map.dart';
import 'package:ricardo/widgets/request_ride_handler.dart';
import '../../models/socket/ride_details_socket_model.dart';
import 'link_export_file.dart';

// ─────────────────────────────────────────────
// Marker State Enum — Single Source of Truth
// ─────────────────────────────────────────────
enum MapMarkerState {
  idle,             // Only user location shown
  searchingDrivers, // Nearby drivers visible on map
  rideRequested,    // Pickup + destination markers
  rideAccepted,     // Driver on way to pickup (driver marker + pickup + dest)
  rideOngoing,      // In trip (driver marker + destination only)
  rideCompleted,    // Trip done — only user marker
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  // ─────────────────────────────────────────────
  // Controllers
  // ─────────────────────────────────────────────
  final userController = Get.find<UserController>();
  final googleSearchLocationController =
  Get.find<GoogleSearchLocationController>();
  final rideController = Get.find<RideController>();
  final mapOPTController = Get.find<MapOPTController>();

  GoogleMapController? _mapController;

  // ─────────────────────────────────────────────
  // Map State
  // ─────────────────────────────────────────────
  Set<Polyline> _polylines = {};
  double currentZoom = 18.5746;
  LatLng destination = const LatLng(23.83655877786759, 90.36862693085972);

  // ─────────────────────────────────────────────
  // Custom Markers (loaded once)
  // ─────────────────────────────────────────────
  BitmapDescriptor? _userMarkerIcon;
  BitmapDescriptor? _carMarkerIcon;

  // ─────────────────────────────────────────────
  // Location Stream
  // ─────────────────────────────────────────────
  StreamSubscription<Position>? _positionStream;

  // ══════════════════════════════════════════════
  // LIFECYCLE
  // ══════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectSocket();
    _loadCustomMarkers();
    _getMyLocation();
    userController.fetchUser();
    _loadRoute();

    // Reload route whenever ride is accepted
    ever(rideController.isRideAccepted, (bool accepted) {
      if (accepted) _loadRoute();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRoute());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionStream?.cancel();
    super.dispose();
  }

  // ══════════════════════════════════════════════
  // MARKER STATE RESOLVER — All Conditions Here
  // ══════════════════════════════════════════════

  /// Single method that decides which state the map is in.
  /// To add a new condition, only touch this method + the switch in [_buildMarkers].
  MapMarkerState _resolveMarkerState() {
    final role = userController.userModel.value?.userProfile?.role;
    final isDriver = role == AppConstants.driver;
    final isPassenger = role == AppConstants.passenger;

    // ── DRIVER FLOW ──────────────────────────────
    if (isDriver) {
      // Driver is in an active trip
      if (mapOPTController.acceptedRideDataStatus.value &&
          mapOPTController.acceptedRideData.value?.isRideAcceptedDriver ==
              true) {
        return MapMarkerState.rideOngoing;
      }

      // Driver has accepted a ride, heading to pickup
      if (mapOPTController.isPassengerRequest.value &&
          mapOPTController.acceptedRideDataStatus.value) {
        return MapMarkerState.rideAccepted;
      }

      // Driver is online, waiting for requests
      return MapMarkerState.idle;
    }

    // ── PASSENGER FLOW ───────────────────────────
    if (isPassenger) {
      // Ride fully accepted by a driver
      if (rideController.acceptRideModel.value?.isRideAccepted == true) {
        return MapMarkerState.rideAccepted;
      }

      // Passenger has selected pickup + drop and viewing map
      if (rideController.viewInMap.value &&
          rideController.viewInMapReturn.value == false) {
        return MapMarkerState.rideRequested;
      }

      // Nearby drivers loaded and visible
      if (rideController.drivers.isNotEmpty) {
        return MapMarkerState.searchingDrivers;
      }
    }

    return MapMarkerState.idle;
  }

  // ══════════════════════════════════════════════
  // CENTRALIZED MARKER BUILDER
  // ══════════════════════════════════════════════

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};
    final state = _resolveMarkerState();

    // ✅ User / Passenger current position — always shown
    markers.add(_currentUserMarker());

    switch (state) {
    // ── Only user marker needed
      case MapMarkerState.idle:
      case MapMarkerState.rideCompleted:
        break;

    // ── Nearby drivers on map (passenger searching)
      case MapMarkerState.searchingDrivers:
        markers.addAll(_nearbyDriverMarkers());
        break;

    // ── Pickup + destination (passenger selected locations)
      case MapMarkerState.rideRequested:
        markers.add(_pickupMarker());
        markers.add(_destinationMarker());
        break;

    // ── Driver accepted: show driver live position + pickup + destination
      case MapMarkerState.rideAccepted:
        markers.add(_pickupMarker());
        markers.add(_destinationMarker());
        markers.add(_driverLiveMarker());
        break;

    // ── In trip: show driver position + destination only
      case MapMarkerState.rideOngoing:
        markers.add(_destinationMarker());
        markers.add(_driverLiveMarker());
        break;
    }

    return markers;
  }

  // ══════════════════════════════════════════════
  // INDIVIDUAL MARKER BUILDERS
  // ══════════════════════════════════════════════

  /// Current user / passenger position
  Marker _currentUserMarker() {
    return Marker(
      markerId: const MarkerId('currentUser'),
      position: LatLng(
        mapOPTController.currentLatitudePosition!.value,
        mapOPTController.currentLongitudePosition!.value,
      ),
      icon: _userMarkerIcon ?? BitmapDescriptor.defaultMarker,
      zIndex: 10, // always rendered on top
    );
  }

  /// Pickup location marker
  Marker _pickupMarker() {
    return Marker(
      markerId: const MarkerId('pickup'),
      position: _resolvePickupLatLng(),
      icon: _carMarkerIcon ?? BitmapDescriptor.defaultMarker,
      infoWindow: const InfoWindow(title: 'Pickup'),
    );
  }

  /// Destination marker
  Marker _destinationMarker() {
    return Marker(
      markerId: const MarkerId('destination'),
      position: _resolveDestLatLng(),
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: const InfoWindow(title: 'Destination'),
    );
  }

  /// Live driver position (updated from socket)
  Marker _driverLiveMarker() {
    final driverLat =
        mapOPTController.acceptedRideData.value?.driverLat ?? 0.0;
    final driverLng =
        mapOPTController.acceptedRideData.value?.driverLng ?? 0.0;

    return Marker(
      markerId: const MarkerId('driverLive'),
      position: LatLng(driverLat, driverLng),
      icon: _carMarkerIcon ?? BitmapDescriptor.defaultMarker,
      infoWindow: const InfoWindow(title: 'Your Driver'),
      zIndex: 9,
    );
  }

  /// All nearby driver markers (passenger searching state)
  Set<Marker> _nearbyDriverMarkers() {
    return rideController.drivers
        .where((driver) => driver.location?.coordinates?.length == 2)
        .map((driver) {
      final coords = driver.location!.coordinates!;
      return Marker(
        markerId: MarkerId(driver.sId ?? UniqueKey().toString()),
        position: LatLng(coords[1], coords[0]), // [lng, lat] → reversed
        icon: _carMarkerIcon ?? BitmapDescriptor.defaultMarker,
        onTap: () => _showDriverDialog(driver),
      );
    })
        .toSet();
  }

  // ══════════════════════════════════════════════
  // COORDINATE HELPERS
  // ══════════════════════════════════════════════

  LatLng _resolvePickupLatLng() {
    final coords =
        rideController.acceptRideModel.value?.ride?.pickupLocation?.coordinates;
    if (coords != null && coords.length == 2) {
      return LatLng(coords[1], coords[0]);
    }
    return LatLng(
      googleSearchLocationController.selectedPickup.value?.lat ?? 0.0,
      googleSearchLocationController.selectedPickup.value?.lng ?? 0.0,
    );
  }

  LatLng _resolveDestLatLng() {
    final coords = rideController
        .acceptRideModel.value?.ride?.destinationLocation?.coordinates;
    if (coords != null && coords.length == 2) {
      return LatLng(coords[1], coords[0]);
    }
    return LatLng(
      googleSearchLocationController.selectedDrop.value?.lat ?? 0.0,
      googleSearchLocationController.selectedDrop.value?.lng ?? 0.0,
    );
  }

  // ══════════════════════════════════════════════
  // LOAD CUSTOM MARKER ICONS
  // ══════════════════════════════════════════════

  Future<void> _loadCustomMarkers() async {
    _userMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 1.0, size: Size(50, 50)),
      'assets/images/location_black_marker.png',
    );
    _carMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 1.0, size: Size(50, 50)),
      'assets/images/car_marker.png',
    );
    if (mounted) setState(() {});
  }

  // ══════════════════════════════════════════════
  // POLYLINE / ROUTE
  // ══════════════════════════════════════════════

  Future<void> _loadRoute() async {
    try {
      final origin = _resolvePickupLatLng();
      final dest = _resolveDestLatLng();

      if (origin.latitude == 0.0 || dest.latitude == 0.0) {
        debugPrint('Skipping route — coords not ready');
        return;
      }

      final points = await DirectionsService.getPolyline(origin, dest);
      if (points.isEmpty) {
        Get.snackbar('Error', 'Could not load route. Check your API key.');
        return;
      }

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('mainRoute'),
            points: points,
            color: Colors.red,
            width: 6,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
          Polyline(
            polylineId: const PolylineId('dotted'),
            points: [origin, points.first],
            color: Colors.red,
            width: 4,
            patterns: [PatternItem.dot, PatternItem.gap(12)],
          ),
        };
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final bounds = _boundsFromLatLng(points);
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
      });
    } catch (e) {
      debugPrint('_loadRoute error: $e');
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

  // ══════════════════════════════════════════════
  // SOCKET
  // ══════════════════════════════════════════════

  void _connectSocket() async {
    final accessToken = await PrefsHelper.getString('accessToken');
    final fcmToken = await FirebaseNotificationService.getFCMToken();
    await PrefsHelper.setString(AppConstants.fcmToken, fcmToken);

    SocketServices.socket?.on('new-ride-request', (data) {
      if (data['newRideRequest'] == true) {
        mapOPTController.isPassengerRequest.value = true;
        mapOPTController.rideDetailsData.value =
            RideDetailsSocketModel.fromJson(data['rideDetails']);
      }
    });

    SocketServices.socket?.on('cancel-ride-request', (data) {
      if (data['isCancelPickRequest'] == true) {
        mapOPTController.isPassengerRequest.value = false;
      }
    });

    SocketServices.socket?.on('ride-accepted', (data) {
      if (data is Map<String, dynamic> && data['isRideAccepted'] == true) {
        rideController.isRideAccepted.value = true;
        rideController.acceptedRideDriverName.value =
            data['driver']?['driverName'] ?? '';
        rideController.acceptRideModel.value = AcceptRideModel.fromJson(data);
      }
    });

    SocketServices.socket?.on('ride-accepted-driver', (data) {
      if (data is Map<String, dynamic> &&
          data['isRideAcceptedDriver'] == true) {
        mapOPTController.acceptedRideDataStatus.value = true;
        mapOPTController.acceptedRideData.value =
            AcceptRideDriverModel.fromJson(data);
      }
    });
  }

  // ══════════════════════════════════════════════
  // LOCATION
  // ══════════════════════════════════════════════

  Future<void> _getMyLocation() async {
    final token = await PrefsHelper.getString(AppConstants.bearerToken);
    await CustomLocationHelper.getCurrentLocation();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      final newLocation = LatLng(position.latitude, position.longitude);
      SocketServices.socket?.emit('update-user-location', {
        "accessToken": token,
        "location": {
          "type": "Point",
          "coordinates": [newLocation.longitude, newLocation.latitude],
        },
      });
    });
  }

  Future<void> _checkLocationPermission() async {
    final status = await LocationPermissionService.checkAndRequestLocation();
    if (status != LocationStatus.granted) {
      _showLocationDialog(status);
    }
  }

  void _showLocationDialog(LocationStatus status) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LocationPermissionDialog(status: status),
    );
  }

  Stream<bool> _locationStatusStream() {
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      return await LocationPermissionService.isLocationEnabled();
    }).asyncMap((e) => e);
  }

  // ══════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Google Map ──────────────────────────
          Obx(
                () => GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  mapOPTController.currentLatitudePosition!.value,
                  mapOPTController.currentLongitudePosition!.value,
                ),
                zoom: currentZoom,
              ),
              // ✅ All marker logic lives in _buildMarkers()
              markers: _buildMarkers(),
              polylines: _polylines,
              circles: _buildCircles(),
              onMapCreated: (controller) {
                _mapController = controller;
                _loadRoute();
              },
            ),
          ),

          // ── Passenger: Accepted Ride Bottom Sheet ──
          Obx(() {
            if (userController.userModel.value?.userProfile?.role ==
                AppConstants.passenger &&
                rideController.acceptRideModel.value?.isRideAccepted == true) {
              return DraggableBottomSheet(
                acceptRideModel: rideController.acceptRideModel.value,
              );
            }
            return const SizedBox.shrink();
          }),

          // ── Ride Request Modal Sheet ─────────────
          Obx(() {
            if (googleSearchLocationController.isModalOn.value &&
                rideController.viewInMap.value &&
                rideController.viewInMapReturn.value == false) {
              return Positioned.fill(
                child: BottomSheet(
                  onClosing: () {},
                  backgroundColor: Colors.transparent,
                  enableDrag: false,
                  builder: (_) => RideRequestBottomSheet(
                    pickupLocation:
                    googleSearchLocationController.pickupController.text,
                    dropLocation:
                    googleSearchLocationController.dropController.text,
                    distance: googleSearchLocationController.distance.value
                        .toString(),
                    rideFare:
                    googleSearchLocationController.fare.value.toString(),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // ── Header ──────────────────────────────
          if (userController.userModel.value?.userProfile?.role ==
              AppConstants.passenger)
            Obx(() {
              if (rideController.viewInMap.value &&
                  rideController.viewInMapReturn.value == false) {
                return CustomHeader(mapOPTController: mapOPTController);
              }
              return MapCustomHeaderBack(rideController: rideController);
            }),

          // ── Safe Area Overlays ───────────────────
          SafeArea(
            child: Column(
              children: [
                // Driver Toggle Switch
                Obx(() {
                  final isDriver =
                      userController.userModel.value?.userProfile?.role ==
                          AppConstants.driver;
                  final rideNotAccepted =
                  !mapOPTController.acceptedRideDataStatus.value;
                  if (isDriver && rideNotAccepted) {
                    return AnimatedToggleSwitch();
                  }
                  return const SizedBox.shrink();
                }),

                // Driver Offline Banner
                Obx(() {
                  final isDriver =
                      userController.userModel.value?.userProfile?.role ==
                          AppConstants.driver;
                  final isOffline =
                      userController.userModel.value?.driverProfile?.isOnline ==
                          false;
                  if (isDriver && isOffline) return NoInternetMessageMap();
                  return const SizedBox.shrink();
                }),

                const Spacer(),

                // Passenger Swipe-To-Go Button
                Obx(() {
                  final isPassenger =
                      userController.userModel.value?.userProfile?.role ==
                          AppConstants.passenger;
                  final modalOff =
                  !googleSearchLocationController.isModalOn.value;
                  final swipeOff = !rideController.isSwippedButtonShow.value;
                  final viewInMap = rideController.viewInMap.value;

                  if (isPassenger && modalOff && swipeOff && viewInMap) {
                    return Column(
                      children: [
                        _buildSwipedButton(),
                        const SizedBox(height: 100),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Driver Bottom Cards (waiting / request / in-trip)
                Obx(() => _buildDriverBottomCard()),
              ],
            ),
          ),

          // ── Location Disabled Banner ─────────────
          StreamBuilder<bool>(
            stream: _locationStatusStream(),
            builder: (context, snapshot) {
              if (snapshot.data == false) {
                return Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Material(
                    color: Colors.red,
                    child: SafeArea(
                      minimum: const EdgeInsets.only(bottom: 25),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 20),
                        child: Row(
                          children: [
                            const Icon(Icons.location_off, color: Colors.white),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Location is disabled. Enable to continue.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            TextButton(
                              onPressed: LocationPermissionService
                                  .openLocationSettings,
                              child: const Text(
                                'ENABLE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // DRIVER BOTTOM CARD — Conditional
  // ══════════════════════════════════════════════

  Widget _buildDriverBottomCard() {
    final role = userController.userModel.value?.userProfile?.role;
    final isDriver = role == AppConstants.driver;
    final isOnline =
        userController.userModel.value?.driverProfile?.isOnline == true;
    final hasRequest = mapOPTController.isPassengerRequest.value;
    final rideAccepted = mapOPTController.acceptedRideDataStatus.value;
    final rideActive =
        mapOPTController.acceptedRideData.value?.isRideAcceptedDriver == true;

    if (!isDriver) return const SizedBox.shrink();

    // ── State 1: Driver online, no request yet — waiting card
    if (isOnline && !hasRequest && !rideAccepted) {
      return Container(
        margin: EdgeInsets.only(bottom: 90.h),
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        child: _bgGlassDesign(_buildWaitingCard()),
      );
    }

    // ── State 2: New passenger request arrived
    if (hasRequest && !rideAccepted) {
      return _buildPassengerRequestCard();
    }

    // ── State 3: Driver accepted, in trip
    if (rideActive && rideAccepted) {
      return GlassBackgroundWidget(child: _buildInTripCard());
    }

    return const SizedBox.shrink();
  }

  // ══════════════════════════════════════════════
  // CIRCLES
  // ══════════════════════════════════════════════

  Set<Circle> _buildCircles() {
    return {
      Circle(
        circleId: const CircleId('currentUser'),
        center: LatLng(
          mapOPTController.currentLatitudePosition!.value,
          mapOPTController.currentLongitudePosition!.value,
        ),
        radius: 10,
        strokeColor: Colors.white,
        strokeWidth: 1,
        fillColor: const Color(0xFF006491).withOpacity(0.2),
        consumeTapEvents: true,
      ),
      Circle(
        circleId: const CircleId('destination'),
        center: destination,
        radius: 10,
        strokeColor: Colors.white,
        strokeWidth: 1,
        fillColor: const Color(0xFF006491).withOpacity(0.2),
      ),
    };
  }

  // ══════════════════════════════════════════════
  // DRIVER CARD WIDGETS
  // ══════════════════════════════════════════════

  Widget _buildWaitingCard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(Assets.images.waiting.path, fit: BoxFit.cover),
        Text(
          'Waiting for Passenger request...',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            fontFamily: FontFamily.poppins,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerRequestCard() {
    final ride = mapOPTController.rideDetailsData.value;
    return GlassBackgroundMultipleChildrenWidget(
      crossAxisAlignment: CrossAxisAlignment.start,
      blurOne: 20,
      blurTwo: 20,
      children: [
        // Handle bar
        Center(
          child: Container(
            width: 50,
            height: 5.h,
            decoration: BoxDecoration(
              color: const Color(0xFFB9C0C9),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
        SizedBox(height: 50.h),

        // Passenger info
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                ride?.passengerImage?.isNotEmpty == true
                    ? '${ApiUrls.imageBaseUrl}${ride!.passengerImage}'
                    : '',
                height: 50.h,
                width: 50.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  Assets.images.defaultImage.path,
                  height: 50.h,
                  width: 50.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride?.passengerName ?? '',
                  style: TextStyle(
                    color: const Color(0xff171717),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: FontFamily.poppins,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '\$${ride?.fare ?? 0.0} ',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                    Text(
                        '(${((ride?.destinationMeters ?? 0) * 0.000621371).toStringAsFixed(2)} Miles)'),
                  ],
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Divider(height: 1, color: Colors.black.withOpacity(0.2)),
        SizedBox(height: 6.h),

        // Pickup & Dropoff
        _buildLocationRow(
          icon: Assets.images.directRight.path,
          label: 'PICK UP',
          address: ride?.pickupAddress ?? 'Pickup not specified',
        ),
        Padding(
          padding: EdgeInsets.only(left: 4.w, top: 4.h, bottom: 4.h),
          child: Container(
            width: 4.w,
            height: 40.h,
            decoration: const BoxDecoration(color: Colors.white),
          ),
        ),
        _buildLocationRow(
          icon: Assets.images.location.path,
          label: 'DROP OFF',
          address: ride?.destinationAddress ?? 'Destination not specified',
        ),

        SizedBox(height: 6.h),
        Divider(height: 1, color: Colors.black.withOpacity(0.2)),
        SizedBox(height: 8.h),

        Text(
          "Passenger's Note",
          style: TextStyle(color: const Color(0xff5E5E5E).withOpacity(0.7)),
        ),
        SizedBox(height: 10.h),
        Text(ride?.destinationAddress ?? ''),
        SizedBox(height: 18.h),

        AcceptRideButton(
          onPressed: () {
            mapOPTController
                .rideAcceptRide(ride!.rideId.toString());
          },
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildInTripCard() {
    // Customize with actual in-trip UI
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'You are on a trip!',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLocationRow({
    required String icon,
    required String label,
    required String address,
  }) {
    return Row(
      children: [
        Image.asset(icon),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.labelTextColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: FontFamily.poppins,
                ),
              ),
              Text(
                address,
                style: TextStyle(
                  color: AppColors.primaryHeadingTextColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: FontFamily.poppins,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // DRIVER DIALOG (tapping a nearby driver marker)
  // ══════════════════════════════════════════════

  void _showDriverDialog(driver) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Driver Info
                  Row(
                    children: [
                      driver.image != null && driver.image!.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          '${ApiUrls.imageBaseUrl}${driver.image}',
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/driver.png',
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                          : CircleAvatar(
                        radius: 30,
                        child: Image.asset('assets/images/driver.png',
                            height: 60, width: 60, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${driver.name}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                    '${driver.rating} (${driver.totalRatings})'),
                                const SizedBox(width: 8),
                                const Text('|'),
                                const SizedBox(width: 8),
                                Text('${driver.trips} Trips'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text('${driver.phone}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        child: IconButton(
                          icon:
                          const Icon(Icons.phone, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Car Info.',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),

                  // Car Info
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${driver.vehicle?.carName}',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('${driver.vehicle?.numberOfSeat} Seat'),
                            const SizedBox(height: 4),
                            Text('${driver.vehicle?.carPlateNumber}'),
                            const SizedBox(height: 4),
                            const Text('1 km away from you.',
                                style: TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: driver.image != null && driver.image!.isNotEmpty
                            ? Image.network(
                          '${ApiUrls.imageBaseUrl}${driver.image}',
                          width: 92.w,
                          height: 92.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/driver.png',
                            width: 92.w,
                            height: 92.h,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Image.asset(
                          'assets/images/driver.png',
                          width: 92.w,
                          height: 92.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RequestRideHandler(cnt: rideController, cardDetails: driver),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // GLASS DESIGN HELPER
  // ══════════════════════════════════════════════

  Widget _bgGlassDesign(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.whiteColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.whiteColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, -4),
                blurRadius: 4,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // SWIPE BUTTON (Passenger)
  // ══════════════════════════════════════════════

  Widget _buildSwipedButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SlideAction(
        sliderButtonYOffset: 0,
        onSubmit: () => Get.toNamed(
          AppRoutes.searchLocationScreen,
          arguments: {'back_disable': true},
        ),
        text: 'Lets Go...',
        textStyle: TextStyle(
          fontSize: 20.sp,
          color: AppColors.whiteColor,
          fontWeight: FontWeight.w500,
          fontFamily: FontFamily.poppins,
        ),
        innerColor: AppColors.greenColor,
        outerColor: AppColors.blackButton,
        sliderButtonIcon: const Icon(
          Icons.arrow_right_alt,
          color: Color(0xFFF6F6F6),
          size: 24,
        ),
        sliderRotate: false,
        height: 56.h,
        sliderButtonIconPadding: 8,
      ),
    );
  }
}*/


/*
* import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:ricardo/app/helpers/custom_location_helper.dart';
import 'package:ricardo/feature/models/socket/accept_ride_driver_model.dart';
import 'package:ricardo/feature/models/socket/accept_ride_model.dart';
import 'package:ricardo/feature/view/home/map/draggable_bottom_sheet.dart';
import 'package:ricardo/feature/view/home/map/custom_header.dart';
import 'package:ricardo/widgets/accepted_ride_button.dart';
import 'package:ricardo/widgets/glass_background_multiple_children_widget.dart';
import 'package:ricardo/widgets/glass_background_widget.dart';
import 'package:ricardo/widgets/map_custom_header_back.dart';
import 'package:ricardo/widgets/no_internet_message_map.dart';
import 'package:ricardo/widgets/request_ride_handler.dart';
import '../../models/socket/ride_details_socket_model.dart';
import 'link_export_file.dart';

// ╔══════════════════════════════════════════════╗
// ║           MARKER STATE ENUM                  ║
// ║  Add new states here when needed             ║
// ╚══════════════════════════════════════════════╝
enum MapMarkerState {
  idle,             // 👤 only my location
  searchingDrivers, // 👤 my location + 🚗 nearby cars
  rideRequested,    // 📍 only pickup marker
  rideAccepted,     // 🚗 accepted driver + 📍 pickup + 🏁 dest + path
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {

  // ════════════════════════════════════════════
  // CONTROLLERS
  // ════════════════════════════════════════════
  final userController                        = Get.find<UserController>();
  final googleSearchLocationController        = Get.find<GoogleSearchLocationController>();
  final rideController                        = Get.find<RideController>();
  final mapOPTController                      = Get.find<MapOPTController>();
  GoogleMapController? _mapController;
  late final RideDetailsSocketModel? rideRelatedInfo;
  StreamSubscription<Position>? positionStream;
  bool isOnline = true;

  // ════════════════════════════════════════════
  // MARKER ICONS
  // ════════════════════════════════════════════
  BitmapDescriptor? _userMarkerIcon; // 📍 passenger pin
  BitmapDescriptor? _carMarkerIcon;  // 🚗 driver car

  // ════════════════════════════════════════════
  // ZOOM TRACKING (for responsive marker size)
  // ════════════════════════════════════════════
  double _currentZoom = 15.0;

  // ════════════════════════════════════════════
  // POLYLINE (solid black line pickup → dest)
  // only visible after ride accepted
  // ════════════════════════════════════════════
  Set<Polyline> _polylines = {};

  // ════════════════════════════════════════════
  // LIFECYCLE
  // ════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // existing
    connectSocket();
    getMyLocation();
    userController.fetchUser();

    // ✅ load marker icons on start
    _loadCustomMarkers();

    // ✅ trigger path ONLY when ride is accepted
    ever(rideController.isRideAccepted, (bool accepted) {
      print('====== isRideAccepted changed: $accepted'); // ✅ debug
      if (accepted == true) {
        _loadRoute();
      } else {
        _clearRoute();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    positionStream?.cancel();
    super.dispose();
  }

  // ════════════════════════════════════════════
  // STEP 1 — Load initial marker icons
  // ════════════════════════════════════════════
  Future<void> _loadCustomMarkers() async {
    await _updateMarkerSizeByZoom(_currentZoom);
  }

  // ════════════════════════════════════════════
  // STEP 2 — Resize markers when zoom changes
  // bigger on zoom in / smaller on zoom out
  // ════════════════════════════════════════════
  Future<void> _updateMarkerSizeByZoom(double zoom) async {
    _currentZoom = zoom;

    // size grows with zoom — min 20px, max 80px
    final double size = (zoom * 4).clamp(20, 80);

    _userMarkerIcon = await _resizeMarker(
      'assets/images/location_black_marker.png',
      size,
    );
    _carMarkerIcon = await _resizeMarker(
      'assets/images/car_marker.png',
      size,
    );

    if (mounted) setState(() {});
  }

  // helper — resize any asset image to given size
  Future<BitmapDescriptor> _resizeMarker(
      String assetPath, double size) async {
    return await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(size, size)),
      assetPath,
    );
  }

  // ════════════════════════════════════════════
  // STEP 3 — My location marker
  // role driver   → 🚗 car icon
  // role passenger → 📍 pin icon
  // ════════════════════════════════════════════
  Marker _myLocationMarker() {
    final role = userController.userModel.value?.userProfile?.role;

    final BitmapDescriptor icon = role == AppConstants.driver
        ? _carMarkerIcon  ?? BitmapDescriptor.defaultMarker
        : _userMarkerIcon ?? BitmapDescriptor.defaultMarker;

    return Marker(
      markerId: const MarkerId('myLocation'),
      position: LatLng(
        mapOPTController.currentLatitudePosition!.value,
        mapOPTController.currentLongitudePosition!.value,
      ),
      icon: icon,
    );
  }

  // ════════════════════════════════════════════
  // STEP 4 — Individual marker builders
  // ════════════════════════════════════════════

  // 📍 Pickup location pin
  Marker _pickupMarker() {
    return Marker(
      markerId: const MarkerId('pickup'),
      position: LatLng(
        googleSearchLocationController.selectedPickup.value?.lat ?? 0.0,
        googleSearchLocationController.selectedPickup.value?.lng ?? 0.0,
      ),
      icon: _userMarkerIcon ?? BitmapDescriptor.defaultMarker,
    );
  }

  // 🏁 Destination pin
  Marker _destinationMarker() {
    return Marker(
      markerId: const MarkerId('destination'),
      position: LatLng(
        googleSearchLocationController.selectedDrop.value?.lat ?? 0.0,
        googleSearchLocationController.selectedDrop.value?.lng ?? 0.0,
      ),
      icon: BitmapDescriptor.defaultMarker,
    );
  }

  // 🚗 Accepted driver live position
  Marker _acceptedDriverMarker() {
    final coords = rideController
        .acceptRideModel.value?.driver?.driverLocation?.coordinates;

    final double lat = (coords != null && coords.length == 2)
        ? coords[1]
        : mapOPTController.currentLatitudePosition?.value ?? 0.0;

    final double lng = (coords != null && coords.length == 2)
        ? coords[0]
        : mapOPTController.currentLongitudePosition?.value ?? 0.0;

    return Marker(
      markerId: const MarkerId('acceptedDriver'),
      position: LatLng(lat, lng),
      icon: _carMarkerIcon ?? BitmapDescriptor.defaultMarker,
    );
  }

  // 🚗🚗 All nearby drivers (passenger searching)
  Set<Marker> _nearbyDriversMarkers() {
    final Set<Marker> result = {};

    for (var driver in rideController.drivers) {
      final coords = driver.location?.coordinates;

      // skip bad data
      if (coords == null || coords.length < 2) continue;

      result.add(
        Marker(
          markerId: MarkerId(driver.sId ?? 'driver_${coords[0]}'),
          position: LatLng(coords[1], coords[0]), // backend [lng,lat] → flip
          icon: _carMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () => _showDriverDialog(driver),
        ),
      );
    }

    return result;
  }

  // ════════════════════════════════════════════
  // STEP 5 — State resolver
  // ALL conditions in ONE place
  // to add new state → only touch this method
  // ════════════════════════════════════════════
  MapMarkerState _resolveMarkerState() {
    final role = userController.userModel.value?.userProfile?.role;

    // ── DRIVER ──────────────────────────────
    if (role == AppConstants.driver) {

      // driver in active trip
      if (mapOPTController.acceptedRideDataStatus.value == true) {
        return MapMarkerState.rideAccepted;
      }

      // driver waiting for request
      return MapMarkerState.idle;
    }

    // ── PASSENGER ───────────────────────────
    if (role == AppConstants.passenger) {

      // a driver accepted my ride
      if (rideController.acceptRideModel.value?.isRideAccepted == true) {
        return MapMarkerState.rideAccepted;
      }

      // passenger selected pickup + destination
      if (rideController.viewInMap.value == true) {
        return MapMarkerState.rideRequested;
      }

      // nearby drivers loaded on map
      if (rideController.drivers.isNotEmpty) {
        return MapMarkerState.searchingDrivers;
      }
    }

    return MapMarkerState.idle;
  }

  // ════════════════════════════════════════════
  // STEP 6 — Main marker builder
  // uses all above methods
  // to add new markers → only add else if block
  // ════════════════════════════════════════════
  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};
    final state = _resolveMarkerState();

    if (state == MapMarkerState.idle) {
      // ✅ only my location
      markers.add(_myLocationMarker());

    } else if (state == MapMarkerState.searchingDrivers) {
      // ✅ my location + nearby cars
      markers.add(_myLocationMarker());
      markers.addAll(_nearbyDriversMarkers());

    } else if (state == MapMarkerState.rideRequested) {
      // ✅ only pickup pin — no path, no destination
      markers.add(_pickupMarker());

    } else if (state == MapMarkerState.rideAccepted) {
      // ✅ accepted driver car + pickup + destination
      // ✅ solid black path loads via _loadRoute()
      markers.add(_acceptedDriverMarker()); // 🚗 driver
      markers.add(_pickupMarker());         // 📍 pickup
      markers.add(_destinationMarker());    // 🏁 destination
    }

    return markers;
  }

  // ════════════════════════════════════════════
  // STEP 7 — Load solid black path
  // called ONLY when ride is accepted
  // ════════════════════════════════════════════
  Future<void> _loadRoute() async {
    // ✅ DEBUG PRINT 1 — is this method even called?
    print('====== _loadRoute CALLED ======');

    final double pickupLat =
        googleSearchLocationController.selectedPickup.value?.lat ?? 0.0;
    final double pickupLng =
        googleSearchLocationController.selectedPickup.value?.lng ?? 0.0;
    final double destLat =
        googleSearchLocationController.selectedDrop.value?.lat ?? 0.0;
    final double destLng =
        googleSearchLocationController.selectedDrop.value?.lng ?? 0.0;

    // ✅ DEBUG PRINT 2 — do coords have data?
    print('====== pickup: $pickupLat, $pickupLng');
    print('====== dest:   $destLat, $destLng');

    if (pickupLat == 0.0 || destLat == 0.0) {
      print('====== STOPPED — coords are 0.0');
      return;
    }

    final LatLng origin = LatLng(pickupLat, pickupLng);
    final LatLng dest   = LatLng(destLat, destLng);

    final List<LatLng> points =
    await DirectionsService.getPolyline(origin, dest);

    // ✅ DEBUG PRINT 3 — did getPolyline return anything?
    print('====== points count: ${points.length}');

    if (points.isEmpty) {
      print('====== STOPPED — points empty');
      return;
    }

    print('====== DRAWING POLYLINE NOW');
    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          color: Colors.black,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      };
    });

    print('====== polylines count: ${_polylines.length}');
  }

  // ✅ Remove path (on cancel or reset)
  void _clearRoute() {
    setState(() {
      _polylines = {};
    });
  }

  // bounds helper for auto zoom
  LatLngBounds _getBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLat = points.first.latitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude  < minLat) minLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.latitude  > maxLat) maxLat = p.latitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // ════════════════════════════════════════════
  // SOCKET — NO CHANGE
  // ════════════════════════════════════════════
  void connectSocket() async {
    String? getAccessToken = await PrefsHelper.getString('accessToken');
    String? fcmToken       = await FirebaseNotificationService.getFCMToken();
    await PrefsHelper.setString(AppConstants.fcmToken, fcmToken);

    SocketServices.socket?.on('new-ride-request', (data) {
      print('New Ride Request: $data');
      if (data['newRideRequest'] == true) {
        mapOPTController.isPassengerRequest.value = true;
        mapOPTController.rideDetailsData.value =
            RideDetailsSocketModel.fromJson(data['rideDetails']);
      }
    });

    SocketServices.socket?.on('cancel-ride-request', (data) {
      if (data['isCancelPickRequest'] == true) {
        mapOPTController.isPassengerRequest.value = false;
      }
    });

    SocketServices.socket?.on('ride-accepted', (data) {
      print('PASSENGER RIDE ACCEPTED: $data');
      if (data is Map<String, dynamic>) {
        if (data['isRideAccepted'] == true) {
          rideController.isRideAccepted.value        = true;
          rideController.acceptedRideDriverName.value =
              data['driver']?['driverName'] ?? '';
          rideController.acceptRideModel.value =
              AcceptRideModel.fromJson(data);
        }
      }
    });

    SocketServices.socket?.on('ride-accepted-driver', (data) {
      print('RIDE ACCEPTED DRIVER: $data');
      if (data is Map<String, dynamic>) {
        if (data['isRideAcceptedDriver'] == true) {
          mapOPTController.acceptedRideDataStatus.value = true;
          mapOPTController.acceptedRideData.value =
              AcceptRideDriverModel.fromJson(data);
        }
      }
    });
  }

  // ════════════════════════════════════════════
  // LOCATION — NO CHANGE
  // ════════════════════════════════════════════
  Future<void> getMyLocation() async {
    var token = await PrefsHelper.getString(AppConstants.bearerToken);
    LatLng myLocation = await CustomLocationHelper.getCurrentLocation();

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      LatLng newLocation = LatLng(position.latitude, position.longitude);
      SocketServices.socket?.emit('update-user-location', {
        "accessToken": token,
        "location": {
          "type": "Point",
          "coordinates": [newLocation.longitude, newLocation.latitude],
        },
      });
    });

    SocketServices.socket?.on('updated-user-location-data', (data) {
      print('updated-user-location-data: $data');
    });
  }

  Future<void> _checkLocationPermission() async {
    final status = await LocationPermissionService.checkAndRequestLocation();
    if (status != LocationStatus.granted) {
      _showLocationDialog(status);
    }
  }

  void _showLocationDialog(LocationStatus status) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationPermissionDialog(status: status),
    );
  }

  // ════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [

          // ─────────────────────────────────────
          // GOOGLE MAP
          // ─────────────────────────────────────
          Obx(
                () => GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  mapOPTController.currentLatitudePosition!.value,
                  mapOPTController.currentLongitudePosition!.value,
                ),
                zoom: _currentZoom,
              ),

              // ✅ zoom responsive markers
              onCameraMove: (CameraPosition position) {
                // only update if zoom changed enough
                if ((position.zoom - _currentZoom).abs() > 0.5) {
                  _updateMarkerSizeByZoom(position.zoom);
                }
              },

              // ✅ STEP 6 — all markers
              markers: _buildMarkers(),

              // ✅ STEP 7 — solid black path (only on rideAccepted)
              polylines: _polylines,

              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),

          // ─────────────────────────────────────
          // PASSENGER ACCEPTED RIDE BOTTOM SHEET
          // ─────────────────────────────────────
          if (userController.userModel.value?.userProfile?.role ==
              AppConstants.passenger &&
              rideController.acceptRideModel.value?.isRideAccepted == true)
            DraggableBottomSheet(
              acceptRideModel: rideController.acceptRideModel.value,
            ),

          // ─────────────────────────────────────
          // RIDE REQUEST MODAL BOTTOM SHEET
          // ─────────────────────────────────────
          Obx(() {
            if (googleSearchLocationController.isModalOn.value &&
                rideController.viewInMap.value &&
                rideController.viewInMapReturn.value == false) {
              return Positioned(
                top: 0, bottom: 0, left: 0, right: 0,
                child: BottomSheet(
                  onClosing: () {},
                  backgroundColor: Colors.transparent,
                  enableDrag: false,
                  builder: (context) {
                    return RideRequestBottomSheet(
                      pickupLocation:
                      googleSearchLocationController.pickupController.text,
                      dropLocation:
                      googleSearchLocationController.dropController.text,
                      distance: googleSearchLocationController.distance.value
                          .toString(),
                      rideFare:
                      googleSearchLocationController.fare.value.toString(),
                    );
                  },
                ),
              );
            }
            return SizedBox.shrink();
          }),

          // ─────────────────────────────────────
          // CUSTOM HEADER (passenger only)
          // ─────────────────────────────────────
          if (userController.userModel.value?.userProfile?.role ==
              AppConstants.passenger)
            Obx(() {
              if (rideController.viewInMap.value &&
                  rideController.viewInMapReturn.value == false) {
                return CustomHeader(mapOPTController: mapOPTController);
              }
              return MapCustomHeaderBack(rideController: rideController);
            }),

          // ─────────────────────────────────────
          // SAFE AREA OVERLAY
          // ─────────────────────────────────────
          SafeArea(
            child: Column(
              children: [

                // ── Driver Toggle Switch ────────
                Obx(() {
                  if (userController.userModel.value?.userProfile?.role ==
                      AppConstants.driver &&
                      mapOPTController.acceptedRideDataStatus.value == false) {
                    return AnimatedToggleSwitch();
                  }
                  return const SizedBox.shrink();
                }),

                // ── Driver accepted ride debug text ─
                Obx(() {
                  if (mapOPTController
                      .acceptedRideData.value?.isRideAcceptedDriver ==
                      true) {
                    return Text(
                      'safdsdfasdfasdfsadfasd',
                      style: TextStyle(color: Colors.red, fontSize: 82),
                    );
                  }
                  return SizedBox.shrink();
                }),

                // ── Driver offline banner ───────
                Obx(() {
                  final cnt = Get.find<MapOPTController>();
                  if (userController.userModel.value?.userProfile?.role ==
                      AppConstants.driver &&
                      cnt.userController.userModel.value?.driverProfile
                          ?.isOnline ==
                          false) {
                    return NoInternetMessageMap();
                  }
                  return SizedBox.shrink();
                }),

                Spacer(),

                // ── Passenger Swipe Button ──────
                Obx(() {
                  final role =
                      userController.userModel.value?.userProfile?.role;
                  if (role == AppConstants.passenger &&
                      googleSearchLocationController.isModalOn.value == false &&
                      rideController.isSwippedButtonShow.value == false &&
                      rideController.viewInMap.value == true) {
                    return Column(
                      children: [
                        _buildSwippedButton(),
                        SizedBox(height: 100),
                      ],
                    );
                  }
                  return SizedBox.shrink();
                }),

                // ── Driver Bottom Cards ─────────
                Obx(() {

                  // State 1: Driver online, waiting for request
                  if (userController.userModel.value?.userProfile?.role ==
                      AppConstants.driver &&
                      mapOPTController.isPassengerRequest.value == false &&
                      userController.userModel.value?.driverProfile?.isOnline ==
                          true) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 90.h),
                      padding: EdgeInsets.symmetric(horizontal: 25.w),
                      child: _bgGlassDesign(_buildPassengerRequestCard()),
                    );
                  }

                  // State 2: New passenger request arrived
                  if (userController.userModel.value?.userProfile?.role ==
                      AppConstants.driver &&
                      mapOPTController.isPassengerRequest.value == true &&
                      mapOPTController.acceptedRideDataStatus.value == false) {
                    return GlassBackgroundMultipleChildrenWidget(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      blurOne: 20,
                      blurTwo: 20,
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 5.h,
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Color(0xFFB9C0C9),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        SizedBox(height: 50.h),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius:
                              BorderRadius.all(Radius.circular(50)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  (mapOPTController.rideDetailsData.value
                                      ?.passengerImage !=
                                      null &&
                                      mapOPTController.rideDetailsData
                                          .value!.passengerImage!.isNotEmpty)
                                      ? '${ApiUrls.imageBaseUrl}${mapOPTController.rideDetailsData.value?.passengerImage}'
                                      : '',
                                  height: 50.h,
                                  width: 50.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      Assets.images.defaultImage.path,
                                      height: 50.h,
                                      width: 50.w,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mapOPTController.rideDetailsData.value
                                      ?.passengerName ??
                                      '',
                                  style: TextStyle(
                                    color: Color(0xff171717),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: FontFamily.poppins,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '\$${mapOPTController.rideDetailsData.value?.fare ?? 0.0} ',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '(${((mapOPTController.rideDetailsData.value?.destinationMeters ?? 0) * 0.000621371).toStringAsFixed(2)} Miles)',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Divider(
                            height: 1,
                            color: Colors.black.withOpacity(0.2)),
                        SizedBox(height: 6.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(Assets.images.directRight.path),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'PICK UP',
                                        style: TextStyle(
                                          color: AppColors.labelTextColor,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: FontFamily.poppins,
                                        ),
                                      ),
                                      Text(
                                        mapOPTController.rideDetailsData.value
                                            ?.pickupAddress ??
                                            'Pickup location not specified',
                                        style: textStyle(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 4.w, top: 4.h, bottom: 4.h),
                              child: Container(
                                width: 4.w,
                                height: 40.h,
                                decoration:
                                BoxDecoration(color: Colors.white),
                              ),
                            ),
                            Row(
                              children: [
                                Image.asset(Assets.images.location.path),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DROP OFF',
                                        style: TextStyle(
                                          color: AppColors.labelTextColor,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: FontFamily.poppins,
                                        ),
                                      ),
                                      Text(
                                        mapOPTController.rideDetailsData.value
                                            ?.destinationAddress ??
                                            'Destination not specified',
                                        style: textStyle(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Divider(
                            height: 1,
                            color: Colors.black.withOpacity(0.2)),
                        SizedBox(height: 8.h),
                        Text(
                          'Passengers Note',
                          style: TextStyle(
                            color: Color(0xff5E5E5E).withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          mapOPTController.rideDetailsData.value
                              ?.destinationAddress ??
                              '',
                        ),
                        SizedBox(height: 18.h),
                        AcceptRideButton(
                          onPressed: () {
                            mapOPTController.rideAcceptRide(
                              mapOPTController.rideDetailsData.value!.rideId
                                  .toString(),
                            );
                          },
                        ),
                        SizedBox(height: 80),
                      ],
                    );
                  }

                  // State 3: Driver accepted, in trip
                  if (mapOPTController
                      .acceptedRideData.value?.isRideAcceptedDriver ==
                      true &&
                      mapOPTController.acceptedRideDataStatus.value == true) {
                    return GlassBackgroundWidget(child: Text('marufsd'));
                  }

                  return SizedBox.shrink();
                }),
              ],
            ),
          ),

          // ─────────────────────────────────────
          // LOCATION DISABLED BANNER
          // ─────────────────────────────────────
          StreamBuilder<bool>(
            stream: _locationStatusStream(),
            builder: (context, snapshot) {
              if (snapshot.data == false) {
                return Positioned(
                  top: 0, left: 0, right: 0,
                  child: Material(
                    color: Colors.red,
                    child: SafeArea(
                      minimum: EdgeInsets.only(bottom: 25),
                      bottom: true,
                      left: true,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 20, bottom: 20, left: 12, right: 12),
                        child: Row(
                          children: [
                            Icon(Icons.location_off, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Location is disabled. Enable to continue.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                LocationPermissionService.openLocationSettings();
                              },
                              child: Text(
                                'ENABLE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),

        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  // HELPER WIDGETS
  // ════════════════════════════════════════════

  TextStyle textStyle() {
    return TextStyle(
      color: AppColors.primaryHeadingTextColor,
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      fontFamily: FontFamily.poppins,
    );
  }

  void _showDriverDialog(driver) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      driver.image != null && driver.image!.isNotEmpty
                          ? ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          '${ApiUrls.imageBaseUrl}${driver.image}',
                          fit: BoxFit.cover,
                          height: 60,
                          width: 60,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                'assets/images/driver.png',
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                              ),
                        ),
                      )
                          : CircleAvatar(
                        radius: 30,
                        child: Image.asset(
                          'assets/images/driver.png',
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${driver.name}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                    '${driver.rating} (${driver.totalRatings})'),
                                const SizedBox(width: 8),
                                const Text('|'),
                                const SizedBox(width: 8),
                                Text('${driver.trips} Trips'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text('${driver.phone}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        child: IconButton(
                          icon: const Icon(Icons.phone, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Car Info.',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${driver.vehicle?.carName}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('${driver.vehicle?.numberOfSeat} Seat'),
                            const SizedBox(height: 4),
                            Text('${driver.vehicle?.carPlateNumber}'),
                            const SizedBox(height: 4),
                            const Text('1 km away from you.',
                                style: TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: driver.image != null &&
                            driver.image!.isNotEmpty
                            ? Image.network(
                          '${ApiUrls.imageBaseUrl}${driver.image}',
                          width: 92.w,
                          height: 92.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                'assets/images/driver.png',
                                width: 92.w,
                                height: 92.h,
                                fit: BoxFit.cover,
                              ),
                        )
                            : Image.asset(
                          'assets/images/driver.png',
                          width: 92.w,
                          height: 92.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RequestRideHandler(
                    cnt: rideController,
                    cardDetails: driver,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bgGlassDesign(child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.whiteColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.whiteColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, -4),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildPassengerRequestCard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(Assets.images.waiting.path, fit: BoxFit.cover),
        Text(
          'Waiting for Passenger request...',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            fontFamily: FontFamily.poppins,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSwippedButton() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: SlideAction(
        sliderButtonYOffset: 0,
        onSubmit: () => Get.toNamed(
          AppRoutes.searchLocationScreen,
          arguments: {'back_disable': true},
        ),
        text: 'Lets Go...',
        textStyle: TextStyle(
          fontSize: 20.sp,
          color: AppColors.whiteColor,
          fontWeight: FontWeight.w500,
          fontFamily: FontFamily.poppins,
        ),
        innerColor: AppColors.greenColor,
        outerColor: AppColors.blackButton,
        sliderButtonIcon: const Icon(
          Icons.arrow_right_alt,
          color: Color(0XFFF6F6F6),
          size: 24,
          weight: 900,
        ),
        sliderRotate: false,
        height: 56.h,
        sliderButtonIconPadding: 8,
      ),
    );
  }

  Stream<bool> _locationStatusStream() {
    return Stream.periodic(Duration(seconds: 5), (_) async {
      return await LocationPermissionService.isLocationEnabled();
    }).asyncMap((event) => event);
  }
}
*
*
* */