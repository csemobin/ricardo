import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ricardo/app/helpers/prefs_helper.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/app/utils/app_constants.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/api_urls.dart';
import 'package:ricardo/services/foreground_location_service.dart';
import 'package:ricardo/services/get_fcm_tocken.dart';
import 'package:ricardo/services/location_permission_service.dart';
import 'package:ricardo/services/socket_services.dart';
import 'package:ricardo/widgets/accepted_ride_button.dart';
import 'package:ricardo/widgets/animated_toggle_switch.dart';
import 'package:ricardo/widgets/glass_background_widget.dart';
import 'package:ricardo/widgets/location_permission_dialog.dart';
import 'package:ricardo/widgets/no_internet_message_map.dart';
import 'package:slide_to_act/slide_to_act.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ Initialize and start - FIXED
    _initForegroundTask();
    connectSocket();
    setCustomMarker();
    getMyLocation();
    userController.fetchUser();
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
  Future<void> setCustomMarkerAdvanced() async {
    final ByteData data = await rootBundle.load("assets/images/car_marker.png");
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 50, // Specify exact width
      targetHeight: 50, // Specify exact height
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? byteData = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List resizedImageData = byteData!.buffer.asUint8List();

    customMarker = BitmapDescriptor.fromBytes(resizedImageData);
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
    SocketServices.socket?.emit('user-connected',
        {"accessToken": getAccessToken, "fcmToken": fcmToken});
  }

  Future<void> getMyLocation() async {
    var token = await PrefsHelper.getString(AppConstants.bearerToken);

    LatLng myLocation = await getCurrentLocation();

    setState(() {
      initialLocation = myLocation;
    });

    print('==============================>>>>>>>> ${myLocation.longitude}');
    print('==============================>>>>>>>> ${myLocation.latitude}');

    /* Timer(const Duration(seconds: 3), (){
      SocketServices.socket?.emit('update-user-location',{
        "accessToken": token,
        "location": {
          "type": "Point",
          "coordinates": [myLocation.longitude, myLocation.latitude]
        }
      });

      print('Yesssssssssssssssssssssss');

    });*/
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

  LatLng initialLocation = const LatLng(23.780696475817816, 90.40761484102724);
  LatLng destination = const LatLng(23.83655877786759, 90.36862693085972);
  List<LatLng> polylineCoordinates = [];
  double currentZoom = 16.4746;
  double markerSize = 40;

  // Offline and online controller
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    polylineCoordinates.add(initialLocation);
    polylineCoordinates.add(destination);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: Obx(() {
          // ✅ Add Obx here
          // Get reactive data
          final userController = Get.find<UserController>();
          final user = userController.userModel.value?.userProfile;
          final profileImage =
              user?.image?.filename ?? Assets.images.profileImage.path;
          final userName = user?.name ?? 'User';
          final currentLocation =
              user?.address ?? '36 East 8th Street, New York, NY 10003, Un...';

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
                                currentLocation,
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
            polylines: {},
            markers: {
              Marker(
                  markerId: const MarkerId('marker'),
                  position: initialLocation,
                  draggable: true,
                  icon: customMarker ?? BitmapDescriptor.defaultMarker,
                  onDragEnd: (updateLanLng) {
                    setState(() {
                      initialLocation = updateLanLng;
                    });
                  },
                  anchor: Offset(0.5, 0.5)),
              Marker(
                markerId: const MarkerId('destination'),
                position: destination,
                draggable: true,
                onDragEnd: (updatedLatLng) {
                  setState(() {
                    destination = updatedLatLng;
                  });
                },
              )
            },
            circles: {
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
                  if (role == 'passenger') _buildSwippedButton(),
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
        onSubmit: () => Get.toNamed(AppRoutes.searchLocationScreen),
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


  // ✅ Stream to monitor location status
  Stream<bool> _locationStatusStream() {
    return Stream.periodic(Duration(seconds: 5), (_) async {
      return await LocationPermissionService.isLocationEnabled();
    }).asyncMap((event) => event);
  }
}
