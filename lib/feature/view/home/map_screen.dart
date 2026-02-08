import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ricardo/app/helpers/prefs_helper.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/app/utils/app_constants.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/get_fcm_tocken.dart';
import 'package:ricardo/services/socket_services.dart';
import 'package:ricardo/widgets/animated_toggle_switch.dart';
import 'package:ricardo/widgets/no_internet_message_map.dart';
import 'package:slide_to_act/slide_to_act.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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

  @override
  void initState() {
    super.initState();
    connectSocket();
    setCustomMarker();
    getMyLocation();
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
        child: ClipRRect(
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
                  border: Border.all(color: Colors.white, width: 2)),
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
                              child: Image.asset(
                                Assets.images.profileImage.path,
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
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
                              '36 East 8th Street, New York, NY 10003, Un...',
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
                          Image.asset(Assets.images.rightArrow.path)
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SizedBox(
                //   height: 10,
                // ),
                AnimatedToggleSwitch(),
                // SizedBox(
                //   height: 30,
                // ),
                NoInternetMessageMap(),

                // Swiped Button are here
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: SlideAction(
                    onSubmit: () => Get.toNamed(AppRoutes.searchLocationScreen),
                    text: 'Lets Go...',
                    innerColor: AppColors.greenColor,
                    outerColor: AppColors.blackButton,
                    sliderButtonIcon: const Icon(
                      Icons.arrow_right_alt,
                      color: Color(0XFFF6F6F6),
                      size: 24,
                      weight: 900,
                    ),
                    sliderRotate: false,
                  ),
                )



              ],
            ),
          )
        ],
      ),
    );
  }
}
