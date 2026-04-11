// // In your widget
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ricardo/feature/controllers/home/map/map_opt_controller.dart';
// import 'package:ricardo/feature/view/home/map/ride_handler.dart';
//
// class RideInfoWidget extends StatelessWidget {
//   const RideInfoWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final MapOPTController controller = Get.find<MapOPTController>();
//
//     return Obx(() {
//       final rideData = controller.currentRideLocation;
//
//       if (rideData == null) {
//         return Text('Loading ride info...');
//       }
//
//       return Column(
//         children: [
//           // Method 1: Using the static method with data
//           Text(RideHandler.getPickupInfo(rideData)),
//
//           // Method 2: Using the controller helper method
//           Text(RideHandler.getPickupInfoFromController()),
//
//           // Method 3: Direct access
//           Text(
//               '(${(rideData.driverToPickup?.time?.value ?? 0) ~/ 60} min) '
//                   '${((rideData.driverToPickup?.distance?.value ?? 0) / 1000).toStringAsFixed(1)} KM'
//           ),
//
//           // Check if near pickup
//           if (RideHandler.isNearPickup(rideData))
//             Text('Driver is near!', style: TextStyle(color: Colors.green)),
//         ],
//       );
//     });
//   }
// }