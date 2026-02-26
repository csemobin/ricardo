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
  final googleSearchLocationController =
      Get.find<GoogleSearchLocationController>();
  final rideController = Get.find<RideController>();
  final mapOPTController = Get.find<MapOPTController>();

  // LatLng initialLocation = const LatLng(23.780696475817816, 90.40761484102724);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // ✅ Initialize and start - FIXED
    // _initForegroundTask();
    connectSocket();
    setCustomMarker();
    setCustomCarMarkers();
    getMyLocation();
    userController.fetchUser();
    // _loadRoute();
  }

  void addCustomMarker(LatLng position, String title) async {
    final BitmapDescriptor customIcon = await getCustomMarker();

    _markers.add(
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

  Future<void> _initForegroundTask() async {
    ForegroundLocationService.initForegroundTask();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    await _startLocationTracking();
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

  Future<void> _startLocationTracking() async {
    bool isRunning = await ForegroundLocationService.isRunningService();

    if (!isRunning) {
      // ✅ FIXED - now returns bool
      bool success = await ForegroundLocationService.startLocationTracking();

      if (success) {
        print('Location tracking started successfully');
      } else {
        print('Failed to start location tracking');
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

    LatLng myLocation = await getCurrentLocation();

    // setState(() {
    //   initialLocation = myLocation;
    // });

    print('==============================>>>>>>>> ${myLocation.longitude}');
    print('==============================>>>>>>>> ${myLocation.latitude}');

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // update when user moves 5 meters
      ),
    ).listen((Position position) {
      LatLng newLocation = LatLng(position.latitude, position.longitude);

      // setState(() {
      //   initialLocation = newLocation;
      // });

      SocketServices.socket?.emit('update-user-location', {
        "accessToken": token,
        "location": {
          "type": "Point",
          "coordinates": [newLocation.longitude, newLocation.latitude]
        }
      });

      print(
          "Live location sent: ${newLocation.latitude}, ${newLocation.longitude}");
    });

    SocketServices.socket?.on('updated-user-location-data', (data) {
      print(data);
    });
  }

  // LatLng initialLocation = const LatLng(23.780696475817816, 90.40761484102724) ;

  LatLng destination = const LatLng(23.83655877786759, 90.36862693085972);

  List<LatLng> polylineCoordinates = [];
  double currentZoom = 18.5746;
  double markerSize = 40;

  // Offline and online controller
  bool isOnline = true;

  /********** MAP Polyline Related Start  here *************/
  static const _origin = LatLng(23.7293, 90.3854);
  static const _destination = LatLng(23.7380, 90.3950);
  static const user = LatLng(23.7384, 90.3950);

  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  final Set<Marker> _singleMarkers = {};
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _loadRoute() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final points = await DirectionsService.getPolyline(_origin, _destination);

      if (points.isEmpty) {
        setState(() {
          Get.snackbar(
              'Error', 'Could not load route. Please check your API key.');
        });
        return;
      }

      setState(() {
        // _polylines = {
        //   Polyline(
        //     polylineId: const PolylineId('route'),
        //     points: points,
        //     color: Colors.red,
        //     width: 6,
        //     startCap: Cap.roundCap,
        //     endCap: Cap.roundCap,
        //     // patterns: [
        //     //   PatternItem.dot,
        //     //   PatternItem.gap(10),
        //     // ],
        //   ),
        // };

        _polylines = {
          // ✅ Your existing main route (solid line on road) - no change
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: Colors.red,
            width: 6,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),

          // ✅ NEW: Dotted line from person (marker) → to route start point
          Polyline(
            polylineId: const PolylineId('walking_connector'),
            points: [
              _origin, // person's position (house/off-road)
              points.first, // where the road route actually begins
            ],
            color: Colors.red,
            width: 4,
            patterns: [
              PatternItem.dot,
              PatternItem.gap(12),
            ],
          ),
        };
        _markers = {
          Marker(
            markerId: const MarkerId('origin'),
            position: _origin,
            // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            icon: customMarker ?? BitmapDescriptor.defaultMarker,
            infoWindow: const InfoWindow(title: 'Origin'),
          ),
          Marker(
            markerId: const MarkerId('destination'),
            position: _destination,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            // infoWindow: const InfoWindow(title: 'Destination'),
            onTap: () {
              // DriverModal.show(context); // ← call bottom sheet on tap
            },
          ),
          // Marker(
          //   markerId: const MarkerId('user'),
          //   position: user,
          //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          //   infoWindow: const InfoWindow(title: 'User'),
          // ),
        };
        _isLoading = false;
      });

      final bounds = _boundsFromLatLng(points);
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading route: $e';
        _isLoading = false;
      });
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

  /********** MAP Polyline Related work are here *************/

  late String userId = '';

  void _getUserId() async {
    userId = await PrefsHelper.getString(AppConstants.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Obx(
            () => GoogleMap(
              // onCameraMove: (CameraPosition position) {
              //   LatLng center = position.target;
              //   print("Map center: ${center.latitude}, ${center.longitude}");
              // },
              // onCameraMove: (CameraPosition position) {
              //   currentZoom = position.zoom;
              //
              //   double newSize = (currentZoom * 3).clamp(20, 100);
              //   if ((newSize - markerSize).abs() > 2) {
              //     markerSize = newSize;
              //     setCustomMarker();
              //   }
              // },
              mapType: MapType.normal,
              // zoomGesturesEnabled: true,
              // zoomControlsEnabled: true,
              //initialCameraPosition: _mapCtrl.kGooglePlex,

              initialCameraPosition: CameraPosition(
                target: LatLng(mapOPTController.currentLatitudePosition!.value,
                    mapOPTController.currentLongitudePosition!.value),
                zoom: currentZoom,
              ),
              markers: _buildMarkers(),
              // polylines: _polylines,
              // markers: mapOPTController.isFirstStep == false
              //     ? _singleMarkers
              //     : _markers,
              // myLocationButtonEnabled: true,
              // myLocationEnabled: true,
              // onMapCreated: (controller) {
              //   _mapController = controller;
              //   // _loadRoute();
              // },
              // markers: {
              //   Marker(
              //       markerId: const MarkerId('marker'),
              //       position: initialLocation,
              //       draggable: true,
              //       icon: customMarker ?? BitmapDescriptor.defaultMarker,
              //       onDragEnd: (updateLanLng) {
              //         setState(() {
              //           initialLocation = updateLanLng;
              //         });
              //       },
              //       anchor: Offset(0.5, 0.5)),
              //   Marker(
              //     markerId: const MarkerId('destination'),
              //     position: destination,
              //     draggable: true,
              //     onDragEnd: (updatedLatLng) {
              //       setState(() {
              //         destination = updatedLatLng;
              //       });
              //     },
              //   )
              // },
              circles: {
                Circle(
                  circleId: CircleId('currentPassenger'),
                  center: LatLng(
                      mapOPTController.currentLatitudePosition!.value,
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
          ),

          /* Single Bottom Modal Sheet [ Fixed ]  */
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
            ),*/
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

          /*Custom Header are here [Fixed] */
          // CustomHeader(mapOPTController: mapOPTController),

          // Custom Header - Only shows when conditions are true
          Obx(() {
            if (rideController.viewInMap.value &&
                rideController.viewInMapReturn.value == false) {
              return CustomHeader(mapOPTController: mapOPTController);
            }
            return MapCustomHeaderBack(
              rideController: rideController,
            );
          }),

          // 3. ✅ DraggableScrollableSheet DIRECTLY in Stack, NOT inside Column
          // rideController.isSwippedButtonShow.value == true

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
          }),*/

          // Bottom Sheet Related work are here
          // BottomSheetScreen(),

          // if(rideController.isSwippedButtonShow.value == true)
          SafeArea(
            child: Obx(() {
              final role = userController.userModel.value?.userProfile?.role;
              return Column(
                // crossAxisAlignment: CrossAxisAlignment.end,
                // mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // SizedBox(
                  //   height: 10,
                  // ),

                  /* Driver Toggle Switch [ Fixed ] */
                  if (role == 'driver') AnimatedToggleSwitch(),

                  // // SizedBox(
                  // //   height: 30,
                  // // ),
                  // NoInternetMessageMap(),
                  //
                  // // Swiped Button are here
                  Spacer(),

                  /* Passenger Swipped Button [ Fixed ] */
                  // Passenger Swipped Button - Only shows when ALL conditions are false
                  Obx(() {
                    if (role == 'passenger' &&
                        googleSearchLocationController.isModalOn.value ==
                            false &&
                        rideController.isSwippedButtonShow.value == false &&
                        rideController.viewInMap.value == true) {
                      return _buildSwippedButton();
                    }
                    return SizedBox.shrink();
                  }),

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
                  */

                  // showRideTrackingSheet(context, status),
                  SizedBox(
                    height: 100.h,
                  ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 25),
                  //   child: ClipRRect(
                  //     borderRadius: BorderRadius.circular(12.r),
                  //     child: BackdropFilter(
                  //       filter: ui.ImageFilter.blur(
                  //         sigmaX: 4,
                  //         sigmaY: 4,
                  //       ),
                  //       child: Container(
                  //         width: double.infinity,
                  //         padding: EdgeInsets.all(20.r),
                  //         decoration: BoxDecoration(
                  //           color: AppColors.whiteColor.withOpacity(0.3),
                  //           borderRadius: BorderRadius.circular(12.r),
                  //           border: Border.all(
                  //             color: AppColors.whiteColor,
                  //           ),
                  //           boxShadow: [
                  //             BoxShadow(
                  //               color: Colors.black.withOpacity(0.1),
                  //               offset: Offset(0, -4),
                  //               blurRadius: 4,
                  //               spreadRadius: 0,
                  //             ),
                  //           ],
                  //         ),
                  //         child: _buildPassengerRequestCard(),
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // Padding(
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: 25.w,
                  //   ),
                  //   child: _bgGlassDesign(_buildPassengerRequestCard()),
                  // ),
                  // SizedBox(
                  //   height: 25.h,
                  // ),

                  /* ElevatedButton(
                  onPressed: () => showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        child: GlassBackgroundWidget(child: Text('Maruf')),
                      );
                    },
                  ),
                  child: Text('Show Modal'),
                ),*/

                  // AnimatedToggleSwitch(
                  //   value: isOnline,
                  //   onChanged: (newValue) {
                  //     // When toggle is clicked, show dialog first
                  //     showDialog(
                  //       barrierDismissible: true,
                  //       context: context,
                  //       builder: (context) {
                  //         return Dialog(
                  //           backgroundColor: Colors.transparent,
                  //           child: GlassBackgroundWidget(
                  //             child: Column(
                  //               mainAxisSize: MainAxisSize.min,
                  //               children: [
                  //                 Text(
                  //                   newValue
                  //                       ? 'Are you sure you want to go Online?'
                  //                       : 'Are you sure you want to go Offline?',
                  //                   style: TextStyle(fontSize: 16.sp),
                  //                   textAlign: TextAlign.center,
                  //                 ),
                  //                 SizedBox(height: 20.h),
                  //                 Row(
                  //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //                   children: [
                  //                     TextButton(
                  //                       onPressed: () {
                  //                         Navigator.pop(context);
                  //                         // Don't change status, keep old value
                  //                       },
                  //                       child: Text('No'),
                  //                     ),
                  //                     ElevatedButton(
                  //                       onPressed: () {
                  //                         setState(() {
                  //                           isOnline = newValue; // Change status
                  //                         });
                  //                         Navigator.pop(context);
                  //                       },
                  //                       child: Text('Yes'),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         );
                  //       },
                  //     );
                  //   },
                  // ),
                  // GlassBackgroundWidget(
                  //   child: Text('Maruf'),
                  // ),
                  // AcceptRideButton(onPressed: (){
                  //   print('yessss');
                  // })
                ],
              );
            }),
          ),

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
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.all(12),
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

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};

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
              onTap: () => showDialog(
                context: context,
                // backgroundColor: Colors.transparent,
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
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                                'assets/images/driver.png');
                                          },
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 50,
                                        child: Image.asset(
                                          'assets/images/driver.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${driver.name}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.star,
                                              color: Colors.amber, size: 16),
                                          SizedBox(width: 4),
                                          Text(
                                              '${driver.rating} (${driver.totalRatings})'),
                                          SizedBox(width: 8),
                                          Text('|'),
                                          SizedBox(width: 8),
                                          Text('${driver.trips} Trips'),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.phone,
                                              color: Colors.green, size: 16),
                                          SizedBox(width: 4),
                                          Text('${driver.phone}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.phone, color: Colors.white),
                                ),
                              ],
                            ),

                            const Divider(height: 24),

                            // ───── Car Info ─────
                            const Align(
                              alignment: Alignment.center,
                              child: Text('Car info.',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${driver.vehicle?.carName}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                          '${driver.vehicle?.numberOfSeat} Seat'),
                                      SizedBox(height: 4),
                                      Text('${driver.vehicle?.carPlateNumber}'),
                                      SizedBox(height: 4),
                                      Text(
                                        '1 km away from you.',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    // Assets.images.favoriteRidesBookCar.path,
                                    '${ApiUrls.imageBaseUrl}${driver.vehicle?.carImage?.filename}',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ───── Request Ride Button ─────
                            // SizedBox(
                            //   width: 160,
                            //   child: ElevatedButton(
                            //     onPressed: () => RequestRideHandler(cnt: rideController, cardDetails: driver),
                            //     style: ElevatedButton.styleFrom(
                            //       backgroundColor: Colors.green,
                            //       // padding:
                            //       //     const EdgeInsets.symmetric(vertical: 14),
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(12),
                            //       ),
                            //     ),
                            //     child: const Text(
                            //       'Request Ride',
                            //       style: TextStyle(
                            //         fontSize: 16,
                            //         color: Colors.white,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            RequestRideHandler(cnt: rideController, cardDetails: driver),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return markers;
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
