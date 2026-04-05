import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ricardo/feature/models/home/ride_status_model.dart' as rideModel;
import 'package:ricardo/feature/models/socket/accept_ride_driver_model.dart';
import 'package:ricardo/feature/models/socket/accept_ride_model.dart';
import 'package:ricardo/feature/models/socket/ride_details_socket_model.dart';
import 'package:ricardo/feature/view/home/map/custom_header.dart';
import 'package:ricardo/feature/view/home/map/draggable_bottom_sheet.dart';
import 'package:ricardo/widgets/accepted_ride_button.dart';
import 'package:ricardo/widgets/custom_passenger_waiting_gif.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/glass_background_multiple_children_widget.dart';
import 'package:ricardo/widgets/glass_background_widget.dart';
import 'package:ricardo/widgets/map_custom_header_back.dart';
import 'package:ricardo/widgets/no_internet_message_map.dart';
import 'package:ricardo/widgets/request_ride_handler.dart';
import 'package:url_launcher/url_launcher.dart';
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

  double currentZoom = 14.0;
  bool _isLoading = true;
  bool _hasLocation = false;
  String _errorMessage = '';

  // Default location (will be replaced when real location is obtained)
  static const LatLng _defaultLocation = LatLng(37.7749, -122.4194);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize markers
    _initMarkers();

    // Initialize location and map
    WidgetsBinding.instance.addPostFrameCallback((_)  {
       _initializeMap();
    });

    // Listen to ride accepted changes
    ever(rideController.isRideAccepted, (bool accepted) {
      if (accepted == true) {
        _loadRoute();
      }
    });

  }

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

    // ✅ Restore ride state if app was closed mid-ride
    // await _restoreRideState();
    // await _restoreDriverRideState();

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
    await _loadRoute();

    setState(() {
      _isLoading = false;
    });
  }

  // Local Storage data are here
  Future<void> _restoreRideState() async {
    final status = await PrefsHelper.getString('status');
    if (status != 'ride-accepted') return;

    final savedData = await PrefsHelper.getString('ride-accepted-data');
    if (savedData == null || savedData.isEmpty) return;

    try {
      final Map<String, dynamic> data = jsonDecode(savedData);
      final driver = data['driver'];

      rideController.isRideAccepted.value = true;
      rideController.acceptedRideDriverName.value =
          (driver is Map ? driver['driverName'] : null) ?? '';
      rideController.acceptRideModel.value = AcceptRideModel.fromJson(data);

      debugPrint('✅ Ride state restored from prefs');
    } catch (e) {
      debugPrint('Restore ride state error: $e');
      // Clear corrupted data
      await PrefsHelper.setString('status', '');
      await PrefsHelper.setString('ride-accepted-data', '');
    }
  }

  Future<void> _restoreDriverRideState() async {
    final status = await PrefsHelper.getString('driver-status');
    if (status != 'ride-accepted-driver') return;

    final savedData = await PrefsHelper.getString('ride-accepted-driver-data');
    if (savedData == null || savedData.isEmpty) return;

    try {
      final Map<String, dynamic> data = jsonDecode(savedData);

      mapOPTController.acceptedRideDriverDataStatus.value = true;
      mapOPTController.acceptedRideDriverData.value =
          AcceptRideDriverModel.fromJson(data);

      debugPrint('✅ Driver ride state restored from prefs');

      // Reload the route after restoring
      await _loadAcceptedRideRoute();
    } catch (e) {
      debugPrint('Restore driver ride state error: $e');
      await PrefsHelper.setString('status', '');
      await PrefsHelper.setString('ride-accepted-driver-data', '');
    }
  }

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
        _loadRoute();
        // ✅ Save status AND full ride data
        PrefsHelper.setString('status', 'ride-accepted');
        PrefsHelper.setString(
            'ride-accepted-data', jsonEncode(data)); // save full data
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
          _loadAcceptedRideRoute();
          PrefsHelper.setString('driver-status', 'ride-accepted-driver');
          PrefsHelper.setString('ride-accepted-driver-data', jsonEncode(data));
        }
      }
    });

    SocketServices.socket?.on('get-ride-driver-location', (data){
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
          // Driver accepted — already handled by 'ride-accepted' event
          debugPrint('✅ ride-status: Ride accepted');
        } else if (rideStatus.arrivingRide == true) {
          debugPrint('🚗 ride-status: Driver arriving');
        } else if (rideStatus.ongoingRide == true) {
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
          SocketServices.socket?.off('ride-status'); // ✅ Stop listening after complete
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
          SocketServices.socket?.off('ride-status'); // ✅ Stop listening after cancel
        }
      } catch (e, stackTrace) {
        print('ride-status ERROR: $e');
        print('STACK: $stackTrace');
      }
    });

  }

  Future<void> _loadRoute() async {
    try {
      final acceptedRide = rideController.acceptRideModel.value;

      if (acceptedRide == null) return;

      final pickupCoords = acceptedRide.ride?.pickupLocation?.coordinates;
      final destCoords = acceptedRide.ride?.destinationLocation?.coordinates;
      final driverAcceptedLocationCoords =
          acceptedRide.ride?.driverAcceptedLocation?.coordinates;

      final LatLng origin = (pickupCoords != null && pickupCoords.length == 2)
          ? LatLng(pickupCoords[1], pickupCoords[0])
          : LatLng(
              googleSearchLocationController.selectedPickup.value?.lat ?? 0.0,
              googleSearchLocationController.selectedPickup.value?.lng ?? 0.0,
            );

      final LatLng dest = (destCoords != null && destCoords.length == 2)
          ? LatLng(destCoords[1], destCoords[0])
          : LatLng(
              googleSearchLocationController.selectedDrop.value?.lat ?? 0.0,
              googleSearchLocationController.selectedDrop.value?.lng ?? 0.0,
            );

      final LatLng acceptedLocation = (driverAcceptedLocationCoords != null &&
              driverAcceptedLocationCoords.length == 2)
          ? LatLng(
              driverAcceptedLocationCoords[1], driverAcceptedLocationCoords[0])
          : LatLng(
              googleSearchLocationController.selectedDrop.value?.lat ?? 0.0,
              googleSearchLocationController.selectedDrop.value?.lng ?? 0.0,
            );

      if (origin.latitude == 0.0 || dest.latitude == 0.0) {
        debugPrint('Skipping route — coords not ready');
        return;
      }

      final List<LatLng> point =
          await DirectionsService.getPolyline(acceptedLocation, origin);
      final List<LatLng> points =
          await DirectionsService.getPolyline(origin, dest);

      if (points.isEmpty) {
        Get.snackbar(
            'Error', 'Could not load route. Please check your API key.');
        return;
      }

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('Driver-Current-Location'),
            points: point,
            color: Colors.blue,
            width: 8,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            patterns: [PatternItem.dot, PatternItem.gap(12)],
          ),
          Polyline(
            polylineId: const PolylineId('Pick-Up-Location'),
            points: points,
            color: Colors.red,
            width: 6,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        };

        markers.removeWhere((m) =>
            m.markerId.value == 'current-location' ||
            m.markerId.value == 'Pick-Up-Location' ||
            m.markerId.value == 'Destination');

        markers.addAll({
          Marker(
            markerId: const MarkerId('current-location'),
            position: acceptedLocation,
            icon: customCarMarker ?? BitmapDescriptor.defaultMarker,
          ),
          Marker(
            markerId: const MarkerId('Pick-Up-Location'),
            position: origin,
            icon: BitmapDescriptor.defaultMarker,
          ),
          Marker(
            markerId: const MarkerId('Destination'),
            position: dest,
            icon: BitmapDescriptor.defaultMarker,
          ),
        });
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final bounds = _boundsFromLatLng(points);
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
      });
    } catch (e) {
      debugPrint(e.toString());
    }
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

      if (driverToPickup.isEmpty || pickupToDestination.isEmpty) return;

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
          Polyline(
            polylineId: const PolylineId('pickup_to_destination'),
            points: pickupToDestination,
            color: Colors.green,
            width: 6,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        };

        markers.removeWhere((m) =>
            m.markerId.value == 'driver_location' ||
            m.markerId.value == 'pickup_location' ||
            m.markerId.value == 'destination_location');

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
          Marker(
            markerId: const MarkerId('destination_location'),
            position: destinationLocation,
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
          result.add(Marker(
            markerId: MarkerId(driver.sId ?? UniqueKey().toString()),
            position: LatLng(coords[1], coords[0]),
            icon: customCarMarker ?? BitmapDescriptor.defaultMarker,
            onTap: () => _showDriverDialog(driver),
          ));
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
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
                trafficEnabled: true,
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
                  _loadRoute();
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                compassEnabled: true,
                circles: {
                  Circle(
                    circleId: const CircleId('currentPassenger'),
                    center: LatLng(
                      mapOPTController.currentLatitudePosition?.value ?? 0.0,
                      mapOPTController.currentLongitudePosition?.value ?? 0.0,
                    ),
                    radius: 10,
                    strokeColor: Colors.white,
                    strokeWidth: 1,
                    fillColor: const Color(0xFF006491).withOpacity(0.2),
                    consumeTapEvents: true,
                  ),
                },
              ),
            )
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
              (rideController.acceptRideModel.value?.isRideAccepted == true ||
                  PrefsHelper.getString('status') == 'ride-accepted'))
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
                      padding: const EdgeInsets.symmetric(horizontal: 25),
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
                    return GlassBackgroundMultipleChildrenWidget(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      blurOne: 20,
                      blurTwo: 20,
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                                color: const Color(0xFFB9C0C9),
                                borderRadius: BorderRadius.circular(50)),
                          ),
                        ),
                        const SizedBox(height: 50),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  (mapOPTController.rideDetailsData.value
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
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/default_image.png',
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                        '(${((mapOPTController.rideDetailsData.value?.destinationMeters ?? 0) * 0.000621371).toStringAsFixed(2)} Miles)')
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Divider(
                          height: 1,
                          color: Colors.black.withOpacity(0.2),
                        ),
                        const SizedBox(height: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                    'assets/images/direct_right.svg'),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'PICK UP',
                                        style: TextStyle(
                                          color: AppColors.labelTextColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: FontFamily.poppins,
                                        ),
                                      ),
                                      Text(
                                        mapOPTController.rideDetailsData.value
                                                ?.pickupAddress ??
                                            'Pickup location not specified',
                                        style: _textStyle(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                top: 4,
                                bottom: 4,
                              ),
                              child: Container(
                                width: 4,
                                height: 40,
                                decoration:
                                    const BoxDecoration(color: Colors.white),
                              ),
                            ),
                            Row(
                              children: [
                                SvgPicture.asset('assets/images/location.svg'),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DROP OFF',
                                        style: TextStyle(
                                          color: AppColors.labelTextColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: FontFamily.poppins,
                                        ),
                                      ),
                                      Text(
                                        mapOPTController.rideDetailsData.value
                                                ?.destinationAddress ??
                                            'Destination not specified',
                                        style: _textStyle(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Divider(
                          height: 1,
                          color: Colors.black.withOpacity(0.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Passengers Note',
                          style: TextStyle(
                            color: const Color(0xff5E5E5E).withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(mapOPTController
                                .rideDetailsData.value?.destinationAddress ??
                            ''),
                        const SizedBox(height: 18),
                        AcceptRideButton(
                          onPressed: () {
                            mapOPTController.rideAcceptRide(mapOPTController
                                .rideDetailsData.value!.rideId
                                .toString());
                          },
                        ),
                        const SizedBox(height: 80),
                      ],
                    );
                  }

                  if (mapOPTController.acceptedRideDriverData.value
                              ?.isRideAcceptedDriver ==
                          true &&
                      mapOPTController.acceptedRideDriverDataStatus.value ==
                          true) {
                    return GlassBackgroundWidget(
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 40),
                              Text(
                                '(4 min) ${((mapOPTController.acceptedRideDriverData.value?.ride?.destinationMeters ?? 0) * 0.000621371).toStringAsFixed(2)} Miles',
                                style: TextStyle(
                                  color: const Color(0xff171717),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 28),
                              Divider(
                                height: 1,
                                color: Colors.black.withOpacity(0.2),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                            mapOPTController.rideDetailsData
                                                    .value?.passengerName ??
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
                                                  '(${((mapOPTController.rideDetailsData.value?.destinationMeters ?? 0) * 0.000621371).toStringAsFixed(2)} Miles)')
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      launchUrl(Uri.parse(
                                          "tel:${mapOPTController.rideDetailsData.value?.passengerPhone}"));
                                    },
                                    child: RepaintBoundary(
                                      // ✅ isolates rendering
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.whiteColor,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          border: Border.all(
                                              color: Colors.grey.shade200),
                                        ),
                                        child: SvgPicture.asset(
                                          Assets.icons.driverCardPhone,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          CustomPrimaryButton(
                              title: 'On the way', onHandler: () {}),
                          const SizedBox(height: 50),
                          const SizedBox(height: 50),
                        ],
                      ),
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

  TextStyle _textStyle() {
    return TextStyle(
      color: AppColors.primaryHeadingTextColor,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: FontFamily.poppins,
    );
  }

  Stream<bool> _locationStatusStream() {
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      return await Geolocator.isLocationServiceEnabled();
    }).asyncMap((event) => event);
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
