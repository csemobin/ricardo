import 'dart:async';
import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/helpers/prefs_helper.dart';
import 'package:ricardo/feature/controllers/custom_bottom_nav_bar_controller.dart';
import 'package:ricardo/feature/controllers/home/map/ride_controller.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/feature/models/home/place_suggestion.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';
import 'package:ricardo/services/map_service.dart';

class GoogleSearchLocationController extends GetxController {
  // Text controllers
  final pickupController = TextEditingController();
  final dropController = TextEditingController();
  final noteController = TextEditingController();

  // Suggestions lists
  final pickupPlaces = <PlaceSuggestion>[].obs;
  final dropPlaces = <PlaceSuggestion>[].obs;

  // Loading states
  final isLoadingPickup = false.obs;
  final isLoadingDrop = false.obs;
  final isLoadingFare = false.obs;

  // Clear buttons visibility
  final showClearPickup = false.obs;
  final showClearDrop = false.obs;

  // Selected locations
  final selectedPickup = Rxn<PlaceDetails>();
  final selectedDrop = Rxn<PlaceDetails>();

  // Fare calculation results
  final distance = ''.obs;
  final duration = ''.obs;
  final fare = 0.0.obs;
  final sendingMetersValue = 0.0.obs;
  // Timers for search delay
  Timer? _pickupTimer;
  Timer? _dropTimer;

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
  }

  void _setupListeners() {
    // Listen to pickup text changes
    pickupController.addListener(() {
      final hasText = pickupController.text.isNotEmpty;
      if (showClearPickup.value != hasText) showClearPickup.value = hasText;

      if (!_isSelectingPickup) {
        _startPickupSearch();
      }
    });

    // Listen to drop text changes
    dropController.addListener(() {
      final hasText = dropController.text.isNotEmpty;
      if (showClearDrop.value != hasText) showClearDrop.value = hasText;

      if (!_isSelectingDrop) {
        _startDropSearch();
      }
    });
  }

  bool _isSelectingPickup = false;
  bool _isSelectingDrop = false;

  void _startPickupSearch() {
    _pickupTimer?.cancel();
    _pickupTimer = Timer(Duration(milliseconds: 500), () {
      _searchPickup(pickupController.text);
    });
  }

  void _startDropSearch() {
    _dropTimer?.cancel();
    _dropTimer = Timer(Duration(milliseconds: 500), () {
      _searchDrop(dropController.text);
    });
  }

  Future<void> _searchPickup(String query) async {
    if (query.isEmpty) {
      pickupPlaces.clear();
      isLoadingPickup.value = false;
      return;
    }

    isLoadingPickup.value = true;
    try {
      final results = await PlacesService.getPlaceSuggestions(query);
      pickupPlaces.value = results;
    } finally {
      isLoadingPickup.value = false;
    }
  }

  Future<void> _searchDrop(String query) async {
    if (query.isEmpty) {
      dropPlaces.clear();
      isLoadingDrop.value = false;
      return;
    }

    isLoadingDrop.value = true;
    try {
      final results = await PlacesService.getPlaceSuggestions(query);
      dropPlaces.value = results;
    } finally {
      isLoadingDrop.value = false;
    }
  }

  Future<void> selectPickup(PlaceSuggestion place) async {
    _isSelectingPickup = true;

    pickupController.text = place.description;
    showClearPickup.value = true;
    pickupPlaces.clear();

    await Future.delayed(Duration(milliseconds: 100));
    _isSelectingPickup = false;

    final details = await PlacesService.getPlaceDetails(place.placeId);
    selectedPickup.value = details;
  }

  Future<void> selectDrop(PlaceSuggestion place) async {
    _isSelectingDrop = true;

    dropController.text = place.description;
    showClearDrop.value = true;
    dropPlaces.clear();

    await Future.delayed(Duration(milliseconds: 100));
    _isSelectingDrop = false;

    final details = await PlacesService.getPlaceDetails(place.placeId);
    selectedDrop.value = details;
  }

  void clearPickup() {
    pickupController.clear();
    showClearPickup.value = false;
    pickupPlaces.clear();
    selectedPickup.value = null;
    _clearFare();
  }

  void clearDrop() {
    dropController.clear();
    showClearDrop.value = false;
    dropPlaces.clear();
    selectedDrop.value = null;
    _clearFare();
  }

  void clearNote() {
    noteController.clear();
  }

  void _clearFare() {
    distance.value = '';
    duration.value = '';
    fare.value = 0.0;
  }

  bool get canCalculateFare {
    return selectedPickup.value != null && selectedDrop.value != null;
  }

  bool get hasFare {
    return fare.value > 0;
  }
  RxBool showPopUpStatus = false.obs;
  Future<void> calculateFare() async {
    if (!canCalculateFare) {
      Get.snackbar('Error', 'Please select both locations');
      return;
    }

    isLoadingFare.value = true;

    try {
      final pickup = selectedPickup.value!;
      final drop = selectedDrop.value!;

      print('Calculating fare...');
      print('Pickup: ${pickup.address}');
      print('Pickup: ${pickup.lat}');
      print('Pickup: ${pickup.lng}');
      print('Drop: ${drop.address}');
      print('Drop: ${drop.lat}');
      print('Drop: ${drop.lng}');
      print('Note: ${noteController.text}');

      // Call Google Distance API
      final apiResponse = await _getDistanceFromGoogle(
        pickupLat: pickup.lat,
        pickupLng: pickup.lng,
        dropLat: drop.lat,
        dropLng: drop.lng,
      );

      if (apiResponse != null) {
        showPopUpStatus.value = true;
        _updateFareFromResponse(apiResponse);

        // ✅ REMOVED: No need for Snackbar since popup will show
        // Get.snackbar(
        //   'Success',
        //   'Fare calculated!',
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        // );
      }
    } finally {
      isLoadingFare.value = false;
    }
  }

  Future<Map<String, dynamic>?> _getDistanceFromGoogle({
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
  }) async {
    final apiKey = dotenv.env['MAP_API_KEY'];
    final origin = '$pickupLat,$pickupLng';
    final destination = '$dropLat,$dropLng';

    // https://maps.googleapis.com/maps/api/distancematrix/json?origins=${origin}&destinations=${destination}&key=${apiKey}
    final url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=$origin'
        '&destinations=$destination'
        '&mode=driving'
        '&key=$apiKey';

    try {
      final response = await GetConnect().get(url);

      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      print('API Error: $e');
    }

    return null;
  }

  void _updateFareFromResponse(Map<String, dynamic> response) {
    try {
      final data = response['rows']?[0]?['elements']?[0];

      if (data == null || data['status'] != 'OK') {
        print('No valid distance data');
        return;
      }

      // Get distance and duration
      distance.value = data['distance']?['text'] ?? '';
      duration.value = data['duration']?['text'] ?? '';

      // Calculate fare (simplified formula)
      final distanceInMeters = (data['distance']?['value'] ?? 0).toDouble();
      final durationInSeconds = (data['duration']?['value'] ?? 0).toDouble();

      sendingMetersValue.value = distanceInMeters;

      final distanceInKm = distanceInMeters / 1000;
      final distanceInMiles = distanceInMeters / 1609.34;
      final durationInMinutes = durationInSeconds / 60;

      // ✅ Fixed: Proper null handling for environment variable
      final milesRateStr = dotenv.env['MILES_FARE'];
      final milesRate = double.tryParse(milesRateStr ?? '') ?? 1; // Default rate if not set

      print('Distance (km): $distanceInKm');
      print('Distance (miles): $distanceInMiles');
      print('Miles Rate: \$$milesRate');

      // Calculate fare based on miles
      fare.value = distanceInMiles * milesRate;

      // Round to 2 decimal places
      fare.value = double.parse(fare.value.toStringAsFixed(2));

      print('Distance: ${distance.value}');
      print('Duration: ${duration.value}');
      print('Fare: \$${fare.value}');
    } catch (e) {
      print('Error updating fare: $e');
      fare.value = 0.0;
    }
  }

  RxBool isBookRideState = false.obs;
  RxBool isModalOn = false.obs;
  Future<void>bookRideHandler() async{
    try{
      isBookRideState.value = true;

      final data = {
        "pickupAddress": selectedPickup.value?.address,
        "destinationAddress": selectedDrop.value?.address,
        "note": noteController.text,
        "destinationMeters": sendingMetersValue.value,
        "pickupLocation": {
          "type": "Point",
          "coordinates": [selectedDrop.value?.lng, selectedDrop.value?.lat]
        },
        "destinationLocation": {
          "type": "Point",
          "coordinates": [selectedPickup.value?.lng, selectedPickup.value?.lat]
        }
      };

      final response = await ApiClient.postData(ApiUrls.rideBookRide, data);
      if( response.statusCode == 200 || response.statusCode == 201 ){
          final cnt = Get.find<UserController>();
          cnt.isBottomModalSheetStatus.value = true;
          Get.toNamed(AppRoutes.customBottomNavBar);
          final cntTwo = Get.find<RideController>();
          cntTwo.fetchRiderData();
      }else{
        Get.snackbar('Error', response.body['message']);
      }
    }catch(e){
      debugPrint(e.toString());
    }finally{
      isBookRideState.value = false;
    }

    // print('selected Drop Destination ============>>>  ${selectedDrop.value?.lng}');
    // print('selected Drop Destination ============>>>  ${selectedDrop.value?.lat}');
    // print('selected Drop Destination ============>>>   ${selectedDrop.value?.address}');
    //
    // print('============================      $data', );
    //
    // print('selected Drop Destination ============>>>  ${selectedPickup.value?.lat}');
    // print('selected Drop Destination ============>>>  ${selectedPickup.value?.lng}');
    // print('selected Drop Destination ============>>>  ${selectedPickup.value?.address}');

    // debugPrint('================>>>>>>>>>>>>yessssssssssssss');
    // Get.offAllNamed(AppRoutes.customBottomNavBar);

    // bool status = false;
    // isBookRideState.value = true;
    // try{
    //   final response = await ApiClient.postData(AppRoutes.setHomeLocation,
    //       {}
    //   );
    //   if( response.statusCode == 200 || response.statusCode == 201 ){
    //     status = true;
    //   }else{
    //     status = false;
    //   }
    // }catch(e){
    //   debugPrint(e.toString());
    // }finally{
    //   isBookRideState.value = false;
    // }

  }
  void cleanField(){
    pickupController.clear();
    dropController.clear();
    noteController.clear();
  }
  @override
  void onClose() {
    pickupController.dispose();
    dropController.dispose();
    noteController.dispose();
    _pickupTimer?.cancel();
    _dropTimer?.cancel();
    super.onClose();
  }
}