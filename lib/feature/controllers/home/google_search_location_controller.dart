import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/helpers/custom_location_helper.dart';
import 'package:ricardo/feature/controllers/app_settings_controller.dart';
import 'package:ricardo/feature/controllers/home/map/ride_controller.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/feature/models/home/place_suggestion.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';
import 'package:ricardo/services/map_service.dart';
import 'package:ricardo/app/helpers/snackbar_helper.dart';

class GoogleSearchLocationController extends GetxController {
  // Text controllers
  final pickupController = TextEditingController();
  final dropController = TextEditingController();
  final noteController = TextEditingController();

  // Suggestions lists
  final pickupPlaces = <PlaceSuggestion>[].obs;
  final dropPlaces = <PlaceSuggestion>[].obs;

  // Explicit visibility flags — the ONLY gate the UI should check
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

  // User's current location for search biasing
  // This ensures location search results are restricted to the user's city area (50km radius)
  double? userLatitude;
  double? userLongitude;

  // Fare calculation results
  final distance = ''.obs;
  final duration = ''.obs;
  final fare = 0.0.obs;
  final sendingMetersValue = 0.0.obs;

  // Modal state
  RxBool isModalOn = false.obs;
  RxBool showPopUpStatus = false.obs;
  RxBool isBookRideState = false.obs;

  // Timers for search debounce
  Timer? _pickupTimer;
  Timer? _dropTimer;

  // Generation counters — incremented on every selection/clear so any
  // in-flight network result that arrives late is discarded.
  int _pickupGen = 0;
  int _dropGen = 0;

  // When true, the field has a confirmed selection and typing hasn't started
  // yet, so listener changes must NOT trigger a search.
  bool _pickupLocked = false;
  bool _dropLocked = false;

  // The confirmed text at the time of selection. If the listener fires and
  // the text still equals this, it was NOT a real user keystroke.
  String _confirmedPickupText = '';
  String _confirmedDropText = '';

  @override
  void onInit() {
    super.onInit();
    _getUserCurrentLocation();
    pickupController.addListener(_pickupListener);
    dropController.addListener(_dropListener);
  }

  Future<void> _getUserCurrentLocation() async {
    try {
      final position = await CustomLocationHelper.getCurrentLocation();
      userLatitude = position.latitude;
      userLongitude = position.longitude;
      debugPrint('User location for search: $userLatitude, $userLongitude');
    } catch (e) {
      debugPrint('Failed to get user location for search: $e');
      // Continue without location bias if location fetch fails
    }
  }

  void _pickupListener() {
    final text = pickupController.text;
    showClearPickup.value = text.isNotEmpty;

    // If locked and the text hasn't changed from the confirmed selection,
    // this is a spurious listener call — ignore it.
    if (_pickupLocked && text == _confirmedPickupText) return;

    // User started typing something different — unlock and search.
    _pickupLocked = false;
    _confirmedPickupText = '';
    _startPickupSearch();
  }

  void _dropListener() {
    final text = dropController.text;
    showClearDrop.value = text.isNotEmpty;

    if (_dropLocked && text == _confirmedDropText) return;

    _dropLocked = false;
    _confirmedDropText = '';
    _startDropSearch();
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
    final gen = ++_pickupGen;

    if (query.isEmpty) {
      pickupPlaces.clear();
      showPickupSuggestions.value = false;
      isLoadingPickup.value = false;
      return;
    }

    isLoadingPickup.value = true;
    try {
      final results = await PlacesService.getPlaceSuggestions(
        query,
        latitude: userLatitude,
        longitude: userLongitude,
        radiusInMeters: 50000, // 50km radius
      );
      if (gen != _pickupGen) return; // stale result, discard
      pickupPlaces.value = results;
      showPickupSuggestions.value = results.isNotEmpty;
    } finally {
      if (gen == _pickupGen) isLoadingPickup.value = false;
    }
  }

  Future<void> _searchDrop(String query) async {
    final gen = ++_dropGen;

    if (query.isEmpty) {
      dropPlaces.clear();
      showDropSuggestions.value = false;
      isLoadingDrop.value = false;
      return;
    }

    isLoadingDrop.value = true;
    try {
      final results = await PlacesService.getPlaceSuggestions(
        query,
        latitude: userLatitude,
        longitude: userLongitude,
        radiusInMeters: 50000, // 50km radius
      );
      if (gen != _dropGen) return; // stale result, discard
      dropPlaces.value = results;
      showDropSuggestions.value = results.isNotEmpty;
    } finally {
      if (gen == _dropGen) isLoadingDrop.value = false;
    }
  }

  Future<void> selectPickup(PlaceSuggestion place) async {
    // 1. Cancel any pending debounce timer.
    _pickupTimer?.cancel();

    // 2. Invalidate any in-flight network request.
    ++_pickupGen;

    // 3. Hide suggestions and spinner immediately — synchronous, instant.
    showPickupSuggestions.value = false;
    isLoadingPickup.value = false;
    pickupPlaces.clear();

    // 4. Set text without triggering a search by locking first.
    _pickupLocked = true;
    _confirmedPickupText = place.description;
    pickupController.text = place.description;
    showClearPickup.value = true;

    // 5. Fetch place details in the background.
    try {
      final details = await PlacesService.getPlaceDetails(place.placeId);
      selectedPickup.value = details;
    } catch (_) {
      // Keep the text even if details fetch fails
    }
  }

  Future<void> selectDrop(PlaceSuggestion place) async {
    _dropTimer?.cancel();
    ++_dropGen;

    showDropSuggestions.value = false;
    isLoadingDrop.value = false;
    dropPlaces.clear();

    _dropLocked = true;
    _confirmedDropText = place.description;
    dropController.text = place.description;
    showClearDrop.value = true;

    try {
      final details = await PlacesService.getPlaceDetails(place.placeId);
      selectedDrop.value = details;
    } catch (_) {
      // Keep the text even if details fetch fails
    }
  }

  void clearPickup() {
    ++_pickupGen;
    _pickupTimer?.cancel();
    _pickupLocked = false;
    _confirmedPickupText = '';

    pickupController.text = '';
    showClearPickup.value = false;
    pickupPlaces.clear();
    showPickupSuggestions.value = false;
    isLoadingPickup.value = false;
    selectedPickup.value = null;
    _clearFare();
  }

  void clearDrop() {
    ++_dropGen;
    _dropTimer?.cancel();
    _dropLocked = false;
    _confirmedDropText = '';

    dropController.text = '';
    showClearDrop.value = false;
    dropPlaces.clear();
    showDropSuggestions.value = false;
    isLoadingDrop.value = false;
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
      showSnackbar('Error', 'Please select both locations');
      return;
    }

    isLoadingFare.value = true;

    try {
      final appSettings = Get.find<AppSettingsController>();
      if (appSettings.settings.value == null) {
        await appSettings.fetchSettings();
      }

      final pickup = selectedPickup.value!;
      final drop = selectedDrop.value!;

      final apiResponse = await _getDistanceFromGoogle(
        pickupLat: pickup.lat,
        pickupLng: pickup.lng,
        dropLat: drop.lat,
        dropLng: drop.lng,
      );
      if (apiResponse != null && _updateFareFromResponse(apiResponse)) {
        showPopUpStatus.value = true;
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

  bool _updateFareFromResponse(Map<String, dynamic> response) {
    try {
      final apiStatus = response['status'];
      if (apiStatus != 'OK') {
        final errorMsg = response['error_message'] ?? 'no error_message field';
        debugPrint(
            'Distance Matrix API error: status=$apiStatus, message=$errorMsg');
        _clearFare();
        return false;
      }

      final rows = response['rows'];
      if (rows is! List || rows.isEmpty) {
        _clearFare();
        return false;
      }

      final firstRow = rows.first;
      if (firstRow is! Map<String, dynamic>) {
        _clearFare();
        return false;
      }

      final elements = firstRow['elements'];
      if (elements is! List || elements.isEmpty) {
        _clearFare();
        return false;
      }

      final data = elements.first;
      if (data is! Map<String, dynamic> || data['status'] != 'OK') {
        _clearFare();
        return false;
      }

      distance.value = data['distance']?['text'] ?? '';
      duration.value = data['duration']?['text'] ?? '';

      final distanceInMeters = (data['distance']?['value'] ?? 0).toDouble();
      sendingMetersValue.value = distanceInMeters;

      final distanceInMiles = distanceInMeters / 1609.34;
      final milesRate = Get.find<AppSettingsController>().perMilePrice;

      fare.value = double.parse(
        (distanceInMiles * milesRate).toStringAsFixed(2),
      );

      debugPrint('Distance: ${distance.value}');
      debugPrint('Duration: ${duration.value}');
      debugPrint('Fare: \$${fare.value}');
      return true;
    } catch (e) {
      debugPrint('Error updating fare: $e');
      _clearFare();
      return false;
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
        showSnackbar('Error', response.body['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isBookRideState.value = false;
    }
  }

  void cleanField() {
    _pickupTimer?.cancel();
    _dropTimer?.cancel();
    _pickupLocked = false;
    _dropLocked = false;
    _confirmedPickupText = '';
    _confirmedDropText = '';

    pickupController.text = '';
    dropController.text = '';
    noteController.clear();
    pickupPlaces.clear();
    dropPlaces.clear();
    showPickupSuggestions.value = false;
    showDropSuggestions.value = false;
    showClearPickup.value = false;
    showClearDrop.value = false;
    selectedPickup.value = null;
    selectedDrop.value = null;
    _clearFare();
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
