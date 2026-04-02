import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
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

  // ✅ Explicit visibility flags
  RxBool showPickupSuggestions = false.obs;
  RxBool showDropSuggestions = false.obs;

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

  // Modal state
  RxBool isModalOn = false.obs;
  RxBool showPopUpStatus = false.obs;
  RxBool isBookRideState = false.obs;

  // Timers for search delay
  Timer? _pickupTimer;
  Timer? _dropTimer;

  bool _isSelectingPickup = false;
  bool _isSelectingDrop = false;

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
  }

  // ✅ Named listeners so they can be removed/added
  void _pickupListener() {
    final hasText = pickupController.text.isNotEmpty;
    if (showClearPickup.value != hasText) showClearPickup.value = hasText;
    if (!_isSelectingPickup) {
      _startPickupSearch();
    }
  }

  void _dropListener() {
    final hasText = dropController.text.isNotEmpty;
    if (showClearDrop.value != hasText) showClearDrop.value = hasText;
    if (!_isSelectingDrop) {
      _startDropSearch();
    }
  }

  void _setupListeners() {
    pickupController.addListener(_pickupListener);
    dropController.addListener(_dropListener);
  }

  void _startPickupSearch() {
    _pickupTimer?.cancel();
    _pickupTimer = Timer(const Duration(milliseconds: 500), () {
      _searchPickup(pickupController.text);
    });
  }

  void _startDropSearch() {
    _dropTimer?.cancel();
    _dropTimer = Timer(const Duration(milliseconds: 500), () {
      _searchDrop(dropController.text);
    });
  }

  Future<void> _searchPickup(String query) async {
    if (query.isEmpty) {
      pickupPlaces.clear();
      showPickupSuggestions.value = false; // ✅
      isLoadingPickup.value = false;
      return;
    }

    isLoadingPickup.value = true;
    try {
      final results = await PlacesService.getPlaceSuggestions(query);
      pickupPlaces.value = results;
      showPickupSuggestions.value = results.isNotEmpty; // ✅
    } finally {
      isLoadingPickup.value = false;
    }
  }

  Future<void> _searchDrop(String query) async {
    if (query.isEmpty) {
      dropPlaces.clear();
      showDropSuggestions.value = false; // ✅
      isLoadingDrop.value = false;
      return;
    }

    isLoadingDrop.value = true;
    try {
      final results = await PlacesService.getPlaceSuggestions(query);
      dropPlaces.value = results;
      showDropSuggestions.value = results.isNotEmpty; // ✅
    } finally {
      isLoadingDrop.value = false;
    }
  }

  Future<void> selectPickup(PlaceSuggestion place) async {
    _isSelectingPickup = true;
    _pickupTimer?.cancel();

    // ✅ Hide suggestions immediately
    pickupPlaces.clear();
    showPickupSuggestions.value = false;

    // ✅ Remove listener before setting text
    pickupController.removeListener(_pickupListener);
    pickupController.text = place.description;
    pickupController.addListener(_pickupListener);

    showClearPickup.value = true;
    _isSelectingPickup = false;

    final details = await PlacesService.getPlaceDetails(place.placeId);
    selectedPickup.value = details;
  }

  Future<void> selectDrop(PlaceSuggestion place) async {
    _isSelectingDrop = true;
    _dropTimer?.cancel();

    // ✅ Hide suggestions immediately
    dropPlaces.clear();
    showDropSuggestions.value = false;

    // ✅ Remove listener before setting text
    dropController.removeListener(_dropListener);
    dropController.text = place.description;
    dropController.addListener(_dropListener);

    showClearDrop.value = true;
    _isSelectingDrop = false;

    final details = await PlacesService.getPlaceDetails(place.placeId);
    selectedDrop.value = details;
  }

  void clearPickup() {
    pickupController.removeListener(_pickupListener);
    pickupController.clear();
    pickupController.addListener(_pickupListener);
    showClearPickup.value = false;
    pickupPlaces.clear();
    showPickupSuggestions.value = false; // ✅
    selectedPickup.value = null;
    _clearFare();
  }

  void clearDrop() {
    dropController.removeListener(_dropListener);
    dropController.clear();
    dropController.addListener(_dropListener);
    showClearDrop.value = false;
    dropPlaces.clear();
    showDropSuggestions.value = false; // ✅
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

  bool get canCalculateFare =>
      selectedPickup.value != null && selectedDrop.value != null;

  bool get hasFare => fare.value > 0;

  void hideModal() => isModalOn.value = false;
  void showModal() => isModalOn.value = true;

  Future<void> calculateFare() async {
    if (!canCalculateFare) {
      Get.snackbar('Error', 'Please select both locations');
      return;
    }

    isLoadingFare.value = true;

    try {
      final pickup = selectedPickup.value!;
      final drop = selectedDrop.value!;

      final apiResponse = await _getDistanceFromGoogle(
        pickupLat: pickup.lat,
        pickupLng: pickup.lng,
        dropLat: drop.lat,
        dropLng: drop.lng,
      );

      if (apiResponse != null) {
        showPopUpStatus.value = true;
        _updateFareFromResponse(apiResponse);
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
      debugPrint('API Error: $e');
    }

    return null;
  }

  void _updateFareFromResponse(Map<String, dynamic> response) {
    try {
      final data = response['rows']?[0]?['elements']?[0];

      if (data == null || data['status'] != 'OK') {
        debugPrint('No valid distance data');
        return;
      }

      distance.value = data['distance']?['text'] ?? '';
      duration.value = data['duration']?['text'] ?? '';

      final distanceInMeters = (data['distance']?['value'] ?? 0).toDouble();

      sendingMetersValue.value = distanceInMeters;

      final distanceInMiles = distanceInMeters / 1609.34;
      final milesRateStr = dotenv.env['MILES_FARE'];
      final milesRate = double.tryParse(milesRateStr ?? '') ?? 1;

      fare.value = double.parse(
        (distanceInMiles * milesRate).toStringAsFixed(2),
      );

      debugPrint('Distance: ${distance.value}');
      debugPrint('Duration: ${duration.value}');
      debugPrint('Fare: \$${fare.value}');
    } catch (e) {
      debugPrint('Error updating fare: $e');
      fare.value = 0.0;
    }
  }

  Future<void> bookRideHandler() async {
    try {
      isBookRideState.value = true;

      final data = {
        "pickupAddress": selectedPickup.value?.address,
        "destinationAddress": selectedDrop.value?.address,
        "note": noteController.text,
        "destinationMeters": sendingMetersValue.value,
        "pickupLocation": {
          "type": "Point",
          "coordinates": [
            selectedPickup.value?.lng,
            selectedPickup.value?.lat,
          ],
        },
        "destinationLocation": {
          "type": "Point",
          "coordinates": [
            selectedDrop.value?.lng,
            selectedDrop.value?.lat,
          ],
        },
      };

      final response = await ApiClient.postData(ApiUrls.rideBookRide, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final cnt = Get.find<UserController>();
        cnt.isBottomModalSheetStatus.value = true;
        Get.toNamed(AppRoutes.customBottomNavBar);
        final id = response.body['data']['_id'];

        final cntTwo = Get.find<RideController>();
        cntTwo.rideId.value = id;
        cntTwo.fetchRiderData(id);
      } else {
        Get.snackbar('Error', response.body['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isBookRideState.value = false;
    }
  }

  void cleanField() {
    pickupController.removeListener(_pickupListener);
    dropController.removeListener(_dropListener);

    pickupController.clear();
    dropController.clear();
    noteController.clear();
    pickupPlaces.clear();
    dropPlaces.clear();
    showPickupSuggestions.value = false;
    showDropSuggestions.value = false;
    selectedPickup.value = null;
    selectedDrop.value = null;
    _clearFare();

    pickupController.addListener(_pickupListener);
    dropController.addListener(_dropListener);
  }

  @override
  void onClose() {
    pickupController.removeListener(_pickupListener);
    dropController.removeListener(_dropListener);
    pickupController.dispose();
    dropController.dispose();
    noteController.dispose();
    _pickupTimer?.cancel();
    _dropTimer?.cancel();
    super.onClose();
  }
}