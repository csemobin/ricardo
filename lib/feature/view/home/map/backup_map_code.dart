/*
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:ricardo/feature/view/home/map/custom_header.dart';
import 'package:ricardo/widgets/map_custom_header_back.dart';
import 'package:ricardo/widgets/request_ride_handler.dart';
import 'link_export_file.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  final userController = Get.find<UserController>();
  final GoogleSearchLocationController googleSearchLocationController =
  Get.find<GoogleSearchLocationController>();
  final rideController = Get.find<RideController>();
  final mapOPTController = Get.find<MapOPTController>();
  GoogleMapController? _mapController;

  // LatLng initialLocation = const LatLng(23.780696475817816, 90.40761484102724);
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    connectSocket();

    // ✅ FIX: Initialize custom markers
    setCustomMarker();
    setCustomCarMarkers();

    getMyLocation();
    userController.fetchUser();

    _loadRoute(); // ← ADD THIS

    ever(rideController.isRideAccepted, (bool accepted) {
      if (accepted == true) {
        _loadRoute();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRoute());
  }

  void addCustomMarker(LatLng position, String title) async {
    final BitmapDescriptor customIcon = await getCustomMarker();
    markers.add(
      Marker(
        markerId: MarkerId('custom_${position.latitude}_${position.longitude}'),
        position: position,
        infoWindow: InfoWindow(title: title),
        icon: customIcon,
      ),
    );
  }

  Future<BitmapDescriptor> getCustomMarker() async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)), // marker size
      mapOPTController.userController.userModel.value?.userProfile?.image
          ?.filename?.isNotEmpty ==
          true
          ? 'assets/images/marker.png'
          : '',
    );
  }

  void _onReceiveTaskData(Object data) {
    if (data is Map) {
      final lat = data['latitude'] as double?;
      final lng = data['longitude'] as double?;

      if (lat != null && lng != null) {
        setState(() {
          // initialLocation = LatLng(lat, lng);
        });
      }
    }
  }

  // ✅ Monitor app lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to foreground, check location again
      _checkLocationPermission();
    }
  }

  // ✅ Check location permission
  Future<void> _checkLocationPermission() async {
    final status = await LocationPermissionService.checkAndRequestLocation();

    if (status != LocationStatus.granted) {
      _showLocationDialog(status);
    }
  }

  // ✅ Show dialog
  void _showLocationDialog(LocationStatus status) {
    showDialog(
      context: context,
      barrierDismissible: false, // Can't dismiss by tapping outside
      builder: (context) => LocationPermissionDialog(status: status),
    );
  }

  StreamSubscription<Position>? positionStream;

  BitmapDescriptor? customMarker;

  Future<void> setCustomMarker() async {
    // Method 1: Using ImageConfiguration to control size
    customMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(
        devicePixelRatio: 1.0, // Lower = smaller image
        size: Size(50, 50), // Target size in logical pixels
      ),
      "assets/images/location_black_marker.png",
    );
    setState(() {});
  }

  BitmapDescriptor? customCarMarker;

  Future<void> setCustomCarMarkers() async {
    // Method 1: Using ImageConfiguration to control size
    customCarMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(
        devicePixelRatio: 1.0, // Lower = smaller image
        size: Size(50, 50), // Target size in logical pixels
      ),
      "assets/images/car_marker.png",
    );
    setState(() {});
  }

  Future<LatLng> getCurrentLocation() async {
    bool serviceEnable;
    LocationPermission permission;

    //Check if location service is enabled
    serviceEnable = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnable) {
      return Future.error('Location Services are disable');
    }
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location Permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location Permission Permanently denied.Enable from settings");
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return LatLng(position.latitude, position.longitude);
  }

  void connectSocket() async {
    String? getAccessToken = await PrefsHelper.getString('accessToken');
    String? fcmToken = await FirebaseNotificationService.getFCMToken();
    await PrefsHelper.setString(AppConstants.fcmToken, fcmToken);
    await SocketServices.init();
    SocketServices.socket?.emit('user-connected', {
      "accessToken": getAccessToken,
      "fcmToken": fcmToken,
    });
  }

  Future<void> getMyLocation() async {
    var token = await PrefsHelper.getString(AppConstants.bearerToken);

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
          "coordinates": [newLocation.longitude, newLocation.latitude]
        }
      });
    });

    SocketServices.socket?.on('updated-user-location-data', (data) {
      print(data);
    });
  }

  LatLng destination = const LatLng(23.83655877786759, 90.36862693085972);
  List<LatLng> polylineCoordinates = [];
  double currentZoom = 18.5746;
  double markerSize = 40;

  // Offline and online controller
  bool isOnline = true;

  Set<Polyline> _polylines = {};
  Set<Marker> _mapMarkers = {};

  */
/*Future<void> _loadRoute() async {
    try {
      final acceptedRide = rideController.acceptRideModel.value;

      final LatLng origin;
      final LatLng dest;

      if (rideController.isRideAccepted.value && acceptedRide != null) {

        print('============================ _mapMarkers');
        print('+++++++++++++++++++++++++++++++++++++++++');
        print('============================ _mapMarkers');

        _mapMarkers.clear();
        _polylines.clear();
        setState(() {});

        final pickupCoords = acceptedRide.ride?.pickupLocation?.coordinates;
        final destCoords = acceptedRide.ride?.destinationLocation?.coordinates;

        origin = (pickupCoords != null && pickupCoords.length == 2)
            ? LatLng(pickupCoords[1], pickupCoords[0])
            : LatLng(
          googleSearchLocationController.selectedPickup.value?.lat ?? 0.0,
          googleSearchLocationController.selectedPickup.value?.lng ?? 0.0,
        );

        dest = (destCoords != null && destCoords.length == 2)
            ? LatLng(destCoords[1], destCoords[0])
            : LatLng(
          googleSearchLocationController.selectedDrop.value?.lat ?? 0.0,
          googleSearchLocationController.selectedDrop.value?.lng ?? 0.0,
        );
      } else {
        origin = LatLng(
          googleSearchLocationController.selectedPickup.value?.lat ?? 0.0,
          googleSearchLocationController.selectedPickup.value?.lng ?? 0.0,
        );
        dest = LatLng(
          googleSearchLocationController.selectedDrop.value?.lat ?? 0.0,
          googleSearchLocationController.selectedDrop.value?.lng ?? 0.0,
        );
      }

      // Guard: don't draw if coords are 0,0
      if (origin.latitude == 0.0 || dest.latitude == 0.0) {
        debugPrint('Skipping route — coords not ready');
        return;
      }

      final points = await DirectionsService.getPolyline(origin, dest);

      if (points.isEmpty) {
        Get.snackbar('Error', 'Could not load route. Please check your API key.');
        return;
      }

      setState(() {
        // ✅ Polylines
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: Colors.red,
            width: 6,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
          Polyline(
            polylineId: const PolylineId('walking_connector'),
            points: [origin, points.first],
            color: Colors.red,
            width: 4,
            patterns: [PatternItem.dot, PatternItem.gap(12)],
          ),
        };

        // ✅ Always keep current passenger marker
        _mapMarkers = {
          Marker(
            markerId: const MarkerId('currentPassenger'),
            position: LatLng(
              mapOPTController.currentLatitudePosition!.value,
              mapOPTController.currentLongitudePosition!.value,
            ),
            icon: customMarker ?? BitmapDescriptor.defaultMarker,
          ),
        };

        if (rideController.isRideAccepted.value) {
          // ✅ Ride accepted: show pickup (car icon) + destination marker only
          _mapMarkers.add(
            Marker(
              markerId: const MarkerId('pickup_point'),
              position: origin,
              icon: customCarMarker ?? BitmapDescriptor.defaultMarker, // car icon at pickup
            ),
          );
          _mapMarkers.add(
            Marker(
              markerId: const MarkerId('destination_point'),
              position: dest,
              icon: BitmapDescriptor.defaultMarker, // pin at destination
            ),
          );
        } else {
          // ✅ Not accepted: show all nearby driver markers
          for (var driver in rideController.drivers) {
            final coords = driver.location?.coordinates;
            if (coords != null && coords.length == 2) {
              _mapMarkers.add(
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
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final bounds = _boundsFromLatLng(points);
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
      });

    } catch (e) {
      debugPrint(e.toString());
    }
  }*//*

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

  */
/********** MAP Polyline Related work are here *************//*

  // Remove _mapMarkers entirely and just use markers

  Future<void> _loadRoute() async {
    try {
      final acceptedRide = rideController.acceptRideModel.value;

      final LatLng origin;
      final LatLng dest;

      if (rideController.isRideAccepted.value && acceptedRide != null) {
        // Clear existing markers
        markers.clear();
        _polylines.clear();

        // Don't call setState here yet - we'll do it at the end

        final pickupCoords = acceptedRide.ride?.pickupLocation?.coordinates;
        final destCoords = acceptedRide.ride?.destinationLocation?.coordinates;

        origin = (pickupCoords != null && pickupCoords.length == 2)
            ? LatLng(pickupCoords[1], pickupCoords[0])
            : LatLng(
          googleSearchLocationController.selectedPickup.value?.lat ?? 0.0,
          googleSearchLocationController.selectedPickup.value?.lng ?? 0.0,
        );

        dest = (destCoords != null && destCoords.length == 2)
            ? LatLng(destCoords[1], destCoords[0])
            : LatLng(
          googleSearchLocationController.selectedDrop.value?.lat ?? 0.0,
          googleSearchLocationController.selectedDrop.value?.lng ?? 0.0,
        );
      } else {
        origin = LatLng(
          googleSearchLocationController.selectedPickup.value?.lat ?? 0.0,
          googleSearchLocationController.selectedPickup.value?.lng ?? 0.0,
        );
        dest = LatLng(
          googleSearchLocationController.selectedDrop.value?.lat ?? 0.0,
          googleSearchLocationController.selectedDrop.value?.lng ?? 0.0,
        );
      }

      // Guard: don't draw if coords are 0,0
      if (origin.latitude == 0.0 || dest.latitude == 0.0) {
        debugPrint('Skipping route — coords not ready');
        return;
      }

      final points = await DirectionsService.getPolyline(origin, dest);

      if (points.isEmpty) {
        Get.snackbar('Error', 'Could not load route. Please check your API key.');
        return;
      }

      setState(() {
        // ✅ Polylines
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: Colors.red,
            width: 6,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
          Polyline(
            polylineId: const PolylineId('walking_connector'),
            points: [origin, points.first],
            color: Colors.red,
            width: 4,
            patterns: [PatternItem.dot, PatternItem.gap(12)],
          ),
        };

        // ✅ Clear and rebuild markers
        markers.clear();

        // ✅ Always keep current passenger marker
        markers.add(
          Marker(
            markerId: const MarkerId('currentPassenger'),
            position: LatLng(
              mapOPTController.currentLatitudePosition!.value,
              mapOPTController.currentLongitudePosition!.value,
            ),
            icon: customMarker ?? BitmapDescriptor.defaultMarker,
          ),
        );

        if (rideController.isRideAccepted.value) {
          // ✅ Ride accepted: show pickup (car icon) + destination marker only
          markers.add(
            Marker(
              markerId: const MarkerId('pickup_point'),
              position: origin,
              icon: customCarMarker ?? BitmapDescriptor.defaultMarker,
            ),
          );
          markers.add(
            Marker(
              markerId: const MarkerId('destination_point'),
              position: dest,
              icon: BitmapDescriptor.defaultMarker,
            ),
          );
        } else {
          // ✅ Not accepted: show all nearby driver markers
          for (var driver in rideController.drivers) {
            final coords = driver.location?.coordinates;
            if (coords != null && coords.length == 2) {
              markers.add(
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
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final bounds = _boundsFromLatLng(points);
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
      });

    } catch (e) {
      debugPrint(e.toString());
    }
  }

// Simplify _buildMarkers() to just return the markers
  Set<Marker> _buildMarkers() {
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(mapOPTController.currentLatitudePosition!.value,
                  mapOPTController.currentLongitudePosition!.value),
              zoom: currentZoom,
            ),
            markers: rideController.isRideAccepted.value
                ? _mapMarkers  // Use _mapMarkers when ride is accepted
                : _buildMarkers(),
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
              _loadRoute(); // ← also call here so map is ready
            },
            circles: {
              Circle(
                circleId: CircleId('currentPassenger'),
                center: LatLng(mapOPTController.currentLatitudePosition!.value,
                    mapOPTController.currentLongitudePosition!.value),
                radius: 10,
                strokeColor: Colors.white,
                strokeWidth: 1,
                fillColor: Color(0xFF006491).withOpacity(0.2),
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
            },
          ),

          */
/* Single Bottom Modal Sheet [ Fixed ]  *//*

          */
/*if ( googleSearchLocationController.isModalOn.value )
            Positioned(
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
                    distance: googleSearchLocationController.distance.value,
                    rideFare:
                        googleSearchLocationController.fare.value.toString(),
                  );
                },
              ),
            ),*//*


          // Bottom Sheet - Only shows when ALL conditions are true
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
            return SizedBox.shrink();
          }),

          */
/*Custom Header are here [Fixed] *//*

          // CustomHeader(mapOPTController: mapOPTController),

          // Custom Header - Only shows when conditions are true
          Obx(() {
            if (userController.userModel.value?.userProfile?.role ==
                'passenger' &&
                rideController.viewInMap.value &&
                rideController.viewInMapReturn.value == false) {
              return CustomHeader(mapOPTController: mapOPTController);
            } else if (userController.userModel.value?.userProfile?.role ==
                'passenger') {
              return MapCustomHeaderBack(
                rideController: rideController,
              );
            }
            return SizedBox.shrink();
          }),

          */
/*Obx(() {
            if (rideController.isSwippedButtonShow.value == true) {
              return DraggableScrollableSheet(
                initialChildSize: 0.2,
                minChildSize: 0.15,
                maxChildSize: 0.85,
                snap: true,
                snapSizes: [0.15, 0.4, 0.85],
                expand: true,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24.r)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      children: [
                        Text('maruf'),
                        Text('maruf'),

                      ],
                    ),
                  );
                },
              );
            }
            return SizedBox.shrink();
          }),*//*


          SafeArea(
              child: Column(
                children: [
                  */
/* Driver Toggle Switch [ Fixed ] *//*

                  Obx(() {
                    final role = userController.userModel.value?.userProfile?.role;
                    if (role == 'driver') {
                      return Padding(
                        padding: EdgeInsets.only(
                          top: 30.h,
                        ),
                        child: AnimatedToggleSwitch(),
                      );
                    }
                    return SizedBox.shrink();
                  }),

                  // NoInternetMessageMap(),

                  Spacer(),

                  Obx(() {
                    final role = userController.userModel.value?.userProfile?.role;
                    if (role == 'passenger' &&
                        googleSearchLocationController.isModalOn.value == false &&
                        rideController.isSwippedButtonShow.value == false &&
                        rideController.viewInMap.value == true) {
                      return _buildSwippedButton();
                    }
                    return SizedBox.shrink();
                  }),

                  */
/*if (rideController.isSwippedButtonShow.value == true)
                    RideTrackingBottomSheet(
                      status: RideStatus.driverOnWay,
                      driverName: 'Maruf',
                      driverRating: '3.3',
                      driverTrips: '2.0',
                      driverPhone: '01936696236',
                      carName: 'BMW',
                      carSeats: '4',
                      distanceAway: '10',
                      eta: '10',
                      driverImage:
                          'https://t4.ftcdn.net/jpg/03/17/25/45/360_F_317254576_lKDALRrvGoBr7gQSa1k4kJBx7O2D15dc.jpg',
                      carImage:
                          'https://t4.ftcdn.net/jpg/03/17/25/45/360_F_317254576_lKDALRrvGoBr7gQSa1k4kJBx7O2D15dc.jpg',
                      carPlate:
                          'https://t4.ftcdn.net/jpg/03/17/25/45/360_F_317254576_lKDALRrvGoBr7gQSa1k4kJBx7O2D15dc.jpg',
                    ),
                  *//*


                  // showRideTrackingSheet(context, status),

                  SizedBox(
                    height: 100.h,
                  ),

                  // Padding(
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: 25.w,
                  //   ),
                  //   child: _bgGlassDesign(_buildPassengerRequestCard()),
                  // ),
                  //

                  SizedBox(
                    height: 14.h,
                  ),

                  // AcceptRideButton(onPressed: (){
                  //   print('yessss');
                  // })
                ],
              )),

          // ✅ Location disabled banner
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
                                LocationPermissionService
                                    .openLocationSettings();
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
  */
/*Set<Marker> _buildMarkers() {
    // ✅ Clear existing markers first
    markers.clear();

    // ✅ Current passenger marker
    markers.add(
      Marker(
        markerId: const MarkerId('currentPassenger'),
        position: LatLng(
          mapOPTController.currentLatitudePosition!.value,
          mapOPTController.currentLongitudePosition!.value,
        ),
        icon: customMarker ?? BitmapDescriptor.defaultMarker,
      ),
    );

    // ✅ Get drivers safely
    final drivers = rideController.drivers;
    if (drivers != null) {
      for (var driver in drivers) {
        final coords = driver.location?.coordinates;
        if (coords != null && coords.length == 2) {
          final double longitude = coords[0];
          final double latitude = coords[1];

          markers.add(
              Marker(
                markerId: MarkerId(driver.sId ?? UniqueKey().toString()),
                position: LatLng(latitude, longitude),
                icon: customCarMarker ?? BitmapDescriptor.defaultMarker,
                onTap: () => _showDriverDialog(driver),
              )
          );
        }
      }
    }

    return markers;
  }*//*


  */
/*Set<Marker> _buildMarkers() {
    // ✅ Current passenger marker
    markers.add(
      Marker(
        markerId: const MarkerId('currentPassenger'),
        position: LatLng(
          mapOPTController.currentLatitudePosition!.value,
          mapOPTController.currentLongitudePosition!.value,
        ),
        icon: customMarker ?? BitmapDescriptor.defaultMarker,
      ),
    );

    // ✅ Get drivers safely
    final drivers = rideController.drivers;
    if (drivers != null) {
      for (var driver in drivers) {
        final coords = driver.location?.coordinates;
        if (coords != null && coords.length == 2) {
          final double longitude = coords[0];
          final double latitude = coords[1];

          markers.add(
              Marker(
                markerId: MarkerId( driver.sId ?? UniqueKey().toString()),
                position: LatLng(latitude, longitude),
                icon: customCarMarker ?? BitmapDescriptor.defaultMarker,
                onTap: () => _showDriverDialog(driver),
              )
          );
        }
      }
    }

    return markers;
  }*//*


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
                  // ───── Driver Info Row ─────
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
                            // add call logic here if needed
                          },
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // ───── Car Info Label ─────
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

                  // ───── Car Info Row ─────
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

                  // ───── Request Ride Button ─────
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
        filter: ui.ImageFilter.blur(
          sigmaX: 4,
          sigmaY: 4,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.whiteColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.whiteColor,
            ),
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
        Image.asset(
          Assets.images.waiting.path,
          fit: BoxFit.cover,
        ),
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
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: SlideAction(
        sliderButtonYOffset: 0,
        // onSubmit: () => Get.toNamed(AppRoutes.setHomeLocation),
        onSubmit: () => Get.toNamed(AppRoutes.searchLocationScreen,
            arguments: {'back_disable': true}),
        // onSubmit: () => Get.toNamed(AppRoutes.rateReviewDriver),
        // onSubmit: () => Get.toNamed(AppRoutes.reportScreen),
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

  // ✅ Stream to monitor location status
  Stream<bool> _locationStatusStream() {
    return Stream.periodic(Duration(seconds: 5), (_) async {
      return await LocationPermissionService.isLocationEnabled();
    }).asyncMap((event) => event);
  }

  @override
  void dispose() {
    // ✅ Stop service and remove listener - FIXED
    ForegroundLocationService.stopLocationTracking();
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    WidgetsBinding.instance.removeObserver(this);
    positionStream?.cancel();

    WidgetsBinding.instance.removeObserver(this);
    positionStream?.cancel();
    super.dispose();
  }
}
*/
