import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ricardo/widgets/animated_toggle_switch.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            //initialCameraPosition: _mapCtrl.kGooglePlex,
            initialCameraPosition: CameraPosition(
              target: LatLng(23.78651945317755, 90.42650798667924),
              zoom: 14.4746,
            ),

            // markers: _mapCtrl.markerList.toSet(),

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
