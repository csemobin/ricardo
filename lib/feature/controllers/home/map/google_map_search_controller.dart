/*
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

// import '../../app/utils/app_constant.dart';

class MapSearchController extends GetxController {
  // Current position
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  // Map controller
  GoogleMapController? _mapController;
  GoogleMapController? get mapController => _mapController;

  final Set<Marker> _markers = <Marker>{};
  Set<Marker> get markers => _markers;

  final Set<Polyline> _polylines = <Polyline>{};
  Set<Polyline> get polylines => _polylines;

  final List<LatLng> _polylineCoordinates = [];
  List<LatLng> get polylineCoordinates => _polylineCoordinates;

  LatLng? _startLocation;
  LatLng? _endLocation;
  List<LatLng> _pitStops = [];

  LatLng? get startLocation => _startLocation;
  LatLng? get endLocation => _endLocation;
  List<LatLng> get pitStops => _pitStops;

  // Loading states
  final RxBool _isLoadingCurrentLocation = false.obs;
  bool get isLoadingCurrentLocation => _isLoadingCurrentLocation.value;

  final RxBool _isLoadingPlaces = false.obs;
  bool get isLoadingPlaces => _isLoadingPlaces.value;

  // Timer for debounce
  Timer? _debounce;

  // Polyline points
  // final PolylinePoints _polylinePoints = PolylinePoints(apiKey: apiKey);

  @override
  void onClose() {
    _debounce?.cancel();
    _mapController?.dispose();
    super.onClose();
  }

  // Set map controller
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    _isLoadingCurrentLocation.value = true;

    try {
      if (await _checkPermissionStatus()) {
        if (await _isGpsServiceEnable()) {
          _currentPosition = await Geolocator.getCurrentPosition(
            // locationSettings: const LocationSettings(
            //   accuracy: LocationAccuracy.best,
            // ),
          );

          _addCurrentLocationMarker();
          _animateToLocation(LatLng(_currentPosition!.latitude, _currentPosition!.longitude));

          print('LatLong: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
        } else {
          await _requestGpsService();
        }
      } else {
        await _requestPermission();
      }
    } catch (e) {
      print('Error getting current location: $e');
    } finally {
      _isLoadingCurrentLocation.value = false;
    }
  }

  // Listen to current location updates
  Future<void> listenCurrentLocation() async {
    if (await _checkPermissionStatus()) {
      if (await _isGpsServiceEnable()) {
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 10),
          ),
        ).listen((position) {
          print('Location update: $position');
        });
      } else {
        await _requestGpsService();
      }
    } else {
      await _requestPermission();
    }
  }

  // Add current location marker
  void _addCurrentLocationMarker() {
    if (_currentPosition == null) return;

    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        infoWindow: InfoWindow(
          title: 'My location',
          snippet: '${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
        ),
      ),
    );

    _polylineCoordinates.clear();
    _polylineCoordinates.add(
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
    );

    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('myRoutes'),
        points: _polylineCoordinates,
        color: Colors.blue,
        width: 5,
      ),
    );

    update();
  }

  void addMarker(LatLng position, {String title = 'Selected Location', bool isStartLocation = true}) {
    final String markerId = isStartLocation ? 'start_location' : 'end_location';

    _markers.removeWhere((marker) => marker.markerId.value == markerId);

    _markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: position,
        infoWindow: InfoWindow(title: title),
        icon: isStartLocation
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    if (isStartLocation) {
      _startLocation = position;
    } else {
      _endLocation = position;
    }

    update();
  }

  void fitMarkersInView() {
    if (_startLocation != null && _endLocation != null) {
      final LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          _startLocation!.latitude < _endLocation!.latitude ? _startLocation!.latitude : _endLocation!.latitude,
          _startLocation!.longitude < _endLocation!.longitude ? _startLocation!.longitude : _endLocation!.longitude,
        ),
        northeast: LatLng(
          _startLocation!.latitude > _endLocation!.latitude ? _startLocation!.latitude : _endLocation!.latitude,
          _startLocation!.longitude > _endLocation!.longitude ? _startLocation!.longitude : _endLocation!.longitude,
        ),
      );

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    } else if (_startLocation != null) {
      updateCameraPosition(_startLocation!);
    } else if (_endLocation != null) {
      updateCameraPosition(_endLocation!);
    }
  }

  void _animateToLocation(LatLng latLng) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  void updateCameraPosition(LatLng latLng, {double zoom = 14.0}) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, zoom));
  }

  void clearMapData() {
    _markers.clear();
    _polylines.clear();
    _polylineCoordinates.clear();
    _startLocation = null;
    _endLocation = null;
    _pitStops.clear();
    update();
  }

  void clearMarker(bool isStartLocation) {
    final String markerId = isStartLocation ? 'start_location' : 'end_location';
    _markers.removeWhere((marker) => marker.markerId.value == markerId);

    if (isStartLocation) {
      _startLocation = null;
    } else {
      _endLocation = null;
    }

    update();
  }

  Future<bool> _checkPermissionStatus() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> _requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> _isGpsServiceEnable() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<void> _requestGpsService() async {
    await Geolocator.openLocationSettings();
  }

  void debouncedSearch(String query, Function(String) searchFunction) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        searchFunction(query);
      }
    });
  }

  void clearDebounce() {
    _debounce?.cancel();
  }

  void addCustomMarker(LatLng position, String title, BitmapDescriptor? icon) {
    _markers.add(
      Marker(
        markerId: MarkerId('custom_${position.toString()}'),
        position: position,
        infoWindow: InfoWindow(title: title),
        icon: icon ?? BitmapDescriptor.defaultMarker,
      ),
    );
    update();
  }

  void updateRoute(List<LatLng> routePoints) {
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: PolylineId('route'),
        points: routePoints,
        color: Colors.blue,
        width: 5,
        geodesic: true,
      ),
    );
    update();
  }

  // Clear route
  void clearRoute() {
    _polylines.clear();
    update();
  }

  void setStartLocation(LatLng location, String address) {
    _startLocation = location;
    _markers.removeWhere((marker) => marker.markerId.value == 'start_location');
    _markers.add(
      Marker(
        markerId: MarkerId('start_location'),
        position: location,
        infoWindow: InfoWindow(title: 'Start: $address'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
    update();
  }

  void setEndLocation(LatLng location, String address) {
    _endLocation = location;
    _markers.removeWhere((marker) => marker.markerId.value == 'end_location');
    _markers.add(
      Marker(
        markerId: MarkerId('end_location'),
        position: location,
        infoWindow: InfoWindow(title: 'End: $address'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    if (_startLocation != null) {
      updatePolyline(_startLocation!, location);
    }
    update();
  }

  void addPitStop(LatLng location, String address, BitmapDescriptor? icon) {
    _pitStops.add(location);
    _markers.add(
      Marker(
        markerId: MarkerId('pitstop_${_pitStops.length}'),
        position: location,
        infoWindow: InfoWindow(title: 'Pit Stop ${_pitStops.length}: $address'),
        icon: icon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );

    if (_startLocation != null && _endLocation != null) {
      _generateRouteWithPitStops(_startLocation!, _endLocation!, _pitStops);
    }
    update();
  }

  void _generateRoute(LatLng start, LatLng end) {
    List<LatLng> routePoints = [start, end];

    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: PolylineId('main_route'),
        points: routePoints,
        color: Colors.blue,
        width: 4,
        geodesic: true,
      ),
    );
    update();
  }

  void _generateRouteWithPitStops(LatLng start, LatLng end, List<LatLng> stops) {
    List<LatLng> routePoints = [start];
    routePoints.addAll(stops);
    routePoints.add(end);

    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: PolylineId('route_with_stops'),
        points: routePoints,
        color: Colors.blue,
        width: 4,
        geodesic: true,
      ),
    );
    update();
  }

  void clearAllLocations() {
    _startLocation = null;
    _endLocation = null;
    _pitStops.clear();
    _markers.clear();
    _polylines.clear();
    update();
  }

  void updatePolyline(LatLng origin, LatLng destination) {
    _getPolyline(origin, destination).then((_) {
      Future.delayed(Duration(milliseconds: 500), () {
        fitMarkersInView();
      });
    });
  }

  Future<void> _getPolyline(LatLng origin, LatLng destination) async {
    debugPrint("🚀 Fetching polyline...");

    // final url = Uri.parse(
    //   'https://maps.googleapis.com/maps/api/directions/json?'
    //       'origin=${origin.latitude},${origin.longitude}&'
    //       'destination=${destination.latitude},${destination.longitude}&'
    //       'key=${AppConstants.googleApiKey}',
    // );

    try {
      // final response = await http.get(url);
      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   if (data['routes'].isNotEmpty) {
      //     final encodedPolyline = data['routes'][0]['overview_polyline']['points'];
      //     // final points = _polylinePoints.decodePolyline(encodedPolyline);
      //
      //     _polylines.clear();
      //     // _polylines.add(
      //     //   Polyline(
      //     //     polylineId: const PolylineId("route"),
      //     //     color: Color(0xFF4FAF5A),
      //     //     points: points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
      //     //     width: 5,
      //     //   ),
      //     // );
      //
      //     update();
      //     // debugPrint("✅ Polyline drawn with ${points.length} points");
      //   } else {
      //     debugPrint("❌ No routes found in API response");
      //   }
      // } else {
      //   // debugPrint("❌ API Error: ${response.statusCode}");
      // }
    } catch (e) {
      debugPrint("🔥 Exception: $e");
    }
  }

  void clearPolylines() {
    _polylines.clear();
    update();
  }


  // Add pit stop marker
  void addPitStopMarker(LatLng position, String title, BitmapDescriptor? icon) {
    final String markerId = 'pitstop_${_pitStops.length}';

    _pitStops.add(position);
    _markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: position,
        infoWindow: InfoWindow(title: title),
        icon: icon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );
    update();
  }

// Remove pit stop marker
  void removePitStopMarker(int index) {
    if (index >= 0 && index < _pitStops.length) {
      final String markerId = 'pitstop_${index + 1}';
      _markers.removeWhere((marker) => marker.markerId.value == markerId);
      _pitStops.removeAt(index);

      // Update remaining marker IDs
      for (int i = index; i < _pitStops.length; i++) {
        final String oldMarkerId = 'pitstop_${i + 2}';
        final String newMarkerId = 'pitstop_${i + 1}';

        final marker = _markers.firstWhere(
              (m) => m.markerId.value == oldMarkerId,
          orElse: () => Marker(markerId: const MarkerId('')),
        );

        if (marker.markerId.value != '') {
          _markers.remove(marker);
          _markers.add(
            Marker(
              markerId: MarkerId(newMarkerId),
              position: marker.position,
              infoWindow: marker.infoWindow,
              icon: marker.icon,
            ),
          );
        }
      }
      update();
    }
  }

  void clearPitStopMarkers() {
    _markers.removeWhere((marker) => marker.markerId.value.startsWith('pitstop_'));
    _pitStops.clear();
    update();
  }

  List<LatLng> get pitStopPositions => _pitStops;

}*/
