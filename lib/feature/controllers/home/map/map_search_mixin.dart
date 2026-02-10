/*
mixin MapSearchMixin on GetxController {
  final searchController = TextEditingController();
  final String googleApiKey = "";

  // static const String _googleApiKey = String.fromEnvironment(
  //     'GOOGLE_MAPS_API_KEY',
  //     defaultValue: 'KEY_NOT_FOUND'
  // );
  //
  //
  // final String googleApiKey = _googleApiKey;

  GoogleMapController? mapController;
  var selectedLatLng = const LatLng(23.8311, 90.4243).obs;
  var currentAddressString = ''.obs;
  var selectedCity = 'Dhaka'.obs;
  var selectedCountry = 'Bangladesh'.obs;
  var placePredictions = <Map<String, dynamic>>[].obs;
  Timer? _debounce;

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => getSuggestions(query));
  }

  Future<void> getSuggestions(String query) async {
    if (query.isEmpty) {
      placePredictions.clear();
      return;
    }
    try {
      final url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$googleApiKey";
      final response = await dio_instance.Dio().get(url);
      if (response.statusCode == 200) {
        final List predictions = response.data['predictions'];
        placePredictions.assignAll(predictions.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint("Autocomplete Error: $e");
    }
  }

  Future<void> selectPrediction(Map<String, dynamic> prediction) async {
    String placeId = prediction['place_id'];
    searchController.text = prediction['description'] ?? "";
    placePredictions.clear();
    try {
      final detailUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleApiKey";
      final response = await dio_instance.Dio().get(detailUrl);
      if (response.statusCode == 200) {
        final location = response.data['result']['geometry']['location'];
        updateLocation(LatLng(location['lat'], location['lng']));
        FocusManager.instance.primaryFocus?.unfocus();
      }
    } catch (e) {
      debugPrint("Place Details Error: $e");
    }
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    Position position = await Geolocator.getCurrentPosition();
    updateLocation(LatLng(position.latitude, position.longitude));
  }

  Future<void> updateLocation(LatLng latLng) async {
    selectedLatLng.value = latLng;
    mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        selectedCity.value = place.locality ?? '';
        selectedCountry.value = place.country ?? '';
        currentAddressString.value = "${place.street}, ${place.locality}, ${place.country}";
      }
    } catch (e) {
      debugPrint("Reverse Geocoding Error: $e");
    }
  }

  void onMapCreated(GoogleMapController controller) => mapController = controller;

  void disposeMapMixin() {
    searchController.dispose();
    _debounce?.cancel();
  }
}*/
