import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ricardo/feature/controllers/home/map/map_opt_controller.dart';
import 'package:ricardo/feature/models/home/ride_status_model.dart';

class RideEtaMetrics {
  final int distanceMeters;
  final int durationSeconds;
  final bool isLive;

  const RideEtaMetrics({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.isLive,
  });

  bool get hasData => distanceMeters > 0 || durationSeconds > 0;
}

class RideEtaResolver {
  static const double _fallbackSpeedMps = 8.33; // ~30 km/h city driving

  static RideEtaMetrics resolve({
    required MapOPTController controller,
    required RideStatusModel? rideStatus,
  }) {
    if (rideStatus?.startRide == true) {
      return _resolveToDestination(
        controller: controller,
        rideStatus: rideStatus,
      );
    }
    return _resolveToPickup(controller: controller, rideStatus: rideStatus);
  }

  static RideEtaMetrics _resolveToPickup({
    required MapOPTController controller,
    required RideStatusModel? rideStatus,
  }) {
    final pickup = _pickupLatLng(rideStatus, controller);
    final driver = _driverLatLng(controller);
    final localMeters = _distanceMeters(driver, pickup);

    final live = controller.getRideDriverLocation.value;
    final liveTime = live?.driverToPickup?.time?.value ?? 0;
    final liveFresh = controller.isDriverLocationSocketFresh;

    if (localMeters != null && localMeters > 0) {
      return RideEtaMetrics(
        distanceMeters: localMeters,
        durationSeconds: liveFresh && liveTime > 0
            ? liveTime
            : _durationForDistance(
                localMeters,
                prefetchedDistance: controller.prefetchedPickupDistance.value,
                prefetchedDuration: controller.prefetchedPickupDuration.value,
              ),
        isLive: liveFresh,
      );
    }

    if (liveFresh) {
      final liveDist = live?.driverToPickup?.distance?.value ?? 0;
      if (liveDist > 0) {
        return RideEtaMetrics(
          distanceMeters: liveDist,
          durationSeconds:
              liveTime > 0 ? liveTime : _estimateDuration(liveDist),
          isLive: true,
        );
      }
    }

    if (controller.prefetchedPickupDistance.value > 0) {
      return RideEtaMetrics(
        distanceMeters: controller.prefetchedPickupDistance.value,
        durationSeconds: controller.prefetchedPickupDuration.value > 0
            ? controller.prefetchedPickupDuration.value
            : _estimateDuration(controller.prefetchedPickupDistance.value),
        isLive: false,
      );
    }

    return const RideEtaMetrics(
      distanceMeters: 0,
      durationSeconds: 0,
      isLive: false,
    );
  }

  static RideEtaMetrics _resolveToDestination({
    required MapOPTController controller,
    required RideStatusModel? rideStatus,
  }) {
    final destination = _destinationLatLng(rideStatus, controller);
    final driver = _driverLatLng(controller);
    final localMeters = _distanceMeters(driver, destination);

    final live = controller.getRideDriverLocation.value;
    final liveTime = live?.driverToDestination?.time?.value ?? 0;
    final liveFresh = controller.isDriverLocationSocketFresh;

    if (localMeters != null && localMeters > 0) {
      return RideEtaMetrics(
        distanceMeters: localMeters,
        durationSeconds: liveFresh && liveTime > 0
            ? liveTime
            : _durationForDistance(
                localMeters,
                prefetchedDistance:
                    controller.prefetchedDestinationDistance.value,
                prefetchedDuration:
                    controller.prefetchedDestinationDuration.value,
              ),
        isLive: liveFresh,
      );
    }

    if (liveFresh) {
      final liveDist = live?.driverToDestination?.distance?.value ?? 0;
      if (liveDist > 0) {
        return RideEtaMetrics(
          distanceMeters: liveDist,
          durationSeconds:
              liveTime > 0 ? liveTime : _estimateDuration(liveDist),
          isLive: true,
        );
      }
    }

    if (controller.prefetchedDestinationDistance.value > 0) {
      return RideEtaMetrics(
        distanceMeters: controller.prefetchedDestinationDistance.value,
        durationSeconds: controller.prefetchedDestinationDuration.value > 0
            ? controller.prefetchedDestinationDuration.value
            : _estimateDuration(controller.prefetchedDestinationDistance.value),
        isLive: false,
      );
    }

    return const RideEtaMetrics(
      distanceMeters: 0,
      durationSeconds: 0,
      isLive: false,
    );
  }

  static int? _distanceMeters(LatLng? from, LatLng? to) {
    if (from == null || to == null) return null;
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    ).round();
  }

  static LatLng? _driverLatLng(MapOPTController controller) {
    final lat = controller.currentLatitudePosition?.value;
    final lng = controller.currentLongitudePosition?.value;
    if (lat == null || lng == null || lat == 0 || lng == 0) return null;
    return LatLng(lat, lng);
  }

  static LatLng? _pickupLatLng(
    RideStatusModel? rideStatus,
    MapOPTController controller,
  ) {
    final coords = rideStatus?.ride?.pickupLocation?.coordinates ??
        controller.acceptedRideDriverData.value?.ride?.pickupLocation
            ?.coordinates;
    return _latLngFromGeoJson(coords);
  }

  static LatLng? _destinationLatLng(
    RideStatusModel? rideStatus,
    MapOPTController controller,
  ) {
    final coords = rideStatus?.ride?.destinationLocation?.coordinates ??
        controller.acceptedRideDriverData.value?.ride?.destinationLocation
            ?.coordinates;
    return _latLngFromGeoJson(coords);
  }

  static LatLng? _latLngFromGeoJson(List<double>? coordinates) {
    if (coordinates == null || coordinates.length < 2) return null;
    return LatLng(coordinates[1], coordinates[0]);
  }

  static int _estimateDuration(int distanceMeters) {
    if (distanceMeters <= 0) return 0;
    return (distanceMeters / _fallbackSpeedMps).round();
  }

  static int _durationForDistance(
    int distanceMeters, {
    required int prefetchedDistance,
    required int prefetchedDuration,
  }) {
    if (prefetchedDistance > 0 && prefetchedDuration > 0) {
      return ((distanceMeters / prefetchedDistance) * prefetchedDuration)
          .round()
          .clamp(1, prefetchedDuration * 3);
    }
    return _estimateDuration(distanceMeters);
  }
}
