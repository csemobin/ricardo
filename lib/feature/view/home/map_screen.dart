import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ricardo/feature/models/socket/accept_ride_driver_model.dart';
import 'package:ricardo/feature/models/socket/accept_ride_model.dart';
import 'package:ricardo/feature/view/home/map/custom_header.dart';
import 'package:ricardo/feature/view/home/map/draggable_bottom_sheet.dart';
import 'package:ricardo/widgets/accepted_ride_button.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/glass_background_multiple_children_widget.dart';
import 'package:ricardo/widgets/glass_background_widget.dart';
import 'package:ricardo/widgets/map_custom_header_back.dart';
import 'package:ricardo/widgets/no_internet_message_map.dart';
import 'package:ricardo/widgets/request_ride_handler.dart';
import '../../models/socket/ride_details_socket_model.dart';
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
  late final RideDetailsSocketModel? rideRelatedInfo;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    connectSocket();
    setCustomMarker();
    setCustomCarMarkers();
    getMyLocation();
    userController.fetchUser();
    _loadRoute();
    ever(rideController.isRideAccepted, (bool accepted) {
      if (accepted == true) {
        _loadRoute();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRoute());
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
        setState(() {});
      }
    }
  }

  Future<void> _startLocationTracking() async {
    bool isRunning = await ForegroundLocationService.isRunningService();
    if (!isRunning) {
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
      barrierDismissible: false,
      builder: (context) => LocationPermissionDialog(status: status),
    );
  }

  StreamSubscription<Position>? positionStream;
  BitmapDescriptor? customMarker;

  Future<void> setCustomMarker() async {
    customMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(
        devicePixelRatio: 1.0,
        size: Size(50, 50),
      ),
      "assets/images/location_black_marker.png",
    );
    setState(() {});
  }

  BitmapDescriptor? customCarMarker;

  Future<void> setCustomCarMarkers() async {
    customCarMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(
        devicePixelRatio: 1.0,
        size: Size(50, 50),
      ),
      "assets/images/car_marker.png",
    );
    setState(() {});
  }

  void connectSocket() async {
    String? fcmToken = await FirebaseNotificationService.getFCMToken();
    await PrefsHelper.setString(AppConstants.fcmToken, fcmToken);

    /* ************************************
     *************************************
     * New Ride Request SOCKET ********
     * ***********************************
     * ********************************** */
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

    /* ************************************
     *************************************
     * PASSENGER DATA FROM SOCKET ********
     * ***********************************
     * ********************************** */

    SocketServices.socket?.on(
      'ride-accepted',
      (data) {
        if (data is Map<String, dynamic>) {
          if (data['isRideAccepted'] == true) {
            rideController.isRideAccepted.value = true;

            rideController.acceptedRideDriverName.value =
                data['driver']?['driverName'] ?? '';

            // ✅ Convert JSON to Model
            rideController.acceptRideModel.value =
                AcceptRideModel.fromJson(data);
          }
        }
      },
    );

    /* ************************************
     *************************************
     * DRIVER DATA FROM SOCKET ********
     * ***********************************
     * ********************************** */

    SocketServices.socket?.on('ride-accepted-driver', (data) {
      if (data is Map<String, dynamic>) {
        if (data['isRideAcceptedDriver'] == true) {
          mapOPTController.acceptedRideDataStatus.value = true;
          mapOPTController.acceptedRideData.value =
              AcceptRideDriverModel.fromJson(data);
          _loadAcceptedRideRoute();
        }
      }
    });
/*
    Timer.periodic(
      const Duration(seconds: 3),
          (timer) {
        SocketServices.emit('get-driver-location', ( ){

        });
      },
    );*/

  }

  /* ************************************
   *************************************
   * Location Related Data are here ***
   * ***********************************
   * ********************************** */

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
  }

  List<LatLng> polylineCoordinates = [];
  double currentZoom = 18.5746;
  double markerSize = 40;

  // Offline and online controller
  bool isOnline = true;

  /* ********* MAP Polyline Related Start  here *************/
  Set<Polyline> _polylines = {};

  Future<void> _loadRoute() async {
    try {
      final acceptedRide = rideController.acceptRideModel.value;

      final LatLng origin;
      final LatLng dest;
      final LatLng acceptedLocation;

      final pickupCoords = acceptedRide?.ride?.pickupLocation?.coordinates;
      final destCoords = acceptedRide?.ride?.destinationLocation?.coordinates;
      final driverAcceptedLocationCoords =
          acceptedRide?.ride?.driverAcceptedLocation?.coordinates;

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

      acceptedLocation = (driverAcceptedLocationCoords != null &&
              driverAcceptedLocationCoords.length == 2)
          ? LatLng(
              driverAcceptedLocationCoords[1], driverAcceptedLocationCoords[0])
          : LatLng(
              googleSearchLocationController.selectedDrop.value?.lat ?? 0.0,
              googleSearchLocationController.selectedDrop.value?.lng ?? 0.0,
            );

      // Guard: don't draw if coords are 0,0
      if (origin.latitude == 0.0 ||
          dest.latitude == 0.0 ||
          acceptedLocation.latitude == 0.0) {
        debugPrint('Skipping route — coords not ready');
        return;
      }

      final point =
          await DirectionsService.getPolyline(acceptedLocation, origin);
      final points = await DirectionsService.getPolyline(origin, dest);

      if (points.isEmpty) {
        Get.snackbar(
            'Error', 'Could not load route. Please check your API key.');
        return;
      }

      setState(() {
        // Set polylines
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
          Polyline(
            polylineId: const PolylineId('Destination'),
            points: [origin, points.first],
            color: Colors.red,
            width: 4,
            patterns: [PatternItem.dot, PatternItem.gap(12)],
          ),
        };

        markers.removeWhere((m) =>
            m.markerId.value == 'Pick-Up-Location' ||
            m.markerId.value == 'Destination');

        markers.addAll({
          Marker(
            markerId: const MarkerId('Pick-Up-Location'),
            position: acceptedLocation,
            icon: customCarMarker ?? BitmapDescriptor.defaultMarker,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Passenger
          Obx(
            () => GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(mapOPTController.currentLatitudePosition!.value,
                    mapOPTController.currentLongitudePosition!.value),
                zoom: currentZoom,
              ),
              markers: _buildMarkers(),
              polylines: _polylines,
              onMapCreated: (controller) {
                _mapController = controller;
                _loadRoute(); // ← also call here so map is ready
              },

              circles: {
                Circle(
                  circleId: CircleId('currentPassenger'),
                  center: LatLng(
                    mapOPTController.currentLatitudePosition!.value,
                    mapOPTController.currentLongitudePosition!.value,
                  ),
                  radius: 10,
                  strokeColor: Colors.white,
                  strokeWidth: 1,
                  fillColor: Color(0xFF006491).withOpacity(0.2),
                  consumeTapEvents: true,
                ),
                Circle(
                  circleId: const CircleId('destination'),
                  // center: destination,
                  radius: 10,
                  strokeColor: Colors.white,
                  strokeWidth: 1,
                  fillColor: const Color(0xFF006491).withOpacity(0.2),
                ),
              },
            ),
          ),

          // Bottom Sheet Related work are here
          if (userController.userModel.value?.userProfile?.role ==
                  AppConstants.passenger &&
              rideController.acceptRideModel.value?.isRideAccepted == true)
            DraggableBottomSheet(
              acceptRideModel: rideController.acceptRideModel.value,
            ),
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
          // Custom Header - Only shows when conditions are true [ Complete ]
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

          SafeArea(
            child: Column(
              children: [
                /* Driver Toggle Switch [ Fixed ] */
                Obx(() {
                  if (userController.userModel.value?.userProfile?.role ==
                          AppConstants.driver &&
                      mapOPTController.acceptedRideDataStatus.value == false) {
                    return AnimatedToggleSwitch();
                  }
                  return const SizedBox.shrink();
                }),

                Obx(() {
                  if (mapOPTController
                          .acceptedRideData.value?.isRideAcceptedDriver ==
                      true) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.w),
                      child: SizedBox(
                        // ← ADD THIS
                        width: double.infinity, // ← FORCES BOUNDED WIDTH
                        child: GlassBackgroundWidget(
                          borderLeftRightRadius: 24,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max, // ← ADD THIS
                            children: [
                              Icon(
                                Icons.location_pin,
                                size: 24.sp,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${mapOPTController.acceptedRideData.value?.passenger?.passengerAddress}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: FontFamily.poppins,
                                        color: Color(0xff171717),
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
                                          return Text('Loading...');
                                        }
                                        if (snapshot.hasError) {
                                          return Text('Error getting address');
                                        }
                                        return Text(
                                          snapshot.data ?? 'No address found',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: FontFamily.poppins,
                                            color: Color(0xffA3A3A3),
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
                  return SizedBox.shrink();
                }),

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

                /* Passenger Swipped Button [ Fixed ] */
                // Passenger Swipped Button - Only shows when ALL conditions are false
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
                        SizedBox(
                          height: 100,
                        ),
                      ],
                    );
                  }
                  return SizedBox.shrink();
                }),

                /* Driver Waiting Passenger Request a Card */
                Obx(() {
                  if (userController.userModel.value?.userProfile?.role ==
                          AppConstants.driver &&
                      mapOPTController.isPassengerRequest.value == false &&
                      userController.userModel.value?.driverProfile?.isOnline ==
                          true) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 90.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 25.w,
                      ),
                      child: _bgGlassDesign(_buildPassengerRequestCard()),
                    );
                  }
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
                                borderRadius: BorderRadius.circular(50)),
                          ),
                        ),
                        SizedBox(
                          height: 50.h,
                        ),
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
                                          mapOPTController
                                              .rideDetailsData
                                              .value!
                                              .passengerImage!
                                              .isNotEmpty)
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
                            SizedBox(
                              width: 10.w,
                            ),
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
                                        '(${((mapOPTController.rideDetailsData.value?.destinationMeters ?? 0) * 0.000621371).toStringAsFixed(2)} Miles)')
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Divider(
                          height: 1,
                          color: Colors.black.withOpacity(0.2),
                        ),
                        SizedBox(
                          height: 6.h,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(Assets.images.directRight),
                                SizedBox(
                                  width: 8.w,
                                ),
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
                                        // 'Pickup location not specified',
                                        style: textStyle(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 4.w,
                                top: 4.h,
                                bottom: 4.h,
                              ),
                              child: Container(
                                width: 4.w,
                                height: 40.h,
                                decoration: BoxDecoration(color: Colors.white
                                    // color: Color(0xffD9D9D9),
                                    ),
                              ),
                            ),
                            Row(
                              children: [
                                SvgPicture.asset(Assets.images.location),
                                SizedBox(
                                  width: 8.w,
                                ),
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
                                        // 'Destination not specified',
                                        style: textStyle(),
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
                        SizedBox(
                          height: 6.h,
                        ),
                        Divider(
                          height: 1,
                          color: Colors.black.withOpacity(0.2),
                        ),
                        SizedBox(
                          height: 8.h,
                        ),
                        Text(
                          'Passengers Note',
                          style: TextStyle(
                            color: Color(0xff5E5E5E).withOpacity(0.7),
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Text(mapOPTController
                                .rideDetailsData.value?.destinationAddress ??
                            ''),
                        SizedBox(
                          height: 18.h,
                        ),
                        AcceptRideButton(
                          onPressed: () {
                            // mapOPTController.rideDetailsData
                            mapOPTController.rideAcceptRide(mapOPTController
                                .rideDetailsData.value!.rideId
                                .toString());
                          },
                        ),
                        SizedBox(height: 80),
                      ],
                    );
                  }

                  if (mapOPTController
                              .acceptedRideData.value?.isRideAcceptedDriver ==
                          true &&
                      mapOPTController.acceptedRideDataStatus.value == true) {
                    return GlassBackgroundWidget(
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 40.h,
                              ),
                              Text(
                                '(4 min) ${((mapOPTController.acceptedRideData.value?.ride?.destinationMeters ?? 0) * 0.000621371).toStringAsFixed(2)} Miles',
                                style: TextStyle(
                                  color: Color(0xff171717),
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                height: 28.h,
                              ),
                              Divider(
                                height: 1,
                                color: Colors.black.withOpacity(0.2),
                              ),
                              SizedBox(
                                height: 16.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50)),
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
                                            height: 50.h,
                                            width: 50.w,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
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
                                      SizedBox(
                                        width: 10.w,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mapOPTController.rideDetailsData
                                                    .value?.passengerName ??
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
                                                  '(${((mapOPTController.rideDetailsData.value?.destinationMeters ?? 0) * 0.000621371).toStringAsFixed(2)} Miles)')
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {},
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
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 40.h,
                          ),
                          CustomPrimaryButton(
                              title: 'On the way', onHandler: () {}),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.05),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.05),
                        ],
                      ),
                    );
                  }
                  return SizedBox.shrink();
                }),
              ],
            ),
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

  TextStyle textStyle() {
    return TextStyle(
      color: AppColors.primaryHeadingTextColor,
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      fontFamily: FontFamily.poppins,
    );
  }

  Set<Marker> _buildMarkers() {
    // Build fresh — never touch class-level `markers` here
    final Set<Marker> result = {};

    // ── 1. Always add current passenger / driver position pin ──────────────
    result.add(
      Marker(
        markerId: const MarkerId('currentPassenger'),
        position: LatLng(
          mapOPTController.currentLatitudePosition!.value,
          mapOPTController.currentLongitudePosition!.value,
        ),
        icon: userController.userModel.value?.userProfile?.role ==
                AppConstants.passenger
            ? customMarker ?? BitmapDescriptor.defaultMarker
            : customCarMarker ?? BitmapDescriptor.defaultMarker,
      ),
    );

    // ── 2. Add route markers (Pick-Up-Location + Destination) if they exist ──
    // These are stored in class-level `markers` by _loadRoute()
    for (final m in markers) {
      if (m.markerId.value == 'Pick-Up-Location' ||
          m.markerId.value == 'Destination') {
        result.add(m);
      }
    }

    // ── 3. Decide whether to show driver car icons ─────────────────────────
    // A route is "active" when _loadRoute() has added route markers
    final bool isRouteActive = markers.any(
      (m) =>
          m.markerId.value == 'Pick-Up-Location' ||
          m.markerId.value == 'Destination',
    );

    // Show driver car icons when:
    //   a) User pressed back from NearByDriverScreen (viewInMapReturn == true), OR
    //   b) No route is active yet and drivers list has entries
    // Hide driver car icons when:
    //   - viewInMap == false (bottom sheet / nearby screen is showing) AND
    //     viewInMapReturn == false (user has NOT pressed back yet)
    final bool showDriverIcons =
        rideController.viewInMapReturn.value || !isRouteActive;

    if (showDriverIcons) {
      final drivers = rideController.drivers;
      for (var driver in drivers) {
        final coords = driver.location?.coordinates;
        if (coords != null && coords.length == 2) {
          final double longitude = coords[0];
          final double latitude = coords[1];
          result.add(Marker(
            markerId: MarkerId(driver.sId ?? UniqueKey().toString()),
            position: LatLng(latitude, longitude),
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
          sigmaX: 8,
          sigmaY: 8,
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
        left: 20,
        right: 20,
      ),
      child: SlideAction(
        sliderButtonYOffset: 0,
        onSubmit: () => Get.toNamed(AppRoutes.searchLocationScreen,
            arguments: {'back_disable': true}),
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

  /*
  *  Widget _buildSwippedButton() {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: SlideAction(
        sliderButtonYOffset: 0,
        onSubmit: () => Get.toNamed(AppRoutes.searchLocationScreen,
            arguments: {'back_disable': true}),
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

  * */
  // ✅ Stream to monitor location status
  Stream<bool> _locationStatusStream() {
    return Stream.periodic(Duration(seconds: 5), (_) async {
      return await LocationPermissionService.isLocationEnabled();
    }).asyncMap((event) => event);
  }

  Future<void> _loadAcceptedRideRoute() async {
    try {
      final acceptedRide = mapOPTController.acceptedRideData.value;
      if (acceptedRide == null) return;

      // ── 1. Driver Current Location ──────────────────────────
      final Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final LatLng driverLocation = LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      // ── 2. Pickup Location ✅ use ride?.pickupLocation ──────
      final pickupCoords = acceptedRide.ride?.pickupLocation?.coordinates;
      if (pickupCoords == null || pickupCoords.length < 2) return;
      final LatLng pickupLocation = LatLng(pickupCoords[1], pickupCoords[0]);

      // ── 3. Destination Location ─────────────────────────────
      final destCoords = acceptedRide.ride?.destinationLocation?.coordinates;
      if (destCoords == null || destCoords.length < 2) return;
      final LatLng destinationLocation = LatLng(destCoords[1], destCoords[0]);

      // ── 4. Guard: skip if coords are 0,0 ───────────────────
      if (driverLocation.latitude == 0.0 ||
          pickupLocation.latitude == 0.0 ||
          destinationLocation.latitude == 0.0) {
        debugPrint('Skipping — coords not ready');
        return;
      }

      // ── 5. Get Polylines ────────────────────────────────────
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
          // 🔴 Driver → Pickup
          Polyline(
            polylineId: const PolylineId('driver_to_pickup'),
            points: driverToPickup,
            color: Colors.black87,
            width: 6,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
          // 🟢 Pickup → Destination
          Polyline(
            polylineId: const PolylineId('pickup_to_destination'),
            points: pickupToDestination,
            color: Colors.green,
            width: 6,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        };

        markers
          ..removeWhere((m) =>
              m.markerId.value == 'driver_location' ||
              m.markerId.value == 'pickup_location' ||
              m.markerId.value == 'destination_location')
          ..addAll({
            // 🚗 Driver (Car icon)
            Marker(
              markerId: const MarkerId('driver_location'),
              position: driverLocation,
              icon: customCarMarker ?? BitmapDescriptor.defaultMarker,
            ),
            // 📍 Pickup (Red pin)
            Marker(
              markerId: const MarkerId('pickup_location'),
              position: pickupLocation,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
            ),
            // 📍 Destination (Green pin)
            Marker(
              markerId: const MarkerId('destination_location'),
              position: destinationLocation,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
            ),
          });
      });

      // ── 6. Camera fits all 3 points ─────────────────────────
      final allPoints = [...driverToPickup, ...pickupToDestination];
      final bounds = _boundsFromLatLng(allPoints);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    } catch (e) {
      debugPrint('_loadAcceptedRideRoute error: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    positionStream?.cancel();

    WidgetsBinding.instance.removeObserver(this);
    positionStream?.cancel();
    super.dispose();
  }
}
