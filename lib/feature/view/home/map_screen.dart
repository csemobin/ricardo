import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ricardo/widgets/animated_toggle_switch.dart';

class MapScreen extends StatefulWidget{
  const MapScreen({super.key});
  @override
  State<MapScreen>createState() => _MapScreenState();
}
class _MapScreenState extends State<MapScreen>{
  BitmapDescriptor? customMarker;

  Future<void> setCustomMarker(markerSize) async {
    customMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(markerSize, markerSize)),  "assets/images/car_marker.png"
    );
    setState(() {});
  }

  @override
  void initState(){
    super.initState();
    setCustomMarker(markerSize);
  }

  LatLng initialLocation = const LatLng(23.780774769697594, 90.40709549570792);
  LatLng destination = const LatLng(23.83655877786759, 90.36862693085972);
  List<LatLng> polylineCoordinates  = [];
  double currentZoom = 14.4746;
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
              currentZoom = position.zoom;

              double newSize = (currentZoom * 3).clamp(20, 100);
              if ((newSize - markerSize).abs() > 2) {
                markerSize = newSize;
                setCustomMarker(markerSize);
              }
            },
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            //initialCameraPosition: _mapCtrl.kGooglePlex,

            initialCameraPosition: CameraPosition(
              target: initialLocation,
              zoom: 14.4746,
            ),

            markers:{
              Marker(
                markerId: const MarkerId('marker'),
                position: initialLocation,
                draggable: true,
                icon: customMarker ?? BitmapDescriptor.defaultMarker,
              ),
              Marker(
                  markerId: const MarkerId('destination'),
                  position: destination,
                  draggable: true,
                  onDragEnd:(updatedLatLng){

                  }

              )
            },
            circles: {
              Circle(
                circleId: CircleId('marker'),
                center: initialLocation,
                radius: 120,
                strokeColor: Colors.white,
                strokeWidth: 1,
                fillColor: Color(0xFF006491).withOpacity(0.2),
              ), Circle(
                circleId: const CircleId('destination'),
                center: destination,   // ✅ FIXED
                radius: 120,
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
