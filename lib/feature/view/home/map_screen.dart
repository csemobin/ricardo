import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ricardo/widgets/animated_toggle_switch.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const LatLng _center = LatLng(23.8103, 90.4125); // Dhaka 🇧🇩

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _center,
              zoom: 14,
            ),
            mapType: MapType.hybrid,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
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
