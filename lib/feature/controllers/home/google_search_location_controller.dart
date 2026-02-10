import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/models/home/place_suggestion.dart';
import 'package:ricardo/services/map_service.dart';

class GoogleSearchLocationController extends GetxController {
  final pickUpLocation = TextEditingController();

  RxList<PlaceSuggestion> pickupSuggestions = <PlaceSuggestion>[].obs;
  RxBool isLoadingPickup = false.obs;

  Timer? _debouncePickup;

  // Selected Location Data
  Rx<PlaceDetails?> selectedPickup = Rx<PlaceDetails?>(null);

  // ✅ ADD THIS FLAG - prevents search when selecting
  bool _isSelectingLocation = false;

  @override
  void onInit() {
    super.onInit();

    pickUpLocation.addListener(() {
      // ✅ Only search if NOT programmatically setting text
      if (!_isSelectingLocation) {
        _onPickupChange(pickUpLocation.text);
      }
    });
  }

  void _onPickupChange(String query) {
    if (_debouncePickup?.isActive ?? false) _debouncePickup!.cancel();
    _debouncePickup = Timer(Duration(milliseconds: 500), () {
      searchPickupLocation(query);
    });
  }

  Future<void> searchPickupLocation(String query) async {
    if (query.isEmpty) {
      pickupSuggestions.clear();
      isLoadingPickup.value = false;
      return;  // ✅ Return early if empty
    }

    isLoadingPickup.value = true;

    final results = await PlacesService.getPlaceSuggestions(query);
    pickupSuggestions.value = results;
    isLoadingPickup.value = false;
  }

  Future<void> selectPickupLocation(PlaceSuggestion suggestion) async {
    // ✅ Prevent listener from triggering
    _isSelectingLocation = true;

    pickUpLocation.text = suggestion.description;
    pickupSuggestions.clear();  // ✅ Clear immediately

    // ✅ Small delay then reset flag
    Future.delayed(Duration(milliseconds: 100), () {
      _isSelectingLocation = false;
    });

    // Get detailed info
    final details = await PlacesService.getPlaceDetails(suggestion.placeId);
    selectedPickup.value = details;
  }

  @override
  void onClose() {
    super.onClose();
    pickUpLocation.dispose();
    _debouncePickup?.cancel();
  }
}