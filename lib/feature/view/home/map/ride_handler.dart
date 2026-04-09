import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/controllers/home/map/map_opt_controller.dart';
import 'package:ricardo/feature/models/socket/get_ride_driver_location.dart';

class RideHandler {
  static bool isNearPickup(GetRideDriverLocation data) {
    final distance = data.driverToPickup?.distance?.value ?? 1000;
    final time = data.driverToPickup?.time?.value ?? 1000;
    return distance <= 100 || time <= 60; // 0.1 km or 1 min
  }

  static bool isNearDestination(GetRideDriverLocation data) {
    final distance = data.driverToDestination?.distance?.value ?? 1000;
    final time = data.driverToDestination?.time?.value ?? 1000;
    return distance <= 100 || time <= 60; // 0.1 km or 1 min
  }

  static String getDestinationInfo(GetRideDriverLocation data) {
    final distance = data.driverToDestination?.distance?.value ?? 0;
    final time = data.driverToDestination?.time?.value ?? 0;
    final distanceInKm = (distance / 1000).toStringAsFixed(1);
    final timeInMin = (time / 60).round();
    return '($timeInMin min) $distanceInKm KM';
  }

  static String getPickupInfo(GetRideDriverLocation data) {
    final distance = data.driverToPickup?.distance?.value ?? 0;
    final time = data.driverToPickup?.time?.value ?? 0;
    final distanceInKm = (distance / 1000).toStringAsFixed(1);
    final timeInMin = (time / 60).round();
    return '($timeInMin min) $distanceInKm KM';
  }

  // Fixed version - accepts data parameter
  static String isNearPickupString(GetRideDriverLocation data) {
    final distance = data.driverToPickup?.distance?.value ?? 0;
    final time = data.driverToPickup?.time?.value ?? 0;
    final distanceInKm = (distance / 1000).toStringAsFixed(1);
    final timeInMin = (time / 60).round();
    return '($timeInMin min) $distanceInKm KM';
  }

  // Alternative: Get from controller
  static String getPickupInfoFromController() {
    final controller = Get.find<MapOPTController>();
    final data = controller.getRideDriverLocation?.value;

    if (data == null) return '(0 min) 0 KM';

    final distance = data.driverToPickup?.distance?.value ?? 0;
    final time = data.driverToPickup?.time?.value ?? 0;
    final distanceInKm = (distance / 1000).toStringAsFixed(1);
    final timeInMin = (time / 60).round();
    return '($timeInMin min) $distanceInKm KM';
  }
}