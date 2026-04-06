import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:ricardo/feature/models/home/ride_status_model.dart'
    as rideModel;
import 'package:ricardo/feature/models/socket/accept_ride_driver_model.dart';
import 'package:ricardo/feature/models/socket/accept_ride_model.dart';
import 'link_export_file.dart';

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

  BitmapDescriptor? customMarker;
  BitmapDescriptor? customCarMarker;

  double currentZoom = 18.5;
  bool _isLoading = true;
  bool _hasLocation = false;
  String _errorMessage = '';

  // Default location (will be replaced when real location is obtained)
  static const LatLng _defaultLocation = LatLng(37.7749, -122.4194);

  /* Init State are start here */
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize markers
    _initMarkers();

    // Initialize location and map
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });

    // Listen to ride accepted changes
    // ever(rideController.isRideAccepted, (bool accepted) {
    //   if (accepted == true) {
    //     _loadRoute();
    //   }
    // });
  }

  /* Init State are end here */

  // Initial Marker are here
  Future<void> _initMarkers() async {
    customMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(
        devicePixelRatio: 1.0,
        size: Size(50, 50),
      ),
      "assets/images/location_black_marker.png",
    );

    customCarMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(
        devicePixelRatio: 1.0,
        size: Size(50, 50),
      ),
      "assets/images/car_marker.png",
    );
    setState(() {});
  }

  Future<void> _initializeMap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    bool hasPermission = await _requestLocationPermission();
    if (!hasPermission) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Location permission is required to use this app';
      });
      return;
    }

    await _getCurrentLocation();
    await connectSocket();
    await userController.fetchUser();
    // await _loadRoute();

    setState(() {
      _isLoading = false;
    });
  }

  // Permission Related work
  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDeniedDialog();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionPermanentlyDeniedDialog();
      return false;
    }

    return true;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs location access to show your position on the map and find nearby rides.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeMap();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission is permanently denied. Please enable it in settings to use this app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Current Location Related work are here
  Future<void> _getCurrentLocation() async {
    try {
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));

      // Update controllers
      mapOPTController.currentLatitudePosition?.value = position.latitude;
      mapOPTController.currentLongitudePosition?.value = position.longitude;

      // Get address from coordinates
      await mapOPTController.getLocation();

      setState(() {
        _hasLocation = true;
      });

      // Start location tracking stream
      _startLocationTracking();

      // Animate camera to current location
      if (_mapController != null) {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: currentZoom,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _errorMessage = 'Could not get your location. Using default location.';
        _hasLocation = true; // Still show map with default location
      });
    }
  }

  // Socket Related work are here
  Future<void> connectSocket() async {
    String? fcmToken = await FirebaseNotificationService.getFCMToken();
    await PrefsHelper.setString(AppConstants.fcmToken, fcmToken);

    // New ride request
    SocketServices.socket?.on('new-ride-request', (data) {
      if (data['newRideRequest'] == true) {
        mapOPTController.startRideRequestTimer(); // ✅ add this line
        mapOPTController.isPassengerRequest.value = true;
        mapOPTController.rideDetailsData.value =
            RideDetailsSocketModel.fromJson(data['rideDetails']);
      }
    });

    // Cancel ride request
    SocketServices.socket?.on('cancel-ride-request', (data) {
      if (data['isCancelPickRequest'] == true) {
        mapOPTController.isPassengerRequest.value = false;
        mapOPTController.cancelRideRequestTimer(); // ✅ add this line
      }
    });

    SocketServices.socket?.on('ride-accepted', (data) {
      if (data is! Map<String, dynamic>) return;
      if (data['isRideAccepted'] != true) return;

      final driver = data['driver'];
      rideController.isRideAccepted.value = true;
      rideController.acceptedRideDriverName.value =
          (driver is Map ? driver['driverName'] : null) ?? '';

      try {
        rideController.acceptRideModel.value = AcceptRideModel.fromJson(data);
      } catch (e) {
        debugPrint('ride-accepted parse error: $e');
      }
    });

    // Ride accepted (driver side)
    SocketServices.socket?.on('ride-accepted-driver', (data) {
      if (data is Map<String, dynamic>) {
        if (data['isRideAcceptedDriver'] == true) {
          mapOPTController.acceptedRideDriverDataStatus.value = true;
          mapOPTController.acceptedRideDriverData.value =
              AcceptRideDriverModel.fromJson(data);
          // _loadAcceptedRideRoute();
        }
      }
    });

    SocketServices.socket?.on('get-ride-driver-location', (data) {
      print('===================================>>> GET RIDE DRIVER $data');
    });

    SocketServices.socket?.on('ride-status', (data) {
      try {
        Map<String, dynamic> jsonData;

        if (data is List) {
          jsonData = Map<String, dynamic>.from(data[0]);
        } else if (data is String) {
          jsonData = jsonDecode(data);
        } else if (data is Map) {
          jsonData = Map<String, dynamic>.from(data);
        } else {
          return;
        }

        final rideModel.RideStatusModel rideStatus =
            rideModel.RideStatusModel.fromJson(jsonData);

        // ✅ Store in controller so UI can react
        mapOPTController.rideStatusData.value = rideStatus;

        if (rideStatus.acceptRide == true) {
          rideController.drivers.clear();
          mapOPTController.isCurrentMarkerShow.value = true;
        } else if (rideStatus.ongoingRide == true){
          _loadAcceptedRideRoute();
          debugPrint('🚗 ride-status: Driver arriving');
        }else if (rideStatus.arrivingRide == true)   {
          debugPrint('🛣️ ride-status: Ride ongoing');
        } else if (rideStatus.completeRide == true) {
          // ✅ Ride done — clear all state and stop listening
          debugPrint('🏁 ride-status: Ride complete');
          rideController.isRideAccepted.value = false;
          rideController.acceptRideModel.value = null;
          mapOPTController.acceptedRideDriverDataStatus.value = false;
          mapOPTController.acceptedRideDriverData.value = null;
          mapOPTController.isPassengerRequest.value = false;
          mapOPTController.rideStatusData.value = null;
          mapOPTController.rideRequestReceivedAt.value = null;
          PrefsHelper.setString('status', '');
          PrefsHelper.setString('ride-accepted-data', '');
          PrefsHelper.setString('driver-status', '');
          PrefsHelper.setString('ride-accepted-driver-data', '');
          SocketServices.socket
              ?.off('ride-status'); // ✅ Stop listening after complete
        } else if (rideStatus.driverCancel == true ||
            rideStatus.passengerCancel == true) {
          // ✅ Cancelled — clear all state and stop listening
          debugPrint('❌ ride-status: Ride cancelled');
          rideController.isRideAccepted.value = false;
          rideController.acceptRideModel.value = null;
          mapOPTController.acceptedRideDriverDataStatus.value = false;
          mapOPTController.acceptedRideDriverData.value = null;
          mapOPTController.isPassengerRequest.value = false;
          mapOPTController.rideStatusData.value = null;
          mapOPTController.rideRequestReceivedAt.value = null;
          PrefsHelper.setString('status', '');
          PrefsHelper.setString('ride-accepted-data', '');
          PrefsHelper.setString('driver-status', '');
          PrefsHelper.setString('ride-accepted-driver-data', '');
          SocketServices.socket
              ?.off('ride-status'); // ✅ Stop listening after cancel
        }
      } catch (e, stackTrace) {
        print('ride-status ERROR: $e');
        print('STACK: $stackTrace');
      }
    });
  }

  void _startLocationTracking() async {
    String? token = await PrefsHelper.getString(AppConstants.bearerToken);

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      LatLng newLocation = LatLng(position.latitude, position.longitude);

      // Update controller
      mapOPTController.currentLatitudePosition?.value = position.latitude;
      mapOPTController.currentLongitudePosition?.value = position.longitude;

      // Emit to socket
      if (token != null) {
        SocketServices.socket?.emit('update-user-location', {
          "accessToken": token,
          "location": {
            "type": "Point",
            "coordinates": [newLocation.longitude, newLocation.latitude]
          }
        });
      }

      // Update map if needed
      if (_mapController != null && mounted) {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: newLocation, zoom: currentZoom),
          ),
        );
      }
    }, onError: (error) {
      print('Location stream error: $error');
    });
  }

  Set<Marker> _buildMarkers() {
    final Set<Marker> result = {};

    // Current position marker
    final currentLat = mapOPTController.currentLatitudePosition?.value ?? 0.0;
    final currentLng = mapOPTController.currentLongitudePosition?.value ?? 0.0;

    if (currentLat != 0.0 && currentLng != 0.0) {
      result.add(
        Marker(
          markerId: const MarkerId('currentPassenger'),
          position: LatLng(currentLat, currentLng),
          icon: userController.userModel.value?.userProfile?.role ==
                  AppConstants.passenger
              ? customMarker ?? BitmapDescriptor.defaultMarker
              : customCarMarker ?? BitmapDescriptor.defaultMarker,
          visible: mapOPTController.isCurrentMarkerShow.value,
        ),
      );
    }

    // Add route markers
    for (final m in markers) {
      if (m.markerId.value != 'currentPassenger') {
        result.add(m);
      }
    }

    // Driver markers
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
          result.add(
            Marker(
              markerId: MarkerId(driver.sId ?? UniqueKey().toString()),
              position: LatLng(coords[1], coords[0]),
              icon: customCarMarker ?? BitmapDescriptor.defaultMarker,
              onTap: () => _showDriverDialog(driver),
            ),
          );
        }
      }
    }

    return result;
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
                          onPressed: () {
                            // Add call logic here
                          },
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
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
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
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('${driver.vehicle?.numberOfSeat} Seat'),
                            const SizedBox(height: 4),
                            Text('${driver.vehicle?.carPlateNumber}'),
                            const SizedBox(height: 4),
                            const Text(
                              '1 km away from you.',
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: driver.image != null && driver.image!.isNotEmpty
                            ? Image.network(
                                '${ApiUrls.imageBaseUrl}${driver.image}',
                                width: 92,
                                height: 92,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                  'assets/images/driver.png',
                                  width: 92,
                                  height: 92,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                'assets/images/driver.png',
                                width: 92,
                                height: 92,
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

  Widget _buildSwippedButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: SlideAction(
        sliderButtonYOffset: 0,
        onSubmit: () => Get.toNamed(AppRoutes.searchLocationScreen,
            arguments: {'back_disable': true}),
        text: 'Lets Go...',
        textStyle: TextStyle(
          fontSize: 20,
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
        height: 56,
        sliderButtonIconPadding: 8,
      ),
    );
  }

  Widget _bgGlassDesign(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: 8,
          sigmaY: 8,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.whiteColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.whiteColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, -4),
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

  Future<void> _loadAcceptedRideRoute() async {
    try {
      final acceptedRide = mapOPTController.acceptedRideDriverData.value;
      if (acceptedRide == null) return;

      final Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final LatLng driverLocation = LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      final pickupCoords = acceptedRide.ride?.pickupLocation?.coordinates;
      if (pickupCoords == null || pickupCoords.length < 2) return;
      final LatLng pickupLocation = LatLng(pickupCoords[1], pickupCoords[0]);

      final destCoords = acceptedRide.ride?.destinationLocation?.coordinates;
      if (destCoords == null || destCoords.length < 2) return;
      final LatLng destinationLocation = LatLng(destCoords[1], destCoords[0]);

      if (driverLocation.latitude == 0.0 ||
          pickupLocation.latitude == 0.0 ||
          destinationLocation.latitude == 0.0) {
        debugPrint('Skipping — coords not ready');
        return;
      }

      final List<LatLng> driverToPickup = await DirectionsService.getPolyline(
        driverLocation,
        pickupLocation,
      );
      final List<LatLng> pickupToDestination =
      await DirectionsService.getPolyline(
        pickupLocation,
        destinationLocation,
      );

      if (driverToPickup.isEmpty) return;

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('driver_to_pickup'),
            points: driverToPickup,
            color: Colors.black87,
            width: 6,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        };

        markers.removeWhere((m) =>
        m.markerId.value == 'driver_location' ||
            m.markerId.value == 'pickup_location' );

        markers.addAll({
          Marker(
            markerId: const MarkerId('driver_location'),
            position: driverLocation,
            icon: customCarMarker ?? BitmapDescriptor.defaultMarker,
          ),
          Marker(
            markerId: const MarkerId('pickup_location'),
            position: pickupLocation,
            icon: BitmapDescriptor.defaultMarker,
          ),
        });
      });

      final allPoints = [...driverToPickup, ...pickupToDestination];
      final bounds = _boundsFromLatLng(allPoints);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    } catch (e) {
      debugPrint('_loadAcceptedRideRoute error: $e');
    }
  }
  LatLngBounds _boundsFromLatLng(List<LatLng> points) {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Map or Loading
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Loading map...'),
                ],
              ),
            )
          else if (_hasLocation)
            Obx(
                  () => GoogleMap(
                mapToolbarEnabled: false,
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
                trafficEnabled: false,
                zoomGesturesEnabled: true,
                fortyFiveDegreeImageryEnabled: true,
                indoorViewEnabled: true,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    mapOPTController.currentLatitudePosition?.value ??
                        _defaultLocation.latitude,
                    mapOPTController.currentLongitudePosition?.value ??
                        _defaultLocation.longitude,
                  ),
                  zoom: currentZoom,
                ),
                markers: _buildMarkers(),
                polylines: _polylines,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                circles: {
                  Circle(
                    circleId: const CircleId('currentDriver'),
                    center: LatLng(
                      mapOPTController.currentLatitudePosition?.value ?? 0.0,
                      mapOPTController.currentLongitudePosition?.value ?? 0.0,
                    ),
                    radius: 30,
                    strokeColor: Colors.white,
                    strokeWidth: 2,
                    fillColor: const Color(0xFF006491).withOpacity(0.2),
                  ),
                },
              ),
            )
            // userController.userModel.value?.userProfile?.role ==
            //         AppConstants.passenger
            //     ? _buildPassengerMap()
            //     : _buildDriverMap()
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 50),
                  const SizedBox(height: 20),
                  Text(_errorMessage.isNotEmpty
                      ? _errorMessage
                      : 'Unable to get your location'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _initializeMap(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),

          // Bottom Sheet for passenger
          if (userController.userModel.value?.userProfile?.role ==
                  AppConstants.passenger &&
              rideController.acceptRideModel.value?.isRideAccepted == true )
            DraggableBottomSheet(
              acceptRideModel: rideController.acceptRideModel.value,
              controller: mapOPTController,
            ),

          // Ride request bottom sheet
          Obx(() {
            if (googleSearchLocationController.isModalOn.value &&
                rideController.viewInMap.value &&
                rideController.viewInMapReturn.value == false) {
              return Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
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
            return const SizedBox.shrink();
          }),

          // Custom Header
          if (userController.userModel.value?.userProfile?.role ==
              AppConstants.passenger)
            Obx(() {
              if (rideController.viewInMap.value &&
                  rideController.viewInMapReturn.value == false) {
                return CustomHeader(mapOPTController: mapOPTController);
              }
              return MapCustomHeaderBack(
                rideController: rideController,
              );
            }),

          // Safe area content
          SafeArea(
            child: Column(
              children: [
                Obx(() {
                  if (mapOPTController
                          .acceptedRideDriverData.value?.isRideAcceptedDriver ==
                      true) {
                    return SizedBox(
                      height: 20.h,
                    );
                  }
                  return SizedBox.shrink();
                }),
                SizedBox(
                  height: 20,
                ),
                // Driver toggle switch
                Obx(() {
                  if (userController.userModel.value?.userProfile?.role ==
                          AppConstants.driver &&
                      mapOPTController.acceptedRideDriverDataStatus.value ==
                          false) {
                    return AnimatedToggleSwitch();
                  }
                  return const SizedBox.shrink();
                }),

                // Accepted ride info for driver
                Obx(() {
                  if (mapOPTController
                          .acceptedRideDriverData.value?.isRideAcceptedDriver ==
                      true) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: SizedBox(
                        width: double.infinity,
                        child: GlassBackgroundWidget(
                          borderLeftRightRadius: 24,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(
                                Icons.location_pin,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${mapOPTController.acceptedRideDriverData.value?.ride?.destinationAddress}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: FontFamily.poppins,
                                        color: const Color(0xff171717),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    FutureBuilder<String>(
                                      future: DirectionsService()
                                          .getCurrentAddress(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Text('Loading...');
                                        }
                                        if (snapshot.hasError) {
                                          return const Text(
                                              'Error getting address');
                                        }
                                        return Text(
                                          snapshot.data ?? 'No address found',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: FontFamily.poppins,
                                            color: const Color(0xffA3A3A3),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // No internet message
                Obx(() {
                  final cnt = Get.find<MapOPTController>();
                  if (userController.userModel.value?.userProfile?.role ==
                          AppConstants.driver &&
                      cnt.userController.userModel.value?.driverProfile
                              ?.isOnline ==
                          false) {
                    return const NoInternetMessageMap();
                  }
                  return const SizedBox.shrink();
                }),

                const Spacer(),

                // Swipped button for passenger
                Obx(() {
                  final role =
                      userController.userModel.value?.userProfile?.role;
                  if (role == AppConstants.passenger &&
                      googleSearchLocationController.isModalOn.value == false &&
                      rideController.isSwippedButtonShow.value == false &&
                      rideController.viewInMap.value == true &&
                      rideController.isRideAccepted.value == false) {
                    return Column(
                      children: [
                        _buildSwippedButton(),
                        const SizedBox(height: 100),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Driver waiting for passenger
                Obx(() {
                  if (userController.userModel.value?.userProfile?.role ==
                          AppConstants.driver &&
                      mapOPTController.isPassengerRequest.value == false &&
                      userController.userModel.value?.driverProfile?.isOnline ==
                          true &&
                      mapOPTController.acceptedRideDriverDataStatus.value ==
                          false) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 90),
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: _bgGlassDesign(CustomPassengerWaitingGif()),
                    );
                  }

                  if (userController.userModel.value?.userProfile?.role ==
                          AppConstants.driver &&
                      mapOPTController.isPassengerRequest.value == true &&
                      mapOPTController.acceptedRideDriverDataStatus.value ==
                          false) {
                    return const PassengerRideRequestSheet();
                  }

                  if (mapOPTController.acceptedRideDriverData.value
                                  ?.isRideAcceptedDriver ==
                              true &&
                          mapOPTController.acceptedRideDriverDataStatus.value ==
                              true ||
                      mapOPTController.acceptedRideDriverData.value
                                  ?.isRideAcceptedDriver ==
                              true &&
                          mapOPTController.acceptedRideDriverDataStatus.value ==
                              true) {
                    return GlassBackgroundWidget(
                      child: Obx(() {
                        final rideStatus =
                            mapOPTController.rideStatusData.value;

                        // ── Determine current driver state ──────────────
                        final bool isOnTheWay =
                            rideStatus == null || rideStatus.acceptRide == true;
                        final bool isArriving =
                            rideStatus?.arrivingRide == true;
                        final bool isOngoing = rideStatus?.ongoingRide == true;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),

                            // ── Distance / time row ─────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    isOngoing
                                        ? 'Ride is in progress'
                                        : isArriving
                                        ? 'Rider Arrive'
                                        : '( 4 min ) ${((mapOPTController.acceptedRideDriverData.value?.ride?.destinationMeters ?? 0) * 0.000621371).toStringAsFixed(2)} Miles',
                                    style: const TextStyle(
                                      color: Color(0xff171717),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    // ✅ moved here
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // ✅ Remove Expanded, use fixed size instead
                                GestureDetector(
                                  onTap: () {
                                    mapOPTController.showCancelReasonDialog.value = true;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                          color: Colors.red, width: 1),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      // ✅ wrap content
                                      children: [
                                        Icon(Icons.block,
                                            color: Colors.red, size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            Divider(
                                height: 1,
                                color: Colors.black.withOpacity(0.2)),
                            const SizedBox(height: 16),

                            // ── Passenger info row ──────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          (mapOPTController
                                              .rideDetailsData
                                              .value
                                              ?.passengerImage !=
                                              null &&
                                              mapOPTController
                                                  .rideDetailsData
                                                  .value!
                                                  .passengerImage!
                                                  .isNotEmpty)
                                              ? '${ApiUrls.imageBaseUrl}${mapOPTController.rideDetailsData.value?.passengerImage}'
                                              : '',
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/images/default_image.jpg',
                                              height: 50,
                                              width: 50,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mapOPTController.rideDetailsData.value
                                              ?.passengerName ??
                                              '',
                                          style: TextStyle(
                                            color: const Color(0xff171717),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: FontFamily.poppins,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '\$${mapOPTController.rideDetailsData.value?.fare ?? 0.0} ',
                                              style: const TextStyle(
                                                fontSize: 16,
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
                                GestureDetector(
                                  onTap: () {
                                    launchUrl(Uri.parse(
                                        "tel:${mapOPTController.rideDetailsData.value?.passengerPhone}"));
                                  },
                                  child: RepaintBoundary(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.whiteColor,
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: SvgPicture.asset(
                                          Assets.icons.driverCardPhone),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ── PRIMARY ACTION BUTTON ───────────────────
                            CustomPrimaryButton(
                              title: isOngoing
                                  ? 'Complete Ride'
                                  : isArriving
                                  ? 'Start Ride' // arrivingRide == true
                                  : isOnTheWay
                                  ? 'On the way' // acceptRide == true
                                  : 'Arrive in Place', // null / initial state
                              onHandler: () async {
                                if (rideStatus != null) {
                                  // ✅ Initial — driver heading to pickup
                                  debugPrint('🚕 On the way to pickup');
                                  final rideId = mapOPTController.acceptedRideDriverData.value?.ride?.sId;
                                  mapOPTController.rideStatusChange(rideId!, 'ongoing');
                                  // TODO: emit on-the-way socket or call API
                                } else if (isOnTheWay) {

                                  // ✅ Accepted — driver arrived at pickup
                                  debugPrint('📍 Arrived at pickup');
                                  // TODO: emit arrive-in-place socket or call API
                                } else if (isArriving) {
                                  // ✅ Driver at pickup — start the ride
                                  debugPrint('🚗 Starting ride...');
                                  // TODO: emit start-ride socket or call API
                                } else if (isOngoing) {
                                  // ✅ Ride ongoing — complete it
                                  debugPrint('🏁 Completing ride...');
                                  // TODO: emit complete-ride socket or call API
                                }
                              },
                            ),

                            const SizedBox(height: 80),
                          ],
                        );
                      }),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),

          // Location disabled banner
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
                      bottom: true,
                      left: true,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 20, left: 12, right: 12),
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
                              onPressed: () {
                                LocationPermissionService
                                    .openLocationSettings();
                              },
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

  Stream<bool> _locationStatusStream() {
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      return await Geolocator.isLocationServiceEnabled();
    }).asyncMap((event) => event);
  }

  // Cancel Related work are here
  void _showCancelReasonDialog(BuildContext context) {
    final reasons = [
      'Passenger no show',
      'Difficult pickup location',
      'Unaccompanied minor',
      'No car seat',
      'Too many bags',
      'Other safety concern',
      'Destination changed',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.red,
      barrierColor: Colors.green,
      builder: (context) {
        String? selectedReason;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return GlassBackgroundWidget(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 30,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Drag handle ──────────────────────
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // ── Close button ─────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── Title ────────────────────────────
                  const Center(
                    child: Text(
                      'Choose Reason For Cancelling',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 8),

                  // ── Reason list ──────────────────────
                  ...reasons.map((reason) => GestureDetector(
                    onTap: () =>
                        setDialogState(() => selectedReason = reason),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedReason == reason
                                    ? Colors.green
                                    : Colors.grey,
                                width: 2,
                              ),
                              color: selectedReason == reason
                                  ? Colors.green
                                  : Colors.transparent,
                            ),
                            child: selectedReason == reason
                                ? const Icon(
                              Icons.check,
                              size: 13,
                              color: Colors.white,
                            )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            reason,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),

                  const SizedBox(height: 24),

                  // ── Cancel button ────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        disabledBackgroundColor: Colors.red.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: selectedReason == null
                          ? null
                          : () {
                        Navigator.pop(context);
                        debugPrint('❌ Cancel reason: $selectedReason');
                        // TODO: emit cancel-ride socket or call API
                      },
                      child: const Text(
                        'Cancel Ride',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Passenger Map ────────────────────────────
  Widget _buildPassengerMap() {
    return Obx(
      () => GoogleMap(
        mapToolbarEnabled: false,
        scrollGesturesEnabled: true,
        rotateGesturesEnabled: true,
        trafficEnabled: false,
        zoomGesturesEnabled: true,
        fortyFiveDegreeImageryEnabled: true,
        indoorViewEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            mapOPTController.currentLatitudePosition?.value ??
                _defaultLocation.latitude,
            mapOPTController.currentLongitudePosition?.value ??
                _defaultLocation.longitude,
          ),
          zoom: currentZoom,
        ),
        markers: _buildMarkers(),
        polylines: _polylines,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: false,
        circles: {
          Circle(
            circleId: const CircleId('currentPassenger'),
            center: LatLng(
              mapOPTController.currentLatitudePosition?.value ?? 0.0,
              mapOPTController.currentLongitudePosition?.value ?? 0.0,
            ),
            radius: 30,
            strokeColor: Colors.white,
            strokeWidth: 2,
            fillColor: const Color(0xFF006491).withOpacity(0.2),
          ),
        },
      ),
    );
  }

// ── Driver Map ───────────────────────────────
  Widget _buildDriverMap() {
    return Obx(
      () => GoogleMap(
        mapToolbarEnabled: false,
        scrollGesturesEnabled: true,
        rotateGesturesEnabled: true,
        trafficEnabled: false,
        zoomGesturesEnabled: true,
        fortyFiveDegreeImageryEnabled: true,
        indoorViewEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            mapOPTController.currentLatitudePosition?.value ??
                _defaultLocation.latitude,
            mapOPTController.currentLongitudePosition?.value ??
                _defaultLocation.longitude,
          ),
          zoom: currentZoom,
        ),
        markers: _buildMarkers(),
        polylines: _polylines,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: false,
        circles: {
          Circle(
            circleId: const CircleId('currentDriver'),
            center: LatLng(
              mapOPTController.currentLatitudePosition?.value ?? 0.0,
              mapOPTController.currentLongitudePosition?.value ?? 0.0,
            ),
            radius: 30,
            strokeColor: Colors.white,
            strokeWidth: 2,
            fillColor: const Color(0xFF006491).withOpacity(0.2),
          ),
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    positionStream?.cancel();
    SocketServices.socket?.off('new-ride-request');
    SocketServices.socket?.off('cancel-ride-request');
    SocketServices.socket?.off('ride-accepted');
    SocketServices.socket?.off('ride-accepted-driver');
    SocketServices.socket?.off('ride-status');
    super.dispose();
  }
}
