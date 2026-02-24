import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ricardo/app/helpers/prefs_helper.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/app/utils/app_constants.dart';
import 'package:ricardo/feature/controllers/custom_bottom_nav_bar_controller.dart';
import 'package:ricardo/feature/controllers/home/google_search_location_controller.dart';
import 'package:ricardo/feature/controllers/home/map/map_opt_controller.dart';
import 'package:ricardo/feature/controllers/home/map/ride_controller.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/feature/view/home/map/RideRequestBottomSheet.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/api_urls.dart';
import 'package:ricardo/services/direction_services.dart';
import 'package:ricardo/services/foreground_location_service.dart';
import 'package:ricardo/services/get_fcm_tocken.dart';
import 'package:ricardo/services/location_permission_service.dart';
import 'package:ricardo/services/socket_services.dart';
import 'package:ricardo/widgets/animated_toggle_switch.dart';
import 'package:ricardo/widgets/driver_bottom_sheet.dart';
import 'package:ricardo/widgets/location_permission_dialog.dart';
import 'package:slide_to_act/slide_to_act.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // ✅ Initialize and start - FIXED
    // _initForegroundTask();
    connectSocket();
    setCustomMarker();
    getMyLocation();
    userController.fetchUser();
    // _loadRoute();
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
          initialLocation = LatLng(lat, lng);
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
      "assets/images/car_marker.png",
    );
    setState(() {});
  }

// Method 2: More precise control using asset() with custom bytes
//   Future<void> setCustomMarkerAdvanced() async {
//     final ByteData data = await rootBundle.load("assets/images/car_marker.png");
//     final ui.Codec codec = await ui.instantiateImageCodec(
//       data.buffer.asUint8List(),
//       targetWidth: 50, // Specify exact width
//       targetHeight: 50, // Specify exact height
//     );
//     final ui.FrameInfo frameInfo = await codec.getNextFrame();
//     final ByteData? byteData = await frameInfo.image.toByteData(
//       format: ui.ImageByteFormat.png,
//     );
//     final Uint8List resizedImageData = byteData!.buffer.asUint8List();
//
//     customMarker = BitmapDescriptor.fromBytes(resizedImageData);
//     setState(() {});
//   }

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

    setState(() {
      initialLocation = myLocation;
    });

    print('==============================>>>>>>>> ${myLocation.longitude}');
    print('==============================>>>>>>>> ${myLocation.latitude}');

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // update when user moves 5 meters
      ),
    ).listen((Position position) {
      LatLng newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        initialLocation = newLocation;
      });

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
  LatLng initialLocation = const LatLng(23.780696475817816, 90.40761484102724);

  LatLng destination = const LatLng(23.83655877786759, 90.36862693085972);

  List<LatLng> polylineCoordinates = [];
  double currentZoom = 16.4746;
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

  final Set<Marker> _singleMarkers = {
    // Marker(
    //   markerId: MarkerId('current_marker'),
    //    icon: BitmapDescriptor.fromAssetImage( , '')
    //    // icon:  BitmapDescriptor.asset(configuration, assetName)
    // )
  };
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
              DriverBottomSheet.show(context); // ← call bottom sheet on tap
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

late String userId ='';
  void  _getUserId() async{
    userId = await PrefsHelper.getString(AppConstants.userId);
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: Obx(() {
          final userController = Get.find<UserController>();

          final user = userController.userModel.value?.userProfile;
          final profileImage =
              user?.image?.filename ?? Assets.images.profileImage.path;
          final userName = user?.name ?? 'User';
          // ✅ In your initState or wherever you load user data

          return ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0x80FFFFFF),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: SafeArea(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: GestureDetector(
                                  onTap: () {
                                    final cnt = Get.find<
                                        CustomBottomNavBarController>();
                                    cnt.selectedIndex.value = 3;
                                    Get.toNamed(AppRoutes.customBottomNavBar);
                                  },
                                  child: Image.network(
                                    '${ApiUrls.imageBaseUrl}$profileImage',
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        Assets.images.profileImage.path,
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Image.asset(
                              Assets.images.bell.path,
                              width: 24,
                              height: 24,
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Image.asset(
                              Assets.images.greenPin.path,
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                mapOPTController.currentLocation.value,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Image.asset(Assets.images.rightArrow.path),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          GoogleMap(
            onCameraMove: (CameraPosition position) {
              LatLng center = position.target;
              print("Map center: ${center.latitude}, ${center.longitude}");
            },
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
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            //initialCameraPosition: _mapCtrl.kGooglePlex,

            initialCameraPosition: CameraPosition(
              target: initialLocation,
              zoom: currentZoom,
            ),
            polylines: _polylines,
            markers: mapOPTController.isFirstStep == false ? _singleMarkers : _markers,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
              _loadRoute();
            },
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
            circles:  {
              Circle(
                  circleId: CircleId('marker'),
                  center: initialLocation,
                  radius: 10,
                  strokeColor: Colors.white,
                  strokeWidth: 1,
                  fillColor: Color(0xFF006491).withOpacity(0.2),
                  consumeTapEvents: true),
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

          // Bottom Sheet related work are here
          if (googleSearchLocationController.isModalOn.value)
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
            ),
          // 3. ✅ DraggableScrollableSheet DIRECTLY in Stack, NOT inside Column
          // rideController.isSwippedButtonShow.value == true

          /* Obx(() {
            if (rideController.isSwippedButtonShow.value == false) {
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

                  if (role == 'driver') AnimatedToggleSwitch(),

                  // // SizedBox(
                  // //   height: 30,
                  // // ),
                  // NoInternetMessageMap(),
                  //
                  // // Swiped Button are here
                  Spacer(),

                  if ((role == 'passenger' &&
                          googleSearchLocationController.isModalOn.value ==
                              false) &&
                      rideController.isSwippedButtonShow.value == false)
                    _buildSwippedButton(),

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
        onSubmit: () => Get.toNamed(AppRoutes.searchLocationScreen, arguments: {'back_disable': true}),
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
