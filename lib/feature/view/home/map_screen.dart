import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ricardo/app/helpers/prefs_helper.dart';
import 'package:ricardo/app/utils/app_constants.dart';
import 'package:ricardo/services/get_fcm_tocken.dart';
import 'package:ricardo/services/socket_services.dart';
import 'package:ricardo/widgets/animated_toggle_switch.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  StreamSubscription<Position>? positionStream;

  BitmapDescriptor? customMarker;
  Future<void> setCustomMarker() async {
    customMarker = await BitmapDescriptor.fromAssetImage(
      mipmaps: true,
      ImageConfiguration(size: Size(10, 10)),
      "assets/images/car_marker.png",
    );
    setState(() {});
  }

  Future<LatLng>getCurrentLocation() async{
    bool serviceEnable;
    LocationPermission permission;

    //Check if location service is enabled
    serviceEnable = await Geolocator.isLocationServiceEnabled();

    if( !serviceEnable ){
      return Future.error('Location Services are disable');
    }
    permission = await Geolocator.checkPermission();

    if( permission == LocationPermission.denied ){
      permission = await Geolocator.requestPermission();
      
      if( permission == LocationPermission.denied ){
        return Future.error("Location Permission denied");
      }
    }
    
    if( permission == LocationPermission.deniedForever ){
      return Future.error("Location Permission Permanently denied.Enable from settings");
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy:  LocationAccuracy.high
    );

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
    SocketServices.socket?.emit('user-connected', {
      "accessToken" : getAccessToken,
      "fcmToken" : fcmToken
    });
  }

  Future<void> getMyLocation() async {
    var  token = await PrefsHelper.getString(AppConstants.bearerToken);

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

      print("Live location sent: ${newLocation.latitude}, ${newLocation.longitude}");
    });

    SocketServices.socket?.on('updated-user-location-data', (data){
      print(data);
    });

  }

  LatLng initialLocation = const LatLng(23.780696475817816, 90.40761484102724);
  LatLng destination = const LatLng(23.83655877786759, 90.36862693085972);
  List<LatLng> polylineCoordinates = [];
  double currentZoom = 16.4746;
  double markerSize = 40;

  @override
  Widget build(BuildContext context) {
    polylineCoordinates.add(initialLocation);
    polylineCoordinates.add(destination);

    return Scaffold(
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
            polylines: {

            },
            markers: {
              Marker(
                markerId: const MarkerId('marker'),
                position: initialLocation,
                draggable: true,
                icon: customMarker ?? BitmapDescriptor.defaultMarker,
                onDragEnd: (updateLanLng){
                  setState(() {
                    initialLocation = updateLanLng;
                  });
                },

              ),
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
                consumeTapEvents: true
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
          SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedToggleSwitch(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
