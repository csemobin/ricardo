import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ricardo/feature/controllers/home/map/map_opt_controller.dart';
import 'package:ricardo/feature/controllers/home/map/ride_controller.dart';
import 'package:ricardo/feature/view/home/map/helpers/location_bootstrap_helper.dart';

/// Google Map host for [MapScreen].
///
/// Rebuilds when [MapOPTController.liveOverlayRevision] (or discrete ride
/// state) changes — **not** on every LatLng Rx tick. Marker paints are
/// GPS/socket-rate now, so a same-frame microtask is enough to batch
/// duplicate signals without adding a visible delay.
class MapView extends StatefulWidget {
  const MapView({
    super.key,
    required this.mapOPTController,
    required this.currentZoom,
    required this.defaultLocation,
    required this.markersBuilder,
    required this.polylines,
    required this.onMapCreated,
    required this.onCameraMove,
    this.onCameraMoveStarted,
    this.onCameraIdle,
  });

  final MapOPTController mapOPTController;
  final double currentZoom;
  final LatLng defaultLocation;
  final Set<Marker> Function() markersBuilder;
  final Set<Polyline> polylines;
  final void Function(GoogleMapController) onMapCreated;
  final void Function(CameraPosition) onCameraMove;
  final VoidCallback? onCameraMoveStarted;
  final VoidCallback? onCameraIdle;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  Worker? _overlayWorker;
  bool _rebuildQueued = false;
  CameraPosition? _frozenInitialCamera;

  @override
  void initState() {
    super.initState();
    final rideController = Get.find<RideController>();
    _overlayWorker = everAll(
      [
        widget.mapOPTController.liveOverlayRevision,
        widget.mapOPTController.markerAssetsRevision,
        widget.mapOPTController.rideStatusData,
        widget.mapOPTController.getRideDriverLocation,
        // Passenger "View In Map" — nearby driver markers depend on these.
        rideController.drivers,
        rideController.viewInMapReturn,
      ],
      (_) => _scheduleRebuild(),
    );
  }

  void _scheduleRebuild() {
    if (!mounted || _rebuildQueued) return;
    _rebuildQueued = true;
    // Same-frame only — do not sit on a timer after a new GPS sample.
    scheduleMicrotask(() {
      _rebuildQueued = false;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _overlayWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.mapOPTController;
    final lat = c.currentLatitudePosition?.value;
    final lng = c.currentLongitudePosition?.value;
    _frozenInitialCamera ??= CameraPosition(
      target: isValidLatLng(lat, lng)
          ? LatLng(lat!, lng!)
          : widget.defaultLocation,
      zoom: widget.currentZoom,
      bearing: 0,
      tilt: 0,
    );

    return SizedBox.expand(
      child: GoogleMap(
      initialCameraPosition: _frozenInitialCamera!,
      onMapCreated: widget.onMapCreated,
      markers: widget.markersBuilder(),
      polylines: widget.polylines,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      rotateGesturesEnabled: true,
      tiltGesturesEnabled: false,
      onCameraMove: widget.onCameraMove,
      onCameraMoveStarted: widget.onCameraMoveStarted,
      onCameraIdle: widget.onCameraIdle,
    ),
    );
  }
}
